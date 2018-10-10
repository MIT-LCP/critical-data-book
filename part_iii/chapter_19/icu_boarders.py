
# coding: utf-8

# In[1]:

get_ipython().magic('matplotlib inline')

from chatto_transform.sessions.mimic import mimic_common
from chatto_transform.schema.mimic import mimic_schema
from chatto_transform.lib.chunks import left_join

from chatto_transform.transforms.mimic import care_value

import pandas as pd
import numpy as np


# In[ ]:

# Load the Transfers table
# NB: This requires both a 'phitransfers' table which
# differs from the publicly accessible version of MIMIC-III 
# in that it contains protected health information (PHI)
transfers = mimic_common.load_table(mimic_schema.phitransfers_schema)
mimic_schema.transfers_schema.add_prefix(transfers)

# Load the Services table
# NB: This requires both a 'phiservices' table which
# differs from the publicly accessible version of MIMIC-III 
# in that it contains protected health information (PHI)
services = mimic_common.load_table(mimic_schema.phiservices_schema)
mimic_schema.services_schema.add_prefix(services)


# In[ ]:

# Load the publicly accessible version of the Services table
# and date restrict it simply to reduce the size slightly by eliminating
# entries far outside the dates of interest
services = services[services['services.transfertime'] > pd.Timestamp('20010101')]


# In[ ]:

# Create a 'med_service_only' dataframe: essentially a copy of the Services table that only contains entries
# related to those patients who were taken care of exclusively by the MED service during their hospital admission.
# i.e. curr_service = 'MED' and size(hadm_id) = 1
row_ids = services.groupby('services.hadm_id').size()
row_ids = row_ids[row_ids < 2]
one_service_only = services[services['services.hadm_id'].isin(row_ids.index)]
med_service_only = one_service_only[one_service_only['services.curr_service'] == 'MED']


# In[ ]:

# Left join transfers to med_service_only.
# This creates a dataframe 'df' where every transfer in the database is represented, but only those patients
# taken care of exclusively by the MED service during their stay have data from the Services table.
df = left_join(transfers, med_service_only, left_on='transfers.hadm_id', right_on='services.hadm_id')


# In[ ]:

# Remove transfers that are not related to an ICU stay
df2 = df[df['transfers.icustay_id'].notnull()]

# Filter to specified dates
# MICU == CC6D & CC7D after April 10th, 2006 (until end of dataset)
df3 = df2[(df2['transfers.intime'] > pd.Timestamp('20060410'))]

# Select out those patients who were under the care of either of a 'West Campus' MICU team
# MSICU is a MICU but it is on the 'East Campus' and not of interest in this study.
df4 = df3[(df3['services.curr_service'] == 'MED') & (df3['transfers.curr_careunit'] != 'MSICU')]


# In[ ]:

# Trim down the dataframe that we will check each MICU patient against to 
# determine the presence of inboarders (non-MICU patients boarding in the MICU)

inboarders = df3[(df3['services.curr_service'] != 'MED') & 
                 ((df3['curr_ward'] == 'CC6D') | (df3['curr_ward'] == 'CC7D'))]

inboarders = inboarders[['transfers.intime', 'transfers.outtime', 'curr_ward']]


# In[ ]:

# For each patient under the care of a West Campus MICU team, calculate the number of
# non-MICU patients (i.e. cared for by other ICU teams) physically occupying MICU beds

# Start with a copy of the dataframe containing all the MICU patients
df5 = df4

# Create a column that defines 1 = patient being cared for by a MICU team in a location other
# than a MICU (e.g. in the SICU). We default to 0 here, then change the value if appropriate during for loop below.
df5['boarder_status'] = 0

# Create a column that distinguishes whether the patient is on the MICU Orange or Green service
# 0 = Orange, 1 = Green
df5['micu_team'] = 0

# Create columns that specify how many non-MICU patients were occupying MICU beds at the time 
# each patient was admitted/transferred to the care of a MICU team
df5['cc6d_boarder_count'] = np.nan
df5['cc7d_boarder_count'] = np.nan
df5['total_boarder_count'] = np.nan

for row_index, row in df5.iterrows():
    
    # Determine which patients in the inboarders dataframe (non-MICU patients in MICU beds) were in
    # MICU-Orange (CC6D) and MICU-Green (CC7D) beds at the time of each MICU patient's ICU stay intime
    cc6d_boarders = inboarders[((inboarders['transfers.intime'] < row['transfers.intime']) & 
                               (inboarders['transfers.outtime'] > row['transfers.intime'])) & 
                               (inboarders['curr_ward'] == 'CC6D')]
    
    cc7d_boarders = inboarders[((inboarders['transfers.intime'] < row['transfers.intime']) & 
                               (inboarders['transfers.outtime'] > row['transfers.intime'])) &
                               (inboarders['curr_ward'] == 'CC7D')]
    
    # Create a new dataframe by concatenating the CC6D and CC7D boarder dataframes
    combined_boarders = pd.concat([cc6d_boarders, cc7d_boarders])
    
    # Store the inboarder counts in their respective columns
    df5.ix[row_index, 'cc6d_boarder_count'] = len(cc6d_boarders.index)
    df5.ix[row_index, 'cc7d_boarder_count'] = len(cc7d_boarders.index)
    df5.ix[row_index, 'total_boarder_count'] = len(combined_boarders.index)
    
    # If this row represents a MICU patient boarding in a non-MICU ICU bed, change 'boarder_status' to 1 (default = 0)
    if ((row['curr_ward'] != 'CC6D') & (row['curr_ward'] != 'CC7D')):
        df5.ix[row_index, 'boarder_status'] = 1
        
        # If this is a MICU patient boarding in the CVICU, it is most likely a patient cared for by the MICU Green team
        if (row['transfers.curr_careunit'] == 'CVICU'):
            df5.ix[row_index, 'micu_team'] = 1
        
    # If this row represents a MICU patient in CC7D, it is almost certainly a patient cared for by the MICU Green team
    if (row['curr_ward'] == 'CC7D'):
        df5.ix[row_index, 'micu_team'] = 1


# In[2]:

# Store df5
# mimic_common.df_to_csv('df5.csv', df5)

# Load df5 from stored CSV file (if we don't want to have to re-generate it)
# df5 = pd.read_csv('~/dev/data/mimic3_local_storage/df5.csv', parse_dates=[8, 15, 20])


# In[3]:

# Add the OASIS severity of illness scores to each row
oasis = pd.read_csv('~/chatto-transform/oasis.csv')
df5 = left_join(df5, oasis[['ICUSTAY_ID', 'OASIS']], left_on='transfers.icustay_id', right_on='ICUSTAY_ID')
df5 = df5.drop('ICUSTAY_ID', 1)

# Add the Elixhauser comorbidity scores to each row
elixhauser = pd.read_csv('~/chatto-transform/elixhauser.csv')
df5 = left_join(df5, elixhauser, left_on='transfers.hadm_id', right_on='hadm_id')


# In[6]:

# Team census and outboarder count for the MICU team taking care of a given patient
df5['team_census'] = np.nan
df5['team_outboarders'] = np.nan
df5['team_census_same_room'] = np.nan

# Average severity of illness measures for the ICU as a whole at a given time
df5['team_census_oasis_mean_combined'] = np.nan
df5['team_census_oasis_median_combined'] = np.nan
df5['team_census_oasis_mean_boarders'] = np.nan
df5['team_census_oasis_median_boarders'] = np.nan
df5['team_census_oasis_mean_nonboarders'] = np.nan
df5['team_census_oasis_median_nonboarders'] = np.nan
df5['team_census_oasis_mean_same_room'] = np.nan
df5['team_census_oasis_median_same_room'] = np.nan

df5['team_census_elixhauser_28day_mean_combined'] = np.nan
df5['team_census_elixhauser_28day_median_combined'] = np.nan
df5['team_census_elixhauser_28day_mean_boarders'] = np.nan
df5['team_census_elixhauser_28day_median_boarders'] = np.nan
df5['team_census_elixhauser_28day_mean_nonboarders'] = np.nan
df5['team_census_elixhauser_28day_median_nonboarders'] = np.nan
df5['team_census_elixhauser_28day_mean_same_room'] = np.nan
df5['team_census_elixhauser_28day_median_same_room'] = np.nan

df5['team_census_elixhauser_hospital_mean_combined'] = np.nan
df5['team_census_elixhauser_hospital_median_combined'] = np.nan
df5['team_census_elixhauser_hospital_mean_boarders'] = np.nan
df5['team_census_elixhauser_hospital_median_boarders'] = np.nan
df5['team_census_elixhauser_hospital_mean_nonboarders'] = np.nan
df5['team_census_elixhauser_hospital_median_nonboarders'] = np.nan
df5['team_census_elixhauser_hospital_mean_same_room'] = np.nan
df5['team_census_elixhauser_hospital_median_same_room'] = np.nan


# For each MICU patient...
for row_index, row in df5.iterrows():
    
    # ... being taken care of by the MICU-Orange team ...
    if (row['micu_team'] == 0):
        
        # Determine how many patients (boarders + non-boarders) were assigned to the MICU Orange team at that time
        # NOT INCLUSIVE OF THIS PATIENT
        census = df5[(df5['transfers.intime'] < row['transfers.intime']) & 
                     (df5['transfers.outtime'] > row['transfers.intime']) & 
                     (df5['micu_team'] == 0)]
        
        # Determine how many NON-boarders the MICU-Orange service was taking care of at that time.
        # NOT INCLUSIVE OF THIS PATIENT
        nonboarders = census[census['transfers.curr_ward'] == 'CC6D']
        
        # Determine how many boarders the MICU-Orange service was taking care of at that time.
        # NOT INCLUSIVE OF THIS PATIENT
        outboarders = census[census['transfers.curr_ward'] != 'CC6D']
