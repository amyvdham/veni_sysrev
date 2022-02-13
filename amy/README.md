# Readme

This folder contains the source code for the final report *“Research assistantship for Caspar van Lissa: Applying cluster analysis on word vectors”*. The aim of this project was to investigate whether it is possible to identify closely related terms in a corpus of abstracts of articles related to emotional regulation by applying k-means clustering on word vectors. 

## Where to start?
To reproduce the analyses in the final report the following steps need to be taken. 

First it is important that the datasets with the pretrained word vectors of GloVe and Word2Vec are in your repository and correct folder `/final_report_AvdH`. These data sets can be retrieved online. Download the Common Crawl (840B tokens, 2.2M vocab, cased, 300d vectors, 2.03 GB download) from <a href="https://github.com/stanfordnlp/GloVe/">this</a> page and the GoogleNews-vectors-negative300.bin.gz. archive by clicking on the <a href="https://drive.google.com/file/d/0B7XkCwpI5KDYNlNUTTlSS21pQmM/edit?resourcekey=0-wjGZdNAUop6WykTtMip30g">link</a> that can be found <a href="https://code.google.com/archive/p/word2vec/">here</a>. After downloading make sure the files `glove.840B.300d.txt` and `GoogleNews-vectors-negative300.bin` are in your repository and stored in the folder `/final_report_AvdH`. 


Secondly, there are two python scripts, `create_w2v_embedding.py` and `create_w2v_emb_bigrams.py`, that need to be run in order to create two files that are needed in the final script, `pretrained_w2v_filtered_bigrams.csv` and `pretrained_w2v_filtered.csv`. 

To be able to run these Python scripts the csv files `final_filter.csv` and `bigrams_filter.csv` first need to be created by running the associated code in the `final_script.Rmd` file. This code can be found in the block under need the heading *“Save dataframe which only includes the filter column - final filter”* and *“Save dataframe which only includes the filter column - bigrams filter (Word2Vec)”*.

## Overview Files 
File                                | Description                   | Usage         
-------------------------           | --------------------------    | --------------
final_script.Rmd                    | Fully reproducible manuscript | Human editable
gensim_to_dict.py                   | Project file                  | Loads project 
create_w2v_embedding.py             | Project file                  | Loads project 
create_w2v_emb_bigrams.py           | Project file                  | Loads project 
README.md                           | Description of project        | Human editable
glove_embedding_final.RData         | Project file                  | Loads project 
glove_embedding_bigrams.RData       | User permissions              | Read only     
w2v_embedding_final.RData           | Preregistered hypotheses      | Human editable
dict_wordvec_sim.csv                | Project file                  | Loads project 
w2v_bigrams_embedding.RData         | Reproducible R environment    | Read only     
glove.840B.300d.txt                 | WORCS metadata YAML           | Read only 
GoogleNews-vectors-negative300.bin  | WORCS metadata YAML           | Read only 
final_filter.csv                    | WORCS metadata YAML           | Read only 
bigrams_filter.csv                  | WORCS metadata YAML           | Read only 
pretrained_w2v_filtered_bigrams.csv | WORCS metadata YAML           | Read only 
pretrained_w2v_filtered.csv         | WORCS metadata YAML           | Read only 

feature_extraction.py 



