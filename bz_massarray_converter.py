#!/usr/bin/python3

import sys
import os
import os.path
import re
#import glob
#import shutil
import subprocess
import pandas as pd
import numpy as np
from argparse import ArgumentParser

def parse_args():
    parser = ArgumentParser(description='Interpretor of sequenom raw data given a set of rules.')

    parser.add_argument('-i', '--infile',
                        required=True,
                        help='Raw sequenom data')
    parser.add_argument('-r', '--rules',
                        required=True,
                        help='Set of rules')
    return parser.parse_args()

def load_file(infile):
    if not os.path.isfile(infile):
        raise Exception('File not found')
    else:
        data = pd.read_csv(infile, encoding="UTF-8", na_values = [''])
    return(data)

def parse_value(df):
    # this is the value matrix, containing the levels of confidence
    df_val = df.pivot(index='Sample_Id', columns='Assay_Id', values='Description')
    #df_val.reset_index(inplace=True)
    #df_val = df_val.fillna('blank')
    return(df_val)

def parse_matrix(df):
    # this is the call matrix, containing the bases called, at the A, B, C and E levels of confidence
    print('Parsing the call matrix values...')
    df_mat = df.pivot(index='Sample_Id', columns='Assay_Id', values='Call')
    df_mat.reset_index(inplace=True)
    df_mat = df_mat.fillna('blank')
    print(df_mat['Sample_Id'].count(), 'entries recorded')
    print('Parsing the call matrix confidence...')
    return(df_mat)

def filter_badspectrum(df_mat, df_val):
    # filter the value table where "Bad Spectrum" is found at least once
    df_val = df_val[df_val.isin(["I.Bad Spectrum"]).any(axis=1)]
    # filter out from the matrix table on the Sample_Id found in df_val (index)
    df_filt = df_mat[~df_mat['Sample_Id'].isin(df_val.index.values)]
    print('List of filtered samples: ', df_val.index.values)
    print(df_filt['Sample_Id'].count(), 'filtered entries remaining')
    return(df_filt)

def result_matrix(df):
    # df here is the parse matrix, used to create the result matrix
    df_res = df[['Sample_Id']]
    df_res = df_res.reindex(columns=[*df_res.columns.tolist(), 'aac(3)-II','aacA27','aacA4','aadB','blaACT/blaMIR','armA','blaCMY-2-like','blaCTX-M','DHA','fosA3' , \
        'GES', 'IMP','KPC','NDM','OXA-10','OXA-30','OXA-48','rmtB','rmtC','rmtF','SHV','TEM','VEB','VIM'], fill_value=0)
    #print(df_res.head())
    return(df_res)

#def convert_tg1():
    # search column header in Primer 1:
    # if call value on same row = df_mat[strain,col]
        # get Interpretation
        # modify value in df_res[strain,col] using Interpretation

#def convert_tgmtp():
    # for TEM & aac 4
        # filter row containing TEM
        # unique values from Primer 1 and Primer 2
        # replace new column header for call.1 and call.2
        # check Primer 1 and Primer 2 values
        # return corresponding Interpretation
        # modify value in df_res[strain, TEM]



def main():
    args = parse_args()

    # setting up run
    infile = args.infile
    rules = args.rules

    print('Loading data:' + infile)
    df_data = load_file(infile)

    print('Loading rules:', rules)
    df_rules = load_file(rules)
    print(df_rules.head())

    df_mat = parse_matrix(df_data)
    df_val = parse_value(df_data)

    print('Filter out Bad spectrum samples...')
    # filter out samples where "Bad Spectrum" is found at least once
    df_filt = filter_badspectrum(df_mat, df_val)

    print('Create results matrix...')
    df_res = result_matrix(df_filt)

    df_mat.to_csv('mat.csv', sep='\t')
    df_val.to_csv('val.csv', sep='\t')
    df_res.to_csv('res.csv', sep='\t')


if __name__ == "__main__":
    main()