#         outboarders = df5[(df5['transfers.intime'] < row['transfers.intime']) &
#                           (df5['transfers.outtime'] > row['transfers.intime']) & 
#                           (df5['micu_team'] == 0) &
#                           (df5['curr_ward'] != 'CC6D')]

        # Determine how many patients the MICU-Orange service was taking care of at that time...
        # ...IN THE SAME ROOM AS THIS PATIENT
        # ...NOT INCLUSIVE OF THIS PATIENT
        census_same_room = census[census['transfers.curr_ward'] == row['transfers.curr_ward']]
        
    # ... being taken care of by the MICU-Green team ...
    else:
        
        # Determine how many patients (boarders + non-boarders) were assigned to the MICU Green team at that time
        # NOT INCLUSIVE OF THIS PATIENT
        census = df5[(df5['transfers.intime'] < row['transfers.intime']) & 
                     (df5['transfers.outtime'] > row['transfers.intime']) & 
                     (df5['micu_team'] == 1)]
    
        # Determine how many NON-boarders the MICU-Green service was taking care of at that time.
        # NOT INCLUSIVE OF THIS PATIENT
        nonboarders = census[census['transfers.curr_ward'] == 'CC7D']
        
        # Determine how many boarders the MICU-Green service was taking care of at that time.
        # NOT INCLUSIVE OF THIS PATIENT
        outboarders = census[census['transfers.curr_ward'] != 'CC7D']
#         outboarders = df5[(df5['transfers.intime'] < row['transfers.intime']) &
#                           (df5['transfers.outtime'] > row['transfers.intime']) & 
#                           (df5['micu_team'] == 1) &
#                           (df5['curr_ward'] != 'CC7D')]

        # Determine how many patients the MICU-Orange service was taking care of at that time...
        # ...IN THE SAME ROOM AS THIS PATIENT
        # ...NOT INCLUSIVE OF THIS PATIENT
        census_same_room = census[census['transfers.curr_ward'] == row['transfers.curr_ward']]
        
    
    df5.ix[row_index, 'team_census'] = len(census.index)
    df5.ix[row_index, 'team_outboarders'] = len(outboarders)
    df5.ix[row_index, 'team_census_same_room'] = len(census_same_room)
    
    df5.ix[row_index, 'team_census_oasis_mean_combined'] = census['OASIS'].mean()
    df5.ix[row_index, 'team_census_oasis_median_combined'] = census['OASIS'].median()
    df5.ix[row_index, 'team_census_oasis_mean_boarders'] = outboarders['OASIS'].mean()
    df5.ix[row_index, 'team_census_oasis_median_boarders'] = outboarders['OASIS'].median()
    df5.ix[row_index, 'team_census_oasis_mean_nonboarders'] = nonboarders['OASIS'].mean()
    df5.ix[row_index, 'team_census_oasis_median_nonboarders'] = nonboarders['OASIS'].median()
    df5.ix[row_index, 'team_census_oasis_mean_same_room'] = census_same_room['OASIS'].mean()
    df5.ix[row_index, 'team_census_oasis_median_same_room'] = census_same_room['OASIS'].median()

    df5.ix[row_index, 'team_census_elixhauser_28day_mean_combined'] = census['elixhauser_28day'].mean()
    df5.ix[row_index, 'team_census_elixhauser_28day_median_combined'] = census['elixhauser_28day'].median()
    df5.ix[row_index, 'team_census_elixhauser_28day_mean_boarders'] = outboarders['elixhauser_28day'].mean()
    df5.ix[row_index, 'team_census_elixhauser_28day_median_boarders'] = outboarders['elixhauser_28day'].median()
    df5.ix[row_index, 'team_census_elixhauser_28day_mean_nonboarders'] = nonboarders['elixhauser_28day'].mean()
    df5.ix[row_index, 'team_census_elixhauser_28day_median_nonboarders'] = nonboarders['elixhauser_28day'].median()
    df5.ix[row_index, 'team_census_elixhauser_28day_mean_same_room'] = census_same_room['elixhauser_28day'].mean()
    df5.ix[row_index, 'team_census_elixhauser_28day_median_same_room'] = census_same_room['elixhauser_28day'].median()

    df5.ix[row_index, 'team_census_elixhauser_hospital_mean_combined'] = census['elixhauser_hospital'].mean()
    df5.ix[row_index, 'team_census_elixhauser_hospital_median_combined'] = census['elixhauser_hospital'].median()
    df5.ix[row_index, 'team_census_elixhauser_hospital_mean_boarders'] = outboarders['elixhauser_hospital'].mean()
    df5.ix[row_index, 'team_census_elixhauser_hospital_median_boarders'] = outboarders['elixhauser_hospital'].median()
    df5.ix[row_index, 'team_census_elixhauser_hospital_mean_nonboarders'] = nonboarders['elixhauser_hospital'].mean()
    df5.ix[row_index, 'team_census_elixhauser_hospital_median_nonboarders'] = nonboarders['elixhauser_hospital'].median()
    df5.ix[row_index, 'team_census_elixhauser_hospital_mean_same_room'] = census_same_room['elixhauser_hospital'].mean()
    df5.ix[row_index, 'team_census_elixhauser_hospital_median_same_room'] = census_same_room['elixhauser_hospital'].median()


# In[7]:

# Store df5v2
# mimic_common.df_to_csv('df5v2.csv', df5)

# Load df5v2 from stored CSV file (if we don't want to have to re-generate it)
# df5 = pd.read_csv('~/dev/data/mimic3_local_storage/df5v2.csv', parse_dates=[8, 15, 20])


# In[8]:

# Team census and outboarder count for the OTHER MICU team (the one NOT caring for a given patient)
df5['other_team_census'] = np.nan
df5['other_team_outboarders'] = np.nan

# Average severity of illness measures for the ICU as a whole at a given time
df5['other_team_census_oasis_mean'] = np.nan
df5['other_team_census_oasis_median'] = np.nan

df5['other_team_census_elixhauser_28day_mean'] = np.nan
df5['other_team_census_elixhauser_28day_median'] = np.nan

df5['other_team_census_elixhauser_hospital_mean'] = np.nan
df5['other_team_census_elixhauser_hospital_median'] = np.nan

# For each MICU patient...
for row_index, row in df5.iterrows():
    
    # ... being taken care of by the MICU-Orange team ...
    if (row['micu_team'] == 0):
        
        # Determine how many patients (boarders + non-boarders) were assigned to the MICU Green team at that time
        census = df5[(df5['transfers.intime'] < row['transfers.intime']) & 
                     (df5['transfers.outtime'] > row['transfers.intime']) & 
                     (df5['micu_team'] == 1)]
        
        # Determine how many boarders the MICU-Green service was taking care of at that time.
        outboarders = census[census['transfers.curr_ward'] != 'CC7D']
#         outboarders = df5[(df5['transfers.intime'] < row['transfers.intime']) &
#                           (df5['transfers.outtime'] > row['transfers.intime']) & 
#                           (df5['micu_team'] == 1) &
#                           (df5['curr_ward'] != 'CC7D')]
    
    # ... being taken care of by the MICU-Green team ...
    else:
        
        # Determine how many patients (boarders + non-boarders) were assigned to the MICU Orange team at that time
        census = df5[(df5['transfers.intime'] < row['transfers.intime']) & 
                     (df5['transfers.outtime'] > row['transfers.intime']) & 
                     (df5['micu_team'] == 0)]
    
        # Determine how many boarders the MICU-Orange service was taking care of at that time.
        outboarders = census[census['transfers.curr_ward'] != 'CC6D']
#         outboarders = df5[(df5['transfers.intime'] < row['transfers.intime']) &
#                           (df5['transfers.outtime'] > row['transfers.intime']) & 
#                           (df5['micu_team'] == 0) &
#                           (df5['curr_ward'] != 'CC6D')]
    
    df5.ix[row_index, 'other_team_census'] = len(census.index)
    df5.ix[row_index, 'other_team_outboarders'] = len(outboarders)
    
    df5.ix[row_index, 'other_team_census_oasis_mean'] = census['OASIS'].mean()
    df5.ix[row_index, 'other_team_census_oasis_median'] = census['OASIS'].median()

    df5.ix[row_index, 'other_team_census_elixhauser_28day_mean'] = census['elixhauser_28day'].mean()
    df5.ix[row_index, 'other_team_census_elixhauser_28day_median'] = census['elixhauser_28day'].median()

    df5.ix[row_index, 'other_team_census_elixhauser_hospital_mean'] = census['elixhauser_hospital'].mean()
    df5.ix[row_index, 'other_team_census_elixhauser_hospital_median'] = census['elixhauser_hospital'].median()


# In[9]:

# Store df5v2b
# mimic_common.df_to_csv('df5v2b.csv', df5)

# Load df5v2 from stored CSV file (if we don't want to have to re-generate it)
# df5 = pd.read_csv('~/dev/data/mimic3_local_storage/df5v2b.csv', parse_dates=[8, 15, 20])


# In[10]:

# Load the Transfers table
msicu_transfers = mimic_common.load_table(mimic_schema.phitransfers_schema)
mimic_schema.transfers_schema.add_prefix(msicu_transfers)

# Time restrict
msicu_transfers = msicu_transfers[(msicu_transfers['transfers.intime'] > pd.Timestamp('20060401'))]
                        
# Location restrict to the MSICU
msicu_transfers = msicu_transfers[(msicu_transfers['transfers.curr_careunit'] == 'MSICU')]


# In[11]:

# Add the OASIS severity of illness scores to each row
oasis = pd.read_csv('~/chatto-transform/oasis.csv')
msicu_transfers = left_join(msicu_transfers, oasis[['ICUSTAY_ID', 'OASIS']], left_on='transfers.icustay_id', right_on='ICUSTAY_ID')
msicu_transfers = msicu_transfers.drop('ICUSTAY_ID', 1)

# Add the Elixhauser comorbidity scores to each row
elixhauser = pd.read_csv('~/chatto-transform/elixhauser.csv')
msicu_transfers = left_join(msicu_transfers, elixhauser, left_on='transfers.hadm_id', right_on='hadm_id')


# In[12]:

# Team census and outboarder count for the Med/Surg ICU (an ICU on the hospital's other campus)
df5['msicu_team_census'] = np.nan
# df5['msicu_team_outboarders'] = np.nan

