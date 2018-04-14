'''
Created on Oct 11, 2015

@author: Francky
'''

from __future__ import print_function
from __future__ import division

import os
import glob
import re
import string

sids_detected_with_icd9 = [add list here]

def compute_has_diabetes(text):
    '''
    
    '''
    regexp = re.compile(r'[\s{0}]DM[\s{0}]'.format(re.escape(string.punctuation)))
    has_diabetes = ('diabetes' in text.lower()) or (regexp.search(text) is not None)
    #print('has_diabetes: {0}'.format(has_diabetes))
    if regexp.search(text) is not None:
        print('regexp.search(text): {0}'.format(regexp.findall(text))) 
    # number_of_diabetes_patients: 14038
    return has_diabetes


def compute_has_hemo(text):
    case_insensitive_patterns = ['hemodialysis', 'haemodialysis', 'kidney dialysis', 'renal dialysis', 'extracorporeal dialysis']
    case_sensitive_patterns = ['on HD', 'HD today', 'tunneled HD', 'continue HD', 'cont HD']
    case_insensitive_pattern_results = [pattern in text.lower() for pattern in case_insensitive_patterns]
    case_sensitive_pattern_results = [pattern in text for pattern in case_sensitive_patterns]
    has_hemo = sum(case_insensitive_pattern_results) + sum(case_sensitive_pattern_results) > 0
    if has_hemo:
        print('case_insensitive_pattern_results: {0}'.format(case_insensitive_pattern_results))
        print('case_sensitive_pattern_results: {0}'.format(case_sensitive_pattern_results))
        #print('has_hemo: {0}'.format(has_hemo))
    
    hemo_matched = case_insensitive_pattern_results + case_sensitive_pattern_results
    
    return has_hemo, hemo_matched

def process_note(note_filepath, note_output_folder):
    
    text = open(note_filepath, 'r').read()
    note_filename = os.path.basename(note_filepath)
    #print('text: {0}'.format(text))
    
    # Step 1: has diabetes?
    has_diabetes = compute_has_diabetes(text)

    # Step 2: has hemo?
    has_hemo, hemo_matched = compute_has_hemo(text)
    
    if not (has_diabetes and has_hemo):
        return has_diabetes, has_hemo, hemo_matched
     
    # Step 3: remove history and copy note
    print('remove family history and copy note')
    sid = int(note_filename.replace('sid', '').replace('.txt', ''))
    if sid in sids_detected_with_icd9:
        output_note_filepath = os.path.join(note_output_folder, 'already_detected_in_icd9', note_filename)
    else:
        output_note_filepath = os.path.join(note_output_folder, 'only_detected_in_notes', note_filename)
    output_note = open(output_note_filepath, 'w')
    family_history_section = False
    for line in text.split('\n'):
        #print('line: {0}'.format(line))
        if 'family history:' in line.lower():
            family_history_section = True
            output_note.write('Family History section removed\n\n')
            print('Family History section removed')
        if not family_history_section:
            output_note.write(line+'\n')
        if family_history_section and len(line.strip()) == 0: # If there is an empty line, it means that the family history section ended
            family_history_section = False
    output_note.close()
            
    # Step 4: delete output if when Family History is removed there is no more diabetes or hemo        
    text = open(output_note_filepath, 'r').read()
    has_diabetes = compute_has_diabetes(text)
    has_hemo, hemo_matched = compute_has_hemo(text)
    if not (has_diabetes and has_hemo): 
        os.remove(output_note_filepath)
        print('file removed') 
    
    return has_diabetes, has_hemo, hemo_matched


def main():
    '''
    This is the main function
    '''
    #number_of_diabetes_patients = number_of_hemo_patients = number_of_hemo_and_diabetes_patients = 0
    diabetes_patients = []
    hemo_patients  = []
    note_folder = os.path.join('all_notes')
    note_output_folder = os.path.join(note_folder, 'output')
    count = 0    
    for note_filepath in glob.iglob(os.path.join(note_folder, 'sid*.txt')):
    #for note_filepath in glob.iglob(os.path.join(note_folder, 'sid1114.txt')):
        print('note_filepath: {0}'.format(note_filepath))
        sid = int(os.path.basename(note_filepath).replace('sid', '').replace('.txt', ''))
        has_diabetes, has_hemo, hemo_matched = process_note(note_filepath, note_output_folder)
        if has_diabetes: diabetes_patients.append(sid)#number_of_diabetes_patients += 1
        if has_hemo: hemo_patients.append(sid) #number_of_hemo_patients += 1
        #if has_diabetes and has_hemo:number_of_hemo_and_diabetes_patients += 1
        count += 1
    '''
    print('number_of_diabetes_patients: {0}'.format(number_of_diabetes_patients))
    print('number_of_hemo_patients: {0}'.format(number_of_hemo_patients))
    print('number_of_hemo_and_diabetes_patients: {0}'.format(number_of_hemo_and_diabetes_patients))
    '''
            
    print('number_of_diabetes_patients: {0}'.format(len(diabetes_patients)))
    print('number_of_hemo_patients: {0}'.format(len(hemo_patients)))
    
    print('diabetes_patients: {0}'.format(diabetes_patients))
    print('hemo_patients: {0}'.format(hemo_patients))
    
if __name__ == "__main__":
    main()
    #cProfile.run('main()') # if you want to do some profiling
    