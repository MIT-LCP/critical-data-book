'''
Created on Mar 23, 2015

@author: Franck Dernoncourt <francky@mit.edu>
'''
from __future__ import print_function
from __future__ import division

import time

import cx_Oracle

def get_cursor():
    '''
    Get a cursor to the database
    '''
    # http://stackoverflow.com/questions/24149138/cx-oracle-doesnt-connect-when-using-sid-instead-of-service-name-on-connection-s
    # http://www.oracle.com/technetwork/articles/dsl/prez-python-queries-101587.html
    ip = '127.0.0.1'
    port = '1521'
    sid = 'mimic2'
    dsnStr = cx_Oracle.makedsn(ip, port, sid)
    username = 'Enter your username here'
    password = open('oracle_password.txt', 'r').readline() # the password should be stored in a file named "oracle_password.txt" 
    db = cx_Oracle.connect(user=username, password=password, dsn=dsnStr)
    
    cursor = db.cursor()
    return cursor
    
def read_sql(filename):
    '''
    Read an SQL file and return it as a string
    '''
    file = open(filename, 'r')
    #for cur_line in file:
    #    print cur_line
    return ' '.join(file.readlines()).replace(';', '')
    #file.close()
    
def execute_sql_file(filename, cursor, verbose = False, display_query = False):
    '''
    Execute an SQL file and return the results
    '''
    sql = read_sql(filename)
    cursor = execute_sql(sql, cursor, verbose = False, display_query = False)   
    return cursor


def execute_sql(sql, cursor, verbose = False, display_query = False):
    '''
    Execute an SQL file and return the results
    '''
    if display_query: print(sql)
    start = time.time()
    if verbose: print('SQL query started... ', end='')
    cursor.execute(sql)
    if verbose: 
        end = time.time()
        print('SQL query done. (took {0} seconds)'.format(end - start))
        #print end - start   
    return cursor