# Average severity of illness measures for the ICU as a whole at a given time
df5['msicu_team_census_oasis_mean'] = np.nan
df5['msicu_team_census_oasis_median'] = np.nan

df5['msicu_team_census_elixhauser_28day_mean'] = np.nan
df5['msicu_team_census_elixhauser_28day_median'] = np.nan

df5['msicu_team_census_elixhauser_hospital_mean'] = np.nan
df5['msicu_team_census_elixhauser_hospital_median'] = np.nan

# For each MICU patient...
for row_index, row in df5.iterrows():
        
    # Determine how many patients (boarders + non-boarders) were assigned to the MICU Green team at that time
    census = msicu_transfers[(msicu_transfers['transfers.intime'] < row['transfers.intime']) & 
                             (msicu_transfers['transfers.outtime'] > row['transfers.intime'])]
    
    df5.ix[row_index, 'msicu_team_census'] = len(census.index)
    
    df5.ix[row_index, 'msicu_team_census_oasis_mean'] = census['OASIS'].mean()
    df5.ix[row_index, 'msicu_team_census_oasis_median'] = census['OASIS'].median()

    df5.ix[row_index, 'msicu_team_census_elixhauser_28day_mean'] = census['elixhauser_28day'].mean()
    df5.ix[row_index, 'msicu_team_census_elixhauser_28day_median'] = census['elixhauser_28day'].median()

    df5.ix[row_index, 'msicu_team_census_elixhauser_hospital_mean'] = census['elixhauser_hospital'].mean()
    df5.ix[row_index, 'msicu_team_census_elixhauser_hospital_median'] = census['elixhauser_hospital'].median()


# In[13]:

# Store df5v2c
# mimic_common.df_to_csv('df5v2c.csv', df5)

# Load df5v2c from stored CSV file (if we don't want to have to re-generate it)
# df5 = pd.read_csv('~/dev/data/mimic3_local_storage/df5v2c.csv', parse_dates=[8, 15, 20])


# In[14]:

# Add a column that estimates the EXPECTED number of outboarders
df5['expected_team_outboarders'] = np.nan
df5.expected_team_outboarders[(df5['micu_team'] == 0)] = (df5['team_census'] - (8 - df5['cc6d_boarder_count']))
df5.expected_team_outboarders[(df5['micu_team'] == 1)] = (df5['team_census'] - (8 - df5['cc7d_boarder_count']))

# Add a column that estimates the EXPECTED number of remaining beds in the nominal ICU of the team caring for the patient
df5['remaining_beds'] = np.nan
df5.remaining_beds[(df5['micu_team'] == 0)] = (8 - (df5['team_census'] - df5['team_outboarders']) - df5['cc6d_boarder_count'])
df5.remaining_beds[(df5['micu_team'] == 1)] = (8 - (df5['team_census'] - df5['team_outboarders']) - df5['cc7d_boarder_count'])


# In[15]:

# Add a column that estimates the EXPECTED number of outboarders for the OTHER MICU team 
# (the one NOT taking care of the patient)
df5['other_expected_team_outboarders'] = np.nan
df5.other_expected_team_outboarders[(df5['micu_team'] == 0)] = (df5['other_team_census'] - (8 - df5['cc7d_boarder_count']))
df5.other_expected_team_outboarders[(df5['micu_team'] == 1)] = (df5['other_team_census'] - (8 - df5['cc6d_boarder_count']))

# Add a column that estimates the EXPECTED number of remaining beds in the OTHER MICU
# (the one NOT taking care of the patient)
df5['other_remaining_beds'] = np.nan
df5.other_remaining_beds[(df5['micu_team'] == 0)] = (8 - (df5['other_team_census'] - df5['other_team_outboarders']) - df5['cc7d_boarder_count'])
df5.other_remaining_beds[(df5['micu_team'] == 1)] = (8 - (df5['other_team_census'] - df5['other_team_outboarders']) - df5['cc6d_boarder_count'])


# In[54]:

# Store df5v3
# mimic_common.df_to_csv('df5v3.csv', df5)

# Load df5v3 from stored CSV file (if we don't want to have to re-generate it)
df5 = pd.read_csv('~/dev/data/mimic3_local_storage/df5v3.csv', parse_dates=[8, 15, 20])


# In[55]:

# Join admissions, patients and icustays tables into 'mortality' dataframe
icustays = mimic_common.load_table(mimic_schema.icustays_schema)
mimic_schema.icustays_schema.add_prefix(icustays)

patients = mimic_common.load_table(mimic_schema.patients_schema)
mimic_schema.patients_schema.add_prefix(patients)

admissions = mimic_common.load_table(mimic_schema.admissions_schema)
mimic_schema.admissions_schema.add_prefix(admissions)

mortality = left_join(icustays[['icustays.subject_id', 'icustays.hadm_id', 'icustays.icustay_id', 'icustays.intime', 'icustays.outtime']], 
                      patients[['patients.subject_id', 'patients.gender', 'patients.dob', 'patients.dod', 'patients.dod_hosp', 'patients.dod_ssn']], 
                      left_on='icustays.subject_id', right_on='patients.subject_id')
mortality = left_join(mortality, 
                      admissions[['admissions.hadm_id', 'admissions.admittime', 'admissions.dischtime', 'admissions.deathtime',
                                'admissions.admission_type', 'admissions.admission_location', 'admissions.edregtime', 'admissions.edouttime', 'admissions.hospital_expire_flag',
                                'admissions.discharge_location', 'admissions.ethnicity']], 
                      left_on='icustays.hadm_id', right_on='admissions.hadm_id')

# Join the mortality dataframe to the rest of the data
df6 = left_join(df5, mortality, left_on='transfers.icustay_id', right_on='icustays.icustay_id')


# In[56]:

# Create a hospital_expire_flag and icustay_expire_flag.

# It is important to use 'intime' and 'outtime' from icustays table and NOT from transfers table because the
# former state the in/out times for the entire ICU stay (which may include multiple transfer events for patients
# that move from one ICU to another), whereas the latter state the in/out times per patient bed transfer onnly.

# NB: The icustay/hospital_expire_flag_MOD variables add 24 hours to the end of the time interval during which 
# the ICU and hospital, respectively, will have a death attributed to them. This serves several purposes:
# 1. Some deaths in the ICU may have DOD recorded as occurring several hours after ICU outtime
# 2. Some deaths in the hospital may have DOD recorded as occurring several hours after hospital discharge time
# 3. It is likely reasonable to attribute deaths occurring within 24 hours of a patient leaving an ICU or hospital
#    as being related to the management or transitions of care practices of the ICU or hospital respectively.

df6['hospital_expire_flag'] = 0
df6['hospital_expire_flag_mod'] = 0
df6['icustay_expire_flag'] = 0
df6['icustay_expire_flag_mod'] = 0

df6.hospital_expire_flag[(df6['patients.dod'] > df6['admissions.admittime']) &
                               (df6['patients.dod'] <= df6['admissions.dischtime'])] = 1
df6.icustay_expire_flag[(df6['patients.dod'] > df6['icustays.intime']) & 
                              (df6['patients.dod'] <= df6['icustays.outtime'])] = 1

df6.hospital_expire_flag_mod[(df6['patients.dod'] > df6['admissions.admittime']) &
                                   (df6['patients.dod'] <= (df6['admissions.dischtime'] + pd.Timedelta(hours=24)))] = 1
df6.icustay_expire_flag_mod[(df6['patients.dod'] > df6['icustays.intime']) & 
                                   (df6['patients.dod'] <= (df6['icustays.outtime'] + pd.Timedelta(hours=24)))] = 1


# In[57]:

# Calculate the MINIMUM number of days survived:
# NB: 20130601 is a ***PLACEHOLDER*** for the exact date that the Social Security Death Index was last queried
df6['days_survived'] = np.nan
df6.days_survived[(df6['patients.dod'].notnull())] = ((df6['patients.dod'] - df6['icustays.intime']).astype(int)/(1000000000*60*60*24))
df6.days_survived[(df6['patients.dod'].isnull())] = ((pd.Timestamp('20130601') - df6['transfers.intime']).astype(int)/(1000000000*60*60*24))

# Calculate days since ICU intime (i.e. number of days the patient theoretically could have survived)
# NB: 20130601 is a ***PLACEHOLDER*** for the exact date that the Social Security Death Index was last queried
df6['days_since_icu_admission'] = np.nan
df6.days_since_icu_admission = ((pd.Timestamp('20130601') - df6['transfers.intime']).astype(int)/(1000000000*60*60*24))


# In[58]:

# Calculate patient age (in years) at time of ICU admission
df6['icustay_admit_age'] = np.round((df6['icustays.intime'] - df6['patients.dob']).astype(int)/(1000000000*60*60*24*365.242))

# Convert gender from a 'M'/'F' designation to 0/1
df6['gender'] = np.nan
df6['gender'][df6['patients.gender'] == 'F'] = 0
df6['gender'][df6['patients.gender'] == 'M'] = 1
df6 = df6.drop('patients.gender', 1)


# In[59]:

# Exclude patients < 18 years of age
df6 = df6[df6['icustay_admit_age'] >= 18]


# In[22]:

# There are 1477 instances where MIMIC's admissions.hospital_expire_flag says 'Y'
# df6[['admissions.hospital_expire_flag', 'hospital_expire_flag', 'hospital_expire_flag_mod']][df6['admissions.hospital_expire_flag'] == 1]


# In[23]:

# There are 1405 instances where our custom hospital_expire_flag says 'Y'
# df6[['admissions.hospital_expire_flag', 'hospital_expire_flag', 'hospital_expire_flag_mod']][df6['hospital_expire_flag'] == 1]


# In[24]:

# There are 84 instances where MIMIC's admissions.hospital_expire_flag says 'Y' 
# when our custom hospital_expire_flag says 'N'
# df6[['admissions.hospital_expire_flag', 'hospital_expire_flag', 'hospital_expire_flag_mod']][(df6['admissions.hospital_expire_flag'] == 1) & (df6['hospital_expire_flag'] == 0)]


