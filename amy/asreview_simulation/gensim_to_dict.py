#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 15 11:30:35 2021

@author: amyvanderham
"""

import gensim

model = gensim.models.Doc2Vec.load("/Users/amyvanderham/Documents/Research_Assistant_Rgit/veni_sysrev/asreview_simulation/gensim.model")

model.wv.index_to_key
#model.wv.key_to_index

my_dict = dict({})
for idx, key in enumerate(model.wv.index_to_key):
    my_dict[key] = model.wv[key]

import itertools

dict(itertools.islice(my_dict.items(), 4))

# load csv module
import csv

# open file for writing, "w" is writing
w = csv.writer(open("/Users/amyvanderham/Documents/Research_Assistant_Rgit/veni_sysrev/asreview_simulation/dict_wordvec.csv", "w"))

# loop over dictionary keys and values
for key, val in my_dict.items():

    # write every key and value to file
    w.writerow([key, val])
