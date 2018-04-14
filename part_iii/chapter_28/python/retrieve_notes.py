'''
Created on Oct 9, 2015

@author: Franck Dernoncourt <francky@mit.edu>
'''

from __future__ import print_function
from __future__ import division


import datetime
import os
import time
import timeit
import warnings

import cx_Oracle

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats

import oracle_db 
import xml.etree.ElementTree
import glob


def list_diseases(cas_filepath):
    '''
    http://stackoverflow.com/questions/1912434/how-do-i-parse-xml-in-python
    http://www.diveintopython3.net/xml.html
    '''
    e = xml.etree.ElementTree.parse(cas_filepath).getroot()
    
    # Get raw notes
    for atype in e.findall('uima.cas.Sofa'):
        notes = atype.get('sofaString')
    
    # Get FSArray
    disease_ids = {}
    for atype in e.findall('uima.cas.FSArray'):
        disease_id = atype.get('_id')
        disease_ids[disease_id] = []
        #print('disease_id: {0}'.format(disease_id))
        for child in atype.getchildren():
            disease_ids[disease_id].append(child.text)
    #print('disease_ids: {0}'.format(disease_ids))
    
    # Get UmlsConcept
    umls_ids = {}
    for atype in e.findall('org.apache.ctakes.typesystem.type.refsem.UmlsConcept'):
        umls_ids[atype.get('_id')] = atype.get('cui')
    #print('umls_ids: {0}'.format(umls_ids))
    
    # Link disease_id to umls_ids
    disease_id_cuid_map = {}
    for disease_id, disease_id_multi in disease_ids.items():
        #print('disease_id_multi: {0}'.format(disease_id_multi))
        #for disease_id_multi_item
        if disease_id_multi[0] in umls_ids:
            disease_id_cuid_map[disease_id] = umls_ids[disease_id_multi[0]]  
        
    #print('disease_id_cuid_map: {0}'.format(disease_id_cuid_map))
    
    # Get diseases 
    diseases = []
    for atype in e.findall('org.apache.ctakes.typesystem.type.textsem.DiseaseDisorderMention'):
        disease = {}
        disease['polarity'] = int(atype.get('polarity'))
        disease['_ref_ontologyConceptArr'] = atype.get('_ref_ontologyConceptArr')
        disease['cuid'] = disease_id_cuid_map[disease['_ref_ontologyConceptArr']]
        disease['begin'] = int(atype.get('begin'))
        disease['end'] = int(atype.get('end'))
        disease['text'] = notes[disease['begin']:disease['end']]
        disease['context'] = notes[max(0, disease['begin']-60):min(disease['end']+60, len(notes))]
        #print('_ref_ontologyConceptArr: {0}; polarity: {1}'.format(_ref_ontologyConceptArr, polarity))
        '''
        if _ref_ontologyConceptArr not in diseases:
            diseases[_ref_ontologyConceptArr] = [polarity]
        else:
            diseases[_ref_ontologyConceptArr].append(polarity)  
        '''
        if True or disease['cuid'] in ['C0011849']:
            diseases.append(disease)
    #print('diseases: {0}'.format(diseases))
    
    diseases = remove_overlapping_events(diseases)
    print('diseases: {0}'.format(diseases))
    #display_events_text(diseases, notes)
    
def remove_overlapping_events(my_list):
    new_list = []
    for idx1, v in enumerate(my_list):
        add = True
        begin = int(v['begin'])
        end = int(v['end'])
        for idx2, v2 in enumerate(my_list):
            if idx1 == idx2: continue
            if (begin >= int(v2['begin']) and end <= int(v2['end'])): # overlap
                add = False
        if add:
            new_list.append(v)
    return new_list


def display_events_text(event_list, notes):
    for event in event_list:
        print(notes[int(event['begin']):int(event['end'])])

def retrieve_notes():
    '''
    
    '''
    
    cursor = oracle_db.get_cursor()    
    #filename = os.path.join('.', 'sql', 'cohort_diabetic_count.sql')
    #cursor = oracle_db.execute_sql_file(filename, cursor, True)
    
    
    subject_ids = []
    #file = open(os.path.join('export', 'cohort_diabetic_hemodialysis_proc_based.csv'), 'r')
    #file = open(os.path.join('export', 'cohort_diabetic_hemodialysis_notes_based_count.csv'), 'r')
    file = open(os.path.join('export', 'cohort_over_18.csv'), 'r')
    for cur_line in file:
        try:
            subject_ids.append(int(cur_line.strip()))
        except:
            pass
    file.close() 
    print('subject_ids: {0}'.format(subject_ids))
    print('len(subject_ids): {0}'.format(len(subject_ids)))
    
    #subject_id = 1795
    for subject_id  in subject_ids:
        sql='''
        SELECT NOTEEVENTS.TEXT
    FROM MIMIC2V30.NOTEEVENTS
    WHERE NOTEEVENTS.SUBJECT_ID = {0}
    AND NOTEEVENTS.CATEGORY NOT IN ('ECG_REPORT', 'ECHO_REPORT', 'RADIOLOGY_REPORT')
    ORDER BY NOTEEVENTS.CHARTTIME ASC
    '''.format(subject_id)
        cursor = oracle_db.execute_sql(sql, cursor, verbose = False, display_query = True)
        
        patient_notes = ''
        note_number = 0
        for row in cursor:
            note_number += 1
            preceding_break = ''
            if note_number > 1:
                preceding_break += '\n\n\n\n'
            patient_notes = patient_notes + '{1}Note number: {0}\n\n'.format(note_number, preceding_break) + str(row[0])
            #print('row[0]: {0}'.format(row[0]))
        
        #print('patient_notes: {0}'.format(patient_notes))
        open(os.path.join('all_notes', 'sid{0}.txt'.format(subject_id)), 'w').write(patient_notes)
        print('subject_id: {0} done'.format(subject_id))

def main():
    note_ctakes_output_folder = os.path.join('notes', 'output')
    for cas_filepath in glob.glob(os.path.join(note_ctakes_output_folder, '*.txt.xml')):
        print('cas_filepath: {0}'.format(cas_filepath))
        list_diseases(cas_filepath)

    
    
if __name__ == "__main__":
    main()
    #cProfile.run('main()') # if you want to do some profiling
    
    
        