# In[25]:

# There are 12 instances where MIMIC's admissions.hospital_expire_flag says 'N' 
# when our custom hospital_expire_flag says 'Y'
# df6[['admissions.hospital_expire_flag', 'hospital_expire_flag', 'hospital_expire_flag_mod']][(df6['admissions.hospital_expire_flag'] == 0) & (df6['hospital_expire_flag'] == 1)]


# In[60]:

# Calculate days on ventilator
vent_days = care_value.VentilatorDays().load_transform()
vent_days['ventdays'] = vent_days['ventdays'].astype(int)/(1000000000*60*60*24)

# Join the vent_days table
df7 = left_join(df6, vent_days[['icustay_id', 'ventdays']], left_on='transfers.icustay_id', right_on='icustay_id')

# Set missing ventdays to 0
df7.ventdays[(df7['ventdays'].isnull())] = 0


# In[ ]:

# Calculate days on vasopressors
vasopressor_days = care_value.VasopressorDays().load_transform()

vasopressor_days['dobutamine_days'] = vasopressor_days['dobutamine_days'].astype(int)/(1000000000*60*60*24)
vasopressor_days['dopamine_days'] = vasopressor_days['dopamine_days'].astype(int)/(1000000000*60*60*24)
vasopressor_days['epinephrine_days'] = vasopressor_days['epinephrine_days'].astype(int)/(1000000000*60*60*24)
vasopressor_days['levophed_days'] = vasopressor_days['levophed_days'].astype(int)/(1000000000*60*60*24)
vasopressor_days['milrinone_days'] = vasopressor_days['milrinone_days'].astype(int)/(1000000000*60*60*24)
vasopressor_days['neosynephrine_days'] = vasopressor_days['neosynephrine_days'].astype(int)/(1000000000*60*60*24)
vasopressor_days['vasopressin_days'] = vasopressor_days['vasopressin_days'].astype(int)/(1000000000*60*60*24)
vasopressor_days['total_vasopressor_days'] = vasopressor_days['total_vasopressor_days'].astype(int)/(1000000000*60*60*24)

# Join the vasopressor_days table
df8 = left_join(df7, vasopressor_days, left_on='transfers.icustay_id', right_on='icustay_id')

# Set missing total_vasopressor_days to 0
df8.total_vasopressor_days[(df8['total_vasopressor_days'].isnull())] = 0


# In[61]:

# ONLY NEEDED WHEN BYPASSING VASOPRESSOR_DAYS CALCULATIONS
df8 = df7


# In[62]:

df9 = df8

# Calculate total LOS per ICU Stay (taking into account each ICU Stay may be made up of multiple rows
# representing different ICU beds a given patient occupied during a single ICU Stay.
df9['icustay_los_total'] = df9['transfers.los'].groupby(df9['transfers.icustay_id']).transform('sum')

# Calculate total LOS as a boarder
# df9['icustay_los_boarder'] = 0
df9['icustay_los_boarder'] = df9['transfers.los'][df9['boarder_status'] == 1].groupby(df9['transfers.icustay_id']).transform('sum')
df9['icustay_los_boarder'].fillna(0, inplace=True)

# Calculate the fraction of the ICU Stay spent as a boarder
df9['icustay_boarder_fraction'] = 0
df9['icustay_boarder_fraction'][df9['boarder_status'] == 1] = df9['icustay_los_boarder'] / df9['icustay_los_total']


# In[63]:

# # Determine the number of ICU free days (a LOS proxy used to account for the fact that death shortens LOS)
# df9['icu_free_days'] = np.nan
# df9.icu_free_days[(df9['days_survived'] < 28)] = 0
# df9.icu_free_days[(df9['days_survived'] >= 28)] = 28 - df9['icustay_los_total']
# df9.icu_free_days[(df9['icu_free_days'] < 0)] = 0

# df9['icu_free_days2'] = np.nan
# df9.icu_free_days2[(df9['icustay_expire_flag_mod'] == 1)] = 0
# df9.icu_free_days2[(df9['icustay_expire_flag_mod'] == 0)] = 28 - df9['icustay_los_total']
# df9.icu_free_days2[(df9['icu_free_days2'] < 0)] = 0

# df9['icu_free_days_21'] = np.nan
# df9.icu_free_days_21[(df9['days_survived'] < 21)] = 0
# df9.icu_free_days_21[(df9['days_survived'] >= 21)] = 21 - df9['icustay_los_total']
# df9.icu_free_days_21[(df9['icu_free_days_21'] < 0)] = 0

# df9['icu_free_days_21_2'] = np.nan
# df9.icu_free_days2[(df9['icustay_expire_flag_mod'] == 1)] = 0
# df9.icu_free_days2[(df9['icustay_expire_flag_mod'] == 0)] = 21 - df9['icustay_los_total']
# df9.icu_free_days2[(df9['icu_free_days_21_2'] < 0)] = 0


# In[64]:

# Calulate mean inboarder count (for both MICUs) over all of the different times a patient was transferred
# Consider changing to a weighted mean in the future, although the number of cases with >1 transfer is only ~16%
df9['avg_cc6d_boarder_count'] = df9['cc6d_boarder_count'].groupby(df9['transfers.icustay_id']).transform('mean')
df9['avg_cc7d_boarder_count'] = df9['cc7d_boarder_count'].groupby(df9['transfers.icustay_id']).transform('mean')

# Calculate mean team_census, team_outboarders, expected_team_outboarders and remaining_beds over all of the different times a patient was transferred.
# Consider changing to a weighted mean in the future, although the number of cases with >1 transfer is only ~16%
df9['avg_team_census'] = df9['team_census'].groupby(df9['transfers.icustay_id']).transform('mean')
df9['avg_team_outboarders'] = df9['team_outboarders'].groupby(df9['transfers.icustay_id']).transform('mean')
df9['avg_expected_team_outboarders'] = df9['expected_team_outboarders'].groupby(df9['transfers.icustay_id']).transform('mean')
df9['avg_remaining_beds'] = df9['remaining_beds'].groupby(df9['transfers.icustay_id']).transform('mean')

# Use our knowledge about which MICU team is caring for a given patient to
# decide which of the average inboarder counts to use as the instrumental variable
df9['avg_inboarder_count'] = np.nan
df9.avg_inboarder_count[(df9['micu_team'] == 0)] = df9['avg_cc6d_boarder_count']
df9.avg_inboarder_count[(df9['micu_team'] == 1)] = df9['avg_cc7d_boarder_count']


# In[65]:

# For the OTHER ICU (the one not taking care of the patient)...
# Calculate mean team_census, team_outboarders, expected_team_outboarders and remaining_beds over all of the different times a patient was transferred.
# Consider changing to a weighted mean in the future, although the number of cases with >1 transfer is only ~16%
df9['other_avg_team_census'] = df9['other_team_census'].groupby(df9['transfers.icustay_id']).transform('mean')
df9['other_avg_team_outboarders'] = df9['other_team_outboarders'].groupby(df9['transfers.icustay_id']).transform('mean')
df9['other_avg_expected_team_outboarders'] = df9['other_expected_team_outboarders'].groupby(df9['transfers.icustay_id']).transform('mean')
df9['other_avg_remaining_beds'] = df9['other_remaining_beds'].groupby(df9['transfers.icustay_id']).transform('mean')

# Determine the average inboarder count for the OTHER ICU (the one not taking care of the patient)
df9['other_avg_inboarder_count'] = np.nan
df9.other_avg_inboarder_count[(df9['micu_team'] == 0)] = df9['avg_cc7d_boarder_count']
df9.other_avg_inboarder_count[(df9['micu_team'] == 1)] = df9['avg_cc6d_boarder_count']


# In[66]:

# Store df9
# mimic_common.df_to_csv('df9.csv', df9)

# Load df9 from stored CSV file (if we don't want to have to re-generate it)
df9 = pd.read_csv('~/dev/data/mimic3_local_storage/df9.csv', parse_dates=[8, 15, 20, 112, 113, 115, 116, 117, 118, 120, 121, 122, 125, 126])


# In[80]:

# Generate a count of how many times a patient was transferred during each ICU stay
d = df9.groupby('transfers.icustay_id')['transfers.row_id'].nunique()
x = pd.DataFrame(data=d, index=d.index)
x.rename(columns={"transfers.row_id": "transfer_count_this_icustay"}, inplace=True)
x.reset_index(level=0, inplace=True)

df10 = left_join(df9, x, left_on='transfers.icustay_id', right_on='transfers.icustay_id')


# In[81]:

# Generate a count of how many ICU stays a patient has had during each admission
d = df10.groupby('transfers.hadm_id')['transfers.icustay_id'].nunique()
x = pd.DataFrame(data=d, index=d.index)
x.rename(columns={"transfers.icustay_id": "icustay_count_this_admission"}, inplace=True)
x.reset_index(level=0, inplace=True)

df10 = left_join(df10, x, left_on='transfers.hadm_id', right_on='transfers.hadm_id')


# In[83]:

# Generate a count of how many prior ICU stays a patient has had during their current and prior hospital admissions combined
d = df10.groupby('transfers.subject_id')['transfers.icustay_id'].nunique()
x = pd.DataFrame(data=d, index=d.index)
x.rename(columns={"transfers.icustay_id": "icustay_count_this_patient"}, inplace=True)
x.reset_index(level=0, inplace=True)

df10 = left_join(df10, x, left_on='transfers.subject_id', right_on='transfers.subject_id')


# In[84]:

# Generate a count of how many prior admissions a patient has had.
d = df10.groupby('transfers.subject_id')['transfers.hadm_id'].nunique()
x = pd.DataFrame(data=d, index=d.index)
x.rename(columns={"transfers.hadm_id": "admissions_count_this_patient"}, inplace=True)
x.reset_index(level=0, inplace=True)

df10 = left_join(df10, x, left_on='transfers.subject_id', right_on='transfers.subject_id')


# In[86]:

# Generate the following variables...
# - icustay_boarder_initial (this will not be 'correct' until after we drop all non-initial transfers for each ICU stay - occurs later)
# - icustay_boarder_ever (this will be 'correct' immediately)

df10['icustay_boarder'] = df10['boarder_status']

aux = df10.groupby(['transfers.icustay_id'], sort=False)['icustay_boarder'].max()

aux2 = pd.DataFrame(data=aux, index=aux.index)
aux2.reset_index(level=0, inplace=True)

df10b = pd.merge(df10, aux2, 
                 on='transfers.icustay_id',
                 suffixes=('_initial', '_ever'))


# In[88]:

# Make sure the value of icustay_los_boarder is accurate for all rows that make up a given ICU stay
# (prior to this cell, only those rows where boarder_status == 1 have a valid value for icustay_los_boarder)

aux = df10.groupby(['transfers.icustay_id'], sort=False)['icustay_los_boarder'].max()

aux2 = pd.DataFrame(data=aux, index=aux.index)
aux2.reset_index(level=0, inplace=True)

df10c = pd.merge(df10b, aux2, 
                 on='transfers.icustay_id',
                 suffixes=('_x', '_y'))

df10c['icustay_los_boarder'] = df10c['icustay_los_boarder_y']
df10c.drop('icustay_los_boarder_x', 1)
df10c.drop('icustay_los_boarder_y', 1)


# In[89]:

# Make sure the value of icustay_boarder_fraction is accurate for all rows that make up a given ICU stay
# (prior to this cell, only those rows where boarder_status == 1 have a valid value for icustay_boarder_fraction)

aux = df10.groupby(['transfers.icustay_id'], sort=False)['icustay_boarder_fraction'].max()

aux2 = pd.DataFrame(data=aux, index=aux.index)
aux2.reset_index(level=0, inplace=True)

df10d = pd.merge(df10c, aux2, 
                 on='transfers.icustay_id',
                 suffixes=('_x', '_y'))

df10d['icustay_boarder_fraction'] = df10d['icustay_boarder_fraction_y']
df10d.drop('icustay_boarder_fraction_x', 1)
df10d.drop('icustay_boarder_fraction_y', 1)


# In[2]:

# Store df10d
# mimic_common.df_to_csv('df10d.csv', df10d)

# Load df10d from stored CSV file (if we don't want to have to re-generate it)
df10d = pd.read_csv('~/dev/data/mimic3_local_storage/df10d.csv', parse_dates=[8, 15, 20, 112, 113, 115, 116, 117, 118, 120, 121, 122, 125, 126])


# In[3]:

# Somewhat superfluous, but for clarity we will create new variables with names that remind us
# that they contain values pertaining to the START of each ICU stay

df11 = df10d

df11['initial_team_census'] = df11['team_census']

df11['initial_inboarder_count'] = np.nan
df11.initial_inboarder_count[(df11['micu_team'] == 0)] = df11['cc6d_boarder_count']
df11.initial_inboarder_count[(df11['micu_team'] == 1)] = df11['cc7d_boarder_count']

df11['initial_team_outboarders'] = df11['team_outboarders']
df11['initial_expected_team_outboarders'] = df11['expected_team_outboarders']
df11['initial_remaining_beds'] = df11['remaining_beds']


# In[4]:

# Same as above, but for the OTHER ICU (the one not taking care of the patient)

df11['other_initial_team_census'] = df11['other_team_census']

df11['other_initial_inboarder_count'] = np.nan
df11.other_initial_inboarder_count[(df11['micu_team'] == 0)] = df11['cc7d_boarder_count']
df11.other_initial_inboarder_count[(df11['micu_team'] == 1)] = df11['cc6d_boarder_count']

df11['other_initial_team_outboarders'] = df11['other_team_outboarders']
df11['other_initial_expected_team_outboarders'] = df11['other_expected_team_outboarders']
df11['other_initial_remaining_beds'] = df11['other_remaining_beds']


# In[5]:

# Same as above, but for the MSICU (not taking care of the patient either)
df11['msicu_initial_team_census'] = df11['msicu_team_census']
df11['msicu_initial_remaining_beds'] = (12 - df11['msicu_initial_team_census'])


# In[7]:

# Generate different combined remaining beds measures
df11['west_initial_remaining_beds'] = df11['initial_remaining_beds'] + df11['other_initial_remaining_beds']
df11['eastwest_initial_remaining_beds'] = df11['initial_remaining_beds'] + df11['other_initial_remaining_beds'] + df11['msicu_initial_remaining_beds']


# In[8]:

# Reclassify rows as NON-boarders if icustay_los_boarder < 1 hour (51 rows)
# -- This helps to eliminate cases where boarders are assigned non-MICU beds without spending a meaningful (or any)
# -- amount of time in it. e.g. see rows in TRANSFERS table associated with ICUSTAY_ID 200173
df11['boarder_1hr'] = 0
df11.boarder_1hr[(df11['icustay_los_boarder'] >= 1.0)] = 1


# In[14]:

# Generate variables for the year and month of the transfer
df11['transfers.intime_year'] = df11['transfers.intime'].map(lambda x: x.year)
df11['transfers.intime_month'] = df11['transfers.intime'].map(lambda x: x.month)

# Generate a variable to indicate the number of weeks prior to December 7, 2012
# (the day after the last transfer in the database)
df11['transfers.weeks_from_db_end'] = (pd.Timestamp('20121207') - df11['transfers.intime']).astype(int)/(1000000000*60*60*24*7)


# In[16]:

# Add ED times for each admission
edtimes = pd.read_csv('~/Downloads/data/ADMISSIONS.csv', 
                    usecols=['HADM_ID', 'EDREGTIME', 'EDOUTTIME'], 
                    parse_dates=[1, 2])

edtimes['HADM_ID'] = edtimes['HADM_ID'].astype(int)

df13a = left_join(df11, edtimes, 
                  left_on='transfers.hadm_id',
                  right_on='HADM_ID')


# In[17]:

# Calculate the time spent in the ED in hours for each patient in our study population
df13a['ED_TIME'] = (df13a['EDOUTTIME'] - df13a['EDREGTIME']).astype(int)/(1000000000*60*60)
df13a.ED_TIME[df13a['EDREGTIME'].isnull()] = np.nan


# In[18]:

# Demonstrating that almost all rows with null ED time data are transfers from other hospitals
# df13a[df13a['ED_TIME'].isnull()][['admissions.admission_location']] # 1,015 rows
# df13a[(df13a['ED_TIME'].isnull()) & (df13a['admissions.admission_location'] == 'TRANSFER FROM HOSP/EXTRAM')][['admissions.admission_location']] # 863 rows
# df13a[(df13a['ED_TIME'].isnull()) & (df13a['admissions.admission_location'] == 'CLINIC REFERRAL/PREMATURE')][['admissions.admission_location']] # 70 rows


# In[19]:

# Load the Transfers table
transfers_ed = mimic_common.load_table(mimic_schema.phitransfers_schema)

# Merge with the ED time data
transfers_ed = left_join(transfers_ed, edtimes,
               left_on='hadm_id',
               right_on='HADM_ID')


# In[20]:

# Narrow the transfers_ed dataframe to only look at...
# - non-null ED times
# - the relevant time period (add 1 month to our prior definition)
# - 'admit' events to ICUs (not to wards)

transfers_ed = transfers_ed[transfers_ed['EDREGTIME'].notnull()]
transfers_ed = transfers_ed[transfers_ed['intime'] > pd.Timestamp('20060301')]
transfers_ed = transfers_ed[(transfers_ed['eventtype'] == 'admit') & (transfers_ed['icustay_id'].notnull())]


# In[21]:

# Calculate the duration of ED stay for each patient in transfers_ed
# NB: At this point, transfers_ed contains both patients in and outside of our study population
transfers_ed['ED_TIME'] = (transfers_ed['EDOUTTIME'] - transfers_ed['EDREGTIME']).astype(int)/(1000000000*60*60)
transfers_ed.ED_TIME[transfers_ed['EDREGTIME'].isnull()] = np.nan


# In[22]:

# For each patient in our study population, find the average ED wait time for all patients
# who needed an ICU bed in the 24 hours prior to the given patient's time of ICU intime

df13b = df13a

df13b['MEAN_ED_TIME_24HRS'] = np.nan
df13b['MEDIAN_ED_TIME_24HRS'] = np.nan
df13b['COUNT_ED_ICU_ADMITS_24HRS'] = np.nan # Number of admits from ED to any ICU

df13b['COUNT_ED_CC6D_ADMITS_24HRS'] = np.nan # Number of admits from ED to CC6D (under care of ANY service)
df13b['COUNT_ED_CC7D_ADMITS_24HRS'] = np.nan # Number of admits from ED to CC7D (under care of ANY service)
df13b['COUNT_ED_CCXD_ADMITS_24HRS'] = np.nan # Number of admits from ED to EITHER CC6D or CC7D (under care of ANY service)

df13b['COUNT_ED_MICU_ADMITS_24HRS_COMBINED'] = np.nan # Number of admits from ED to EITHER MICU-Orange or -Green TEAM
df13b['COUNT_ED_MICU_BOARDER_ADMITS_24HRS_COMBINED'] = np.nan # Number of admits from ED to EITHER MICU-Orange or MICU-Green TEAM as a boarder


micu_icustay_ids = df13b.groupby('transfers.icustay_id').size()

# for row_index, row in df13b.head(100).iterrows():
for row_index, row in df13b.iterrows():

    earlier_ed_admits = transfers_ed[(transfers_ed['intime'] < row['transfers.intime']) &
                                    ((transfers_ed['intime'] + pd.Timedelta(hours=24)) > row['transfers.intime']) &
                                    (transfers_ed['subject_id'] != row['transfers.subject_id'])]
    
    earlier_ed_cc6d_admits = earlier_ed_admits[earlier_ed_admits['curr_ward'] == 'CC6D']
    earlier_ed_cc7d_admits = earlier_ed_admits[earlier_ed_admits['curr_ward'] == 'CC7D']
    earlier_ed_ccxd_admits = pd.concat([earlier_ed_cc6d_admits, earlier_ed_cc7d_admits])
    
    earlier_ed_micu_admits = earlier_ed_admits[earlier_ed_admits['icustay_id'].isin(micu_icustay_ids.index)]
    earlier_ed_micu_boarder_admits = earlier_ed_micu_admits[(earlier_ed_micu_admits['curr_ward'] != 'CC6D') &
                                                            (earlier_ed_micu_admits['curr_ward'] != 'CC7D')]
    
    
    df13b.ix[row_index, 'MEAN_ED_TIME_24HRS'] = earlier_ed_admits['ED_TIME'].mean()
    df13b.ix[row_index, 'MEDIAN_ED_TIME_24HRS'] = earlier_ed_admits['ED_TIME'].median()
    df13b.ix[row_index, 'COUNT_ED_ICU_ADMITS_24HRS'] = len(earlier_ed_admits.index)

    df13b.ix[row_index, 'COUNT_ED_CC6D_ADMITS_24HRS'] = len(earlier_ed_cc6d_admits.index)
    df13b.ix[row_index, 'COUNT_ED_CC7D_ADMITS_24HRS'] = len(earlier_ed_cc7d_admits.index)
    df13b.ix[row_index, 'COUNT_ED_CCXD_ADMITS_24HRS'] = len(earlier_ed_ccxd_admits.index)
    
    df13b.ix[row_index, 'COUNT_ED_MICU_ADMITS_24HRS_COMBINED'] = len(earlier_ed_micu_admits.index)
    df13b.ix[row_index, 'COUNT_ED_MICU_BOARDER_ADMITS_24HRS_COMBINED'] = len(earlier_ed_micu_boarder_admits.index)


# In[23]:

# For each patient in our study population, find the average ED wait time for all patients
# who needed an ICU bed in the 12 hours prior to the given patient's time of ICU intime

df13b['MEAN_ED_TIME_12HRS'] = np.nan
df13b['MEDIAN_ED_TIME_12HRS'] = np.nan
df13b['COUNT_ED_ICU_ADMITS_12HRS'] = np.nan # Number of admits from ED to any ICU

df13b['COUNT_ED_CC6D_ADMITS_12HRS'] = np.nan # Number of admits from ED to CC6D (under care of ANY service)
df13b['COUNT_ED_CC7D_ADMITS_12HRS'] = np.nan # Number of admits from ED to CC7D (under care of ANY service)
df13b['COUNT_ED_CCXD_ADMITS_12HRS'] = np.nan # Number of admits from ED to EITHER CC6D or CC7D (under care of ANY service)

df13b['COUNT_ED_MICU_ADMITS_12HRS_COMBINED'] = np.nan # Number of admits from ED to EITHER MICU-Orange or -Green TEAM
df13b['COUNT_ED_MICU_BOARDER_ADMITS_12HRS_COMBINED'] = np.nan # Number of admits from ED to EITHER MICU-Orange or MICU-Green TEAM as a boarder

# df13b['COUNT_ED_MICU_ADMITS_12HRS_ORANGE'] = np.nan # Number of admits from ED to MICU-Orange TEAM
# df13b['COUNT_ED_MICU_ADMITS_12HRS_GREEN'] = np.nan # Number of admits from ED to MICU-Green TEAM


micu_icustay_ids = df13b.groupby('transfers.icustay_id').size()

# for row_index, row in df13b.head(100).iterrows():
for row_index, row in df13b.iterrows():

    earlier_ed_admits = transfers_ed[(transfers_ed['intime'] < row['transfers.intime']) &
                                    ((transfers_ed['intime'] + pd.Timedelta(hours=12)) > row['transfers.intime']) &
                                    (transfers_ed['subject_id'] != row['transfers.subject_id'])]
    
    earlier_ed_cc6d_admits = earlier_ed_admits[earlier_ed_admits['curr_ward'] == 'CC6D']
    earlier_ed_cc7d_admits = earlier_ed_admits[earlier_ed_admits['curr_ward'] == 'CC7D']
    earlier_ed_ccxd_admits = pd.concat([earlier_ed_cc6d_admits, earlier_ed_cc7d_admits])
    
    earlier_ed_micu_admits = earlier_ed_admits[earlier_ed_admits['icustay_id'].isin(micu_icustay_ids.index)]
    earlier_ed_micu_boarder_admits = earlier_ed_micu_admits[(earlier_ed_micu_admits['curr_ward'] != 'CC6D') &
                                                            (earlier_ed_micu_admits['curr_ward'] != 'CC7D')]
    
    
    df13b.ix[row_index, 'MEAN_ED_TIME_12HRS'] = earlier_ed_admits['ED_TIME'].mean()
    df13b.ix[row_index, 'MEDIAN_ED_TIME_12HRS'] = earlier_ed_admits['ED_TIME'].median()
    df13b.ix[row_index, 'COUNT_ED_ICU_ADMITS_12HRS'] = len(earlier_ed_admits.index)

    df13b.ix[row_index, 'COUNT_ED_CC6D_ADMITS_12HRS'] = len(earlier_ed_cc6d_admits.index)
    df13b.ix[row_index, 'COUNT_ED_CC7D_ADMITS_12HRS'] = len(earlier_ed_cc7d_admits.index)
    df13b.ix[row_index, 'COUNT_ED_CCXD_ADMITS_12HRS'] = len(earlier_ed_ccxd_admits.index)
    
    df13b.ix[row_index, 'COUNT_ED_MICU_ADMITS_12HRS_COMBINED'] = len(earlier_ed_micu_admits.index)
    df13b.ix[row_index, 'COUNT_ED_MICU_BOARDER_ADMITS_12HRS_COMBINED'] = len(earlier_ed_micu_boarder_admits.index)


# In[24]:

# For each patient in our study population, find the average ED wait time for all patients
# who needed an ICU bed in the 12 hours prior to the given patient's time of ICU intime

df13b['MEAN_ED_TIME_6HRS'] = np.nan
df13b['MEDIAN_ED_TIME_6HRS'] = np.nan
df13b['COUNT_ED_ICU_ADMITS_6HRS'] = np.nan # Number of admits from ED to any ICU

df13b['COUNT_ED_CC6D_ADMITS_6HRS'] = np.nan # Number of admits from ED to CC6D (under care of ANY service)
df13b['COUNT_ED_CC7D_ADMITS_6HRS'] = np.nan # Number of admits from ED to CC7D (under care of ANY service)
df13b['COUNT_ED_CCXD_ADMITS_6HRS'] = np.nan # Number of admits from ED to EITHER CC6D or CC7D (under care of ANY service)

df13b['COUNT_ED_MICU_ADMITS_6HRS_COMBINED'] = np.nan # Number of admits from ED to EITHER MICU-Orange or -Green TEAM
df13b['COUNT_ED_MICU_BOARDER_ADMITS_6HRS_COMBINED'] = np.nan # Number of admits from ED to EITHER MICU-Orange or MICU-Green TEAM as a boarder

# df13b['COUNT_ED_MICU_ADMITS_12HRS_ORANGE'] = np.nan # Number of admits from ED to MICU-Orange TEAM
# df13b['COUNT_ED_MICU_ADMITS_12HRS_GREEN'] = np.nan # Number of admits from ED to MICU-Green TEAM


micu_icustay_ids = df13b.groupby('transfers.icustay_id').size()

# for row_index, row in df13b.head(100).iterrows():
for row_index, row in df13b.iterrows():

    earlier_ed_admits = transfers_ed[(transfers_ed['intime'] < row['transfers.intime']) &
                                    ((transfers_ed['intime'] + pd.Timedelta(hours=6)) > row['transfers.intime']) &
                                    (transfers_ed['subject_id'] != row['transfers.subject_id'])]
    
    earlier_ed_cc6d_admits = earlier_ed_admits[earlier_ed_admits['curr_ward'] == 'CC6D']
    earlier_ed_cc7d_admits = earlier_ed_admits[earlier_ed_admits['curr_ward'] == 'CC7D']
    earlier_ed_ccxd_admits = pd.concat([earlier_ed_cc6d_admits, earlier_ed_cc7d_admits])
    
    earlier_ed_micu_admits = earlier_ed_admits[earlier_ed_admits['icustay_id'].isin(micu_icustay_ids.index)]
    earlier_ed_micu_boarder_admits = earlier_ed_micu_admits[(earlier_ed_micu_admits['curr_ward'] != 'CC6D') &
                                                            (earlier_ed_micu_admits['curr_ward'] != 'CC7D')]
    
    
    df13b.ix[row_index, 'MEAN_ED_TIME_6HRS'] = earlier_ed_admits['ED_TIME'].mean()
    df13b.ix[row_index, 'MEDIAN_ED_TIME_6HRS'] = earlier_ed_admits['ED_TIME'].median()
    df13b.ix[row_index, 'COUNT_ED_ICU_ADMITS_6HRS'] = len(earlier_ed_admits.index)

    df13b.ix[row_index, 'COUNT_ED_CC6D_ADMITS_6HRS'] = len(earlier_ed_cc6d_admits.index)
    df13b.ix[row_index, 'COUNT_ED_CC7D_ADMITS_6HRS'] = len(earlier_ed_cc7d_admits.index)
    df13b.ix[row_index, 'COUNT_ED_CCXD_ADMITS_6HRS'] = len(earlier_ed_ccxd_admits.index)
    
    df13b.ix[row_index, 'COUNT_ED_MICU_ADMITS_6HRS_COMBINED'] = len(earlier_ed_micu_admits.index)
    df13b.ix[row_index, 'COUNT_ED_MICU_BOARDER_ADMITS_6HRS_COMBINED'] = len(earlier_ed_micu_boarder_admits.index)


# In[126]:

# Store df13b
# mimic_common.df_to_csv('df13bi.csv', df13b)

# Load df13b from stored CSV file (if we don't want to have to re-generate it)
df13b = pd.read_csv('~/dev/data/mimic3_local_storage/df13bi.csv', parse_dates=[8, 15, 20, 112, 113, 115, 116, 117, 118, 120, 121, 122, 125, 126])


# In[127]:

# TO BE MOVED HIGHER UP
# Determine the number of ICU free days (a LOS proxy used to account for the fact that death shortens LOS)
df13b['icu_free_days_28'] = np.nan
df13b.icu_free_days_28[(df13b['days_survived'] < 28)] = 0
df13b.icu_free_days_28[(df13b['days_survived'] >= 28)] = 28 - (df13b['icustay_los_total'].astype(int)/(24))
df13b.icu_free_days_28[(df13b['icu_free_days_28'] < 0)] = 0

df13b['icu_free_days_21'] = np.nan
df13b.icu_free_days_21[(df13b['days_survived'] < 21)] = 0
df13b.icu_free_days_21[(df13b['days_survived'] >= 21)] = 21 - (df13b['icustay_los_total'].astype(int)/(24))
df13b.icu_free_days_21[(df13b['icu_free_days_21'] < 0)] = 0

df13b['icu_free_days_35'] = np.nan
df13b.icu_free_days_35[(df13b['days_survived'] < 35)] = 0
df13b.icu_free_days_35[(df13b['days_survived'] >= 35)] = 35 - (df13b['icustay_los_total'].astype(int)/(24))
df13b.icu_free_days_35[(df13b['icu_free_days_35'] < 0)] = 0


# In[128]:

# TO BE MOVED HIGHER UP
# Generate different combined remaining beds measures
df13b['west_initial_team_census'] = df13b['initial_team_census'] + df13b['other_initial_team_census']
df13b['eastwest_initial_team_census'] = df13b['initial_team_census'] + df13b['other_initial_team_census'] + df13b['msicu_initial_team_census']


# In[129]:

# Calculate LOS in days prior to ICU stay
df13b['los_days_prior_to_icu'] = (df13b['icustays.intime'] - df13b['admissions.admittime']).astype(int)/(1000000000*60*60*24)


# In[ ]:

notes = pd.read_csv('~/Downloads/MIMIC/data/NOTEEVENTS_DATA_TABLE.csv', 
                    usecols=['ROW_ID', 'RECORD_ID', 'SUBJECT_ID', 'HADM_ID', 'CHARTDATE', 'CATEGORY', 'DESCRIPTION'], 
                    parse_dates=[4])


# In[ ]:

ecg = notes[(notes['CATEGORY'] == 'ECG')]
echo = notes[(notes['CATEGORY'] == 'Echo')]

radiology = notes[(notes['CATEGORY'] == 'Radiology')]
cxr = radiology[(radiology['DESCRIPTION'] == 'CHEST (PORTABLE AP)') |
                (radiology['DESCRIPTION'] == 'CHEST (PA & LAT)') |
                (radiology['DESCRIPTION'] == 'CHEST (PRE-OP PA & LAT)') |
                (radiology['DESCRIPTION'] == 'CHEST (SINGLE VIEW)') ]

# cxr_by_hadm = cxr.groupby('HADM_ID').size()
# ecg_by_hadm = ecg.groupby('HADM_ID').size()
# echo_by_hadm = echo.groupby('HADM_ID').size()


# In[ ]:

# Store ecg, echo, cxr, and radiology dataframes
mimic_common.df_to_csv('ecg.csv', ecg)
mimic_common.df_to_csv('echo.csv', echo)
mimic_common.df_to_csv('cxr.csv', cxr)
mimic_common.df_to_csv('radiology.csv', radiology)

# Load df14 from stored CSV file (if we don't want to have to re-generate it)
# ecg = pd.read_csv('~/dev/data/mimic3_local_storage/ecg.csv', parse_dates=[4])
# echo = pd.read_csv('~/dev/data/mimic3_local_storage/echo.csv', parse_dates=[4])
# cxr = pd.read_csv('~/dev/data/mimic3_local_storage/cxr.csv', parse_dates=[4])
# radiology = pd.read_csv('~/dev/data/mimic3_local_storage/radiology.csv', parse_dates=[4])


# In[ ]:

df14 = df13

# For each patient under the care of the MICU-Orange or MICU-Green service, calculate the number of
# chest X-rays, echocardiograms, and ECGs ordered for each patient during their ICU stay
df14['cxr_count'] = np.nan
df14['echo_count'] = np.nan
df14['ecg_count'] = np.nan
df14['total_orders_count'] = np.nan

for row_index, row in df14.iterrows():
    
    # Since CHARTDATE only records the DAY (does not include HH:MM:SS) of a study,
    # we will add 24 hours to CHARTDATE before comparing it to transfers.intime
    
    cxr_count = cxr[(cxr['SUBJECT_ID'] == row['transfers.subject_id']) & 
                    ((cxr['CHARTDATE'] + pd.Timedelta(hours=24)) > row['icustays.intime']) & 
                    (cxr['CHARTDATE'] < row['icustays.outtime'])]
    
    echo_count = echo[(echo['SUBJECT_ID'] == row['transfers.subject_id']) & 
                      ((echo['CHARTDATE'] + pd.Timedelta(hours=24)) > row['icustays.intime']) & 
                       (echo['CHARTDATE'] < row['icustays.outtime'])]
    
    ecg_count = ecg[(ecg['SUBJECT_ID'] == row['transfers.subject_id']) & 
                    ((ecg['CHARTDATE'] + pd.Timedelta(hours=24)) > row['icustays.intime']) & 
                    (ecg['CHARTDATE'] < row['icustays.outtime'])]
    
    # Create a new dataframe by concatenating the cxr, echo and ecg dataframes
    total_orders_count = pd.concat([cxr_count, echo_count, ecg_count])
    
    # Store the counts in their respective columns
    df14.ix[row_index, 'cxr_count'] = len(cxr_count.index)
    df14.ix[row_index, 'echo_count'] = len(echo_count.index)
    df14.ix[row_index, 'ecg_count'] = len(ecg_count.index)
    df14.ix[row_index, 'total_orders_count'] = len(total_orders_count.index)


# In[ ]:

# Store df14 (pc for 'post-change' with respect to change to using 'initial_' variables)
# mimic_common.df_to_csv('df14_pc.csv', df14)

# Load df14 from stored CSV file (if we don't want to have to re-generate it)
# df14 = pd.read_csv('~/dev/data/mimic3_local_storage/df14_pc.csv', parse_dates=[8, 15, 20, 39, 40, 42, 43, 44, 45, 47, 48, 49, 52, 53])
# df14 = pd.read_csv('~/dev/data/mimic3_local_storage/df14_pc.csv', parse_dates=[8, 15, 20, 112, 113, 115, 116, 117, 118, 120, 121, 122, 125, 126])


# In[130]:

# DO NOT NEED UNLESS SKIPPING THE RADIOLOGY DATA MERGE
df14 = df13b


# In[131]:

# Add the primary ICD-9-CM diagnosis for each admission

# Load the ICD diagnoses table
diagnoses = mimic_common.load_table(mimic_schema.diagnoses_icd_schema)
mimic_schema.diagnoses_icd_schema.add_prefix(diagnoses)

# Filter the diagnoses dataframe, keeping only those rows where SEQ_NUM == 1 (i.e. primary diagnoses)
primary_diagnoses = diagnoses[diagnoses['diagnoses_icd.seq_num'] == 1]

# Merge the primary diagnoses into our main data
df15 = left_join(df14, primary_diagnoses, left_on='transfers.hadm_id', right_on='diagnoses_icd.hadm_id')

# Convert the diagnoses from integers to strings
df15['diagnoses_icd.icd9_code'] = df15['diagnoses_icd.icd9_code'].astype(str)


# In[135]:

# Determine the AHRQ Clinical Classification System (CCS) categories for each diagnosis

# New dataframe from CSV file containing ICD-9-CM to CCS mapping
ccs = pd.read_csv('~/chatto-transform/ccs_dx.csv')

# Left join on the two dataframes
df16 = left_join(df15, ccs, left_on='diagnoses_icd.icd9_code', right_on='icd_code')


# In[133]:

# 71% of all cases are admissions from the ED

# df16
# df16[(df16['transfers.eventtype'] == 'admit')]
# df16[(df16['transfers.eventtype'] == 'transfer')]


# In[134]:

# DO NOT NEED UNLESS SKIPPING THE ICD-9 DIAGNOSIS MERGE
df16 = df14


# In[136]:

# The data is now in a format such that...

# 1. ICU stays occupying multiple rows but with no time as a boarder are identical
# - Therefore all but the first grouped row should be deleted (after sorting by transfers.intime ASC)

# 2. ICU stays occupying multiple rows with all time spent as a boarder are identical
# - Therefore all but the first grouped row should be deleted (after sorting by transfers.intime ASC)

# 3. ICU stays occupying multiple rows that have SOME but NOT ALL time as a boarder are identical
# - Therefore all but the first grouped row should be deleted (after sorting by transfers.intime ASC)


# NB: Identical refers to the following fields...
# icustay_boarder_ever
# icustay_los_boarder
# icustay_boarder_fraction
# icustay_los_total
# avg_team_census
# avg_team_outboarders
# avg_expected_team_outboarders
# avg_inboarder_count
# avg_remaining_beds

# ... NOT the following fields (which all refer to the values at each row's transfer.intime)...
# team_census
# team_outboarders
# cc6d_boarder_count
# cc7d_boarder_count
# transfers.curr_careunit

# ... and NOT the following field either (the value of which will not be 'correct' until row dropping occurs)
# icustay_boarder_initial


# Sort rows first by transfers.icustay_id ASCENDING, then by transfers.intime ASCENDING
df17 = df16.sort(['transfers.icustay_id', 'transfers.intime'], ascending=[1, 1])

# Delete duplicate rows based on transfers.icustay_id. By default, the first row will be preserved.
df17 = df17.drop_duplicates(subset='transfers.icustay_id')


# In[137]:

# Now we want to only keep the first ICU admission for each patient to ensure our observations are independent

# Sort rows first by transfers.subject_id ASCENDING, then by transfers.intime ASCENDING (*** EARLIEST *** FIRST)
df17 = df17.sort(['transfers.subject_id', 'transfers.intime'], ascending=[1, 1])

# Sort rows first by transfers.subject_id ASCENDING, then by transfers.intime DESCENDING (*** LATEST *** FIRST)
# df17 = df17.sort(['transfers.subject_id', 'transfers.intime'], ascending=[1, 0])

# Delete duplicate rows based on transfers.subject_id
# By default, the first row (the earliest ICU stay) will be preserved
df17 = df17.drop_duplicates(subset='transfers.subject_id')


# In[138]:

# Preview the data
df18 = df17[['transfers.subject_id', 'transfers.hadm_id', 'transfers.icustay_id', 'transfers.eventtype',
             'transfers.intime_year', 'transfers.intime_month', 'ED_TIME',

             'MEAN_ED_TIME_24HRS', 'MEDIAN_ED_TIME_24HRS', 'COUNT_ED_ICU_ADMITS_24HRS',
             'COUNT_ED_CC6D_ADMITS_24HRS', 'COUNT_ED_CC7D_ADMITS_24HRS',
             'COUNT_ED_CCXD_ADMITS_24HRS',
             'COUNT_ED_MICU_ADMITS_24HRS_COMBINED',
             'COUNT_ED_MICU_BOARDER_ADMITS_24HRS_COMBINED',
             
             'MEAN_ED_TIME_12HRS', 'MEDIAN_ED_TIME_12HRS', 'COUNT_ED_ICU_ADMITS_12HRS',
             'COUNT_ED_CC6D_ADMITS_12HRS', 'COUNT_ED_CC7D_ADMITS_12HRS',
             'COUNT_ED_CCXD_ADMITS_12HRS',
             'COUNT_ED_MICU_ADMITS_12HRS_COMBINED',
             'COUNT_ED_MICU_BOARDER_ADMITS_12HRS_COMBINED',
             
             'MEAN_ED_TIME_6HRS', 'MEDIAN_ED_TIME_6HRS', 'COUNT_ED_ICU_ADMITS_6HRS',
             'COUNT_ED_CC6D_ADMITS_6HRS', 'COUNT_ED_CC7D_ADMITS_6HRS',
             'COUNT_ED_CCXD_ADMITS_6HRS',
             'COUNT_ED_MICU_ADMITS_6HRS_COMBINED',
             'COUNT_ED_MICU_BOARDER_ADMITS_6HRS_COMBINED',
             
             'team_census_same_room', 
             
             'team_census_oasis_mean_combined',
             'team_census_oasis_median_combined', 'team_census_oasis_mean_boarders',
             'team_census_oasis_median_boarders', 'team_census_oasis_mean_nonboarders', 
             'team_census_oasis_median_nonboarders', 'team_census_oasis_mean_same_room', 
             'team_census_oasis_median_same_room',
             
             'team_census_elixhauser_28day_mean_combined', 
             'team_census_elixhauser_28day_median_combined', 'team_census_elixhauser_28day_mean_boarders', 
             'team_census_elixhauser_28day_median_boarders', 'team_census_elixhauser_28day_mean_nonboarders', 
             'team_census_elixhauser_28day_median_nonboarders', 'team_census_elixhauser_28day_mean_same_room',
             'team_census_elixhauser_28day_median_same_room',

             'team_census_elixhauser_hospital_mean_combined', 'team_census_elixhauser_hospital_median_combined',
             'team_census_elixhauser_hospital_mean_boarders', 'team_census_elixhauser_hospital_median_boarders',
             'team_census_elixhauser_hospital_mean_nonboarders', 'team_census_elixhauser_hospital_median_nonboarders', 
             'team_census_elixhauser_hospital_mean_same_room', 'team_census_elixhauser_hospital_median_same_room',
             
             'other_team_census_oasis_mean', 'other_team_census_oasis_median',
             'other_team_census_elixhauser_28day_mean', 'other_team_census_elixhauser_28day_median', 
             'other_team_census_elixhauser_hospital_mean', 'other_team_census_elixhauser_hospital_median',
             
             'msicu_team_census_oasis_mean', 'msicu_team_census_oasis_median',
             'msicu_team_census_elixhauser_28day_mean', 'msicu_team_census_elixhauser_28day_median', 
             'msicu_team_census_elixhauser_hospital_mean', 'msicu_team_census_elixhauser_hospital_median',
             
             'west_initial_remaining_beds', 'eastwest_initial_remaining_beds',
             'west_initial_team_census', 'eastwest_initial_team_census',
             # The expected value of this is where the patient boarded (or the MICU if boarder_status == 0)
             # BUT, at present, if the patient didn't board during the INITIAL part of their ICU stay but did so later,
             # then boarder_status can equal 1 while transfers.curr_careunit == 'MICU'.
             # Consider creating a new variable called 'icustay_boarder_location' that has the location
             # of the patient when they were boarding (although this is complicated by the fact that there
             # may be >1 boarding location) for any given boarder.
             # 'transfers.curr_careunit',
           
             'micu_team', 
             
             'los_days_prior_to_icu',
           
             # NEW ('post-change')
             'icustay_boarder_initial', 'icustay_boarder_ever', 'boarder_1hr',
             'initial_team_census', 'initial_team_outboarders', 'initial_expected_team_outboarders',
             'initial_inboarder_count', 'initial_remaining_beds',
             'icustay_los_total', 'icustay_los_boarder', 'icustay_boarder_fraction',
             
             'other_initial_team_census', 'other_initial_team_outboarders', 'other_initial_expected_team_outboarders',
             'other_initial_inboarder_count', 'other_initial_remaining_beds',
             'msicu_initial_team_census', 'msicu_initial_remaining_beds',
             
             # OLD ('pre-change')
           'avg_team_census', 
           'avg_team_outboarders', 'avg_expected_team_outboarders',
           'avg_inboarder_count', 'avg_remaining_beds',
             
             # OTHER
           'admissions.hospital_expire_flag',
           'icustay_expire_flag', 'icustay_expire_flag_mod', 'hospital_expire_flag', 'hospital_expire_flag_mod',
           'OASIS', 'gender', 'icustay_admit_age',
           'days_survived', 'days_since_icu_admission',
           'icu_free_days_21', 'icu_free_days_28', 'icu_free_days_35',
           'transfer_count_this_icustay', 'icustay_count_this_admission', 'icustay_count_this_patient',
           'admissions_count_this_patient',
           'icd_code', 'ccs_lvl1', 'ccs_lvl1_label', 'ccs_lvl2', 'ccs_lvl2_label', 'ccs_lvl3', 'ccs_lvl3_label',
#            'total_vasopressor_days',
#            'ventdays',
           
             # TO BE RESTORED LATER
             # 'cxr_count', 'echo_count', 'ecg_count', 'total_orders_count',
           'elixhauser_hospital', 'elixhauser_28day',
           'congestive_heart_failure', 'cardiac_arrhythmias', 'valvular_disease', 'pulmonary_circulation',
           'peripheral_vascular', 'hypertension', 'paralysis', 'other_neurological', 'chronic_pulmonary',
           'diabetes_uncomplicated', 'diabetes_complicated', 'hypothyroidism', 'renal_failure',
           'liver_disease', 'peptic_ulcer', 'aids', 'lymphoma', 'metastatic_cancer', 'solid_tumor',
           'rheumatoid_arthritis', 'coagulopathy', 'obesity', 'weight_loss', 'fluid_electrolyte', 'blood_loss_anemia',
           'deficiency_anemias', 'alcohol_abuse', 'drug_abuse', 'psychoses', 'depression']]
# df18.head(15)


# In[139]:

# Export EARLIEST ICU stay version:
mimic_common.df_to_csv('boarders_FIRST_ICU_Jan10_v3.csv', df18)

# Export LATEST ICU stay version:
# mimic_common.df_to_csv('boarders_LAST_ICU_Jan10_v3.csv', df18)


# In[ ]:

# We lose 29% of our sample if we narrow to ED admits only
# Transfers make up 1807/6289

# df17[df17['transfers.eventtype'] == 'transfer']
df17


# In[ ]:

df18 = df17
df18.groupby("transfers.intime_year").agg([len, np.mean, np.median])[['elixhauser_hospital', 'elixhauser_28day', 'OASIS', 'icustay_boarder_ever']]


# In[ ]:

# Total - 6807 (763, or 11%, of which have a primary diagnosis that fits into one of the categories below)
# df17

# AMI - 52
# df17[df17['ccs_lvl3'] == '7.2.3']

# CHF - 180
# df17[df17['ccs_lvl3'] == '7.2.11']

# GI Hemorrhage - 68
# df17[df17['ccs_lvl2'] == '9.1']

# Hip fracture - 62
# df17[df17['ccs_lvl3'] == '16.2.1']

# Pneumonia - 340
# df17[df17['ccs_lvl3'] == '8.1.1']

# Stroke - 61
# df17[df17['ccs_lvl3'] == '7.3.1']


# In[ ]:

# df17[df17['ccs_lvl3_label'] == ' '][['icd_code', 'ccs_lvl2_label', 'ccs_lvl1_label']]
# df17[df17['ccs_lvl2_label'] == ' '][['icd_code', 'ccs_lvl2_label', 'ccs_lvl1_label']]
# df17['ccs_lvl2_label'].unique()


# In[ ]:

# df15 = df14
# df15['year'] = np.nan
# df15['year'] = df15['transfers.intime'].map(lambda x: x.year)

# df15['years'] = np.nan
# df15['years'][df15['year'] == 2006] = 0
# df15['years'][df15['year'] == 2007] = 1
# df15['years'][df15['year'] == 2008] = 2
# df15['years'][df15['year'] == 2009] = 3
# df15['years'][df15['year'] == 2010] = 4
# df15['years'][df15['year'] == 2011] = 5
# df15['years'][df15['year'] == 2012] = 6


# In[ ]:

# Performing instrumental variable analyses (IVA) in Python
# http://nbviewer.ipython.org/github/natematias/research_in_python/blob/master/instrumental_variables_estimation/Instrumental-Variables%20Estimation.ipynb

