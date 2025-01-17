# Readme

This folder contains the source code for the final report *“Research assistantship for Caspar van Lissa: Applying cluster analysis on word vectors”*. The aim of this project was to investigate whether it is possible to identify closely related terms in a corpus of abstracts of articles related to emotional regulation by applying k-means clustering on word vectors. 

## Where to start?
The file `final_script.Rmd` is the main script of this project and contains the code that was used for producing the results that can be found in the final report. To reproduce the analyses in the final report the following steps need to be taken. 

First, it is important that the `veni_sysrev` is set as the working directory. (When running the Python files your working directory should be set to `veni_sysrev/final_report_AvdH`)

Secondly, before opening and running the script `final_script.Rmd`, you have to download the existing datasets with the pre-trained word vectors of GloVe and Word2Vec. These datasets can be found online. Download the Common Crawl (840B tokens, 2.2M vocab, cased, 300d vectors, 2.03 GB download) from <a href="https://github.com/stanfordnlp/GloVe/">this</a> page and the GoogleNews-vectors-negative300.bin.gz. archive by clicking on the <a href="https://drive.google.com/file/d/0B7XkCwpI5KDYNlNUTTlSS21pQmM/edit?resourcekey=0-wjGZdNAUop6WykTtMip30g">link</a> that can be found <a href="https://code.google.com/archive/p/word2vec/">here</a>. After downloading make sure the files `glove.840B.300d.txt` and `GoogleNews-vectors-negative300.bin` are in your repository and stored in the folder `veni_sysrev/final_report_AvdH`. 

Thirdly, there are two python scripts, `create_w2v_embedding.py` and `create_w2v_emb_bigrams.py`, that need to be run in order to create two files that are needed in the final script, `pretrained_w2v_filtered_bigrams.csv` and `pretrained_w2v_filtered.csv`. 

To be able to run these Python scripts the csv files, `final_filter.csv` and `bigrams_filter.csv`, first need to be created by running the associated code in the `final_script.Rmd` file. This code can be found in the block underneath the heading *“Save dataframe which only includes the filter column - final filter”* and *“Save dataframe which only includes the filter column - bigrams filter (Word2Vec)”*.

## Overview Files 
File                                | Description                                                                                                   | Access      
-------------------------           | --------------------------------------------                                                                  | --------------
asreview_embedding_sim_final.RData  | Matrix with word vectors obtained by running the simulation mode in ASReview                                  | Repository
bigrams_filter_glove.RData          | Dataframe containing the terms (including bigrams separate with a -) we want to include in the analysis       | Run final_script.Rmd
bigrams_filter.csv                  | Dataframe containing the terms (including bigrams separate with a _) we want to include in the analysis       | Run final_script.Rmd
bigrams_filter.RData                | Dataframe containing the terms (including bigrams separate with a _) we want to include in the analysis       | Run final_script.Rmd
create_w2v_emb_bigrams.py           | Extract word vectors (including for bigram terms) from existing Word2Vec dataset                              | Repository
create_w2v_embedding.py             | Extract word vectors from existing Word2Vec dataset                                                           | Repository
data_study2.RData                   | Dataframe after applying first pre-processing steps that were also done in the original manuscript            | Run final_script.Rmd
dict_wordvec_sim.csv                | Dictionary with the terms as the keys and their associated word vectors                                       | Run gensim_to_dict.py (not working)
english-ewt-ud-2.5-191206.udpipe    | English udpipe model                                                                                          | Repository
feature_extraction.py               | Python script that shows how to apply feature extraction without the simulation mode in ASReview              | Repository 
final_filter.csv                    | Dataframe containing the terms(only unigrams) we want to include in the analysis                              | Run final_script.Rmd 
final_filter.Rdata                  | Dataframe containing the terms(only unigrams) we want to include in the analysis                              | Run final_script.Rmd
final_script.Rmd                    | Main script of this project                                                                                   | Repository
gensim_to_dict.py                   | Transforming the vocab and matrix from the gensim model to a dictionary                                       | Repository
gensim.model                        | Doc2Vec object retrieved by running the ASReview simulation mode which contains the word vectors              | Repository
glove_embedding_bigrams.RData       | Matrix containing the terms (including bigrams) and their word vector extracted from the GloVe dataset        | Run final_script.Rmd   
glove_embedding_final.RData         | Matrix containing the terms (only unigrams) and their word vector extracted from the GloVe dataset            | Run final_script.Rmd
glove.840B.300d.txt                 | File containing the existing pre-trained GloVe word vectors                                                   | Download online 
GoogleNews-vectors-negative300.bin  | File containing the existing pre-trained Word2Vec word vectors                                                | Download online 
pretrained_w2v_filtered_bigrams.csv | File containing word vectors that could be extracted from the Word2Vec dataset (including for bigrams terms)  | Run create_w2v_emb_bigrams.py
pretrained_w2v_filtered.csv         | File containing word vectors that could be extracted from the Word2Vec dataset (only for unigram terms)       | Run create_w2v_embedding.py 
README.md                           | Description of project                                                                                        | Repository
study2_df_lemma.RData               | Dataframe with a column of the terms to be included in the analysis and information on the original articles  | Run final_script.Rmd
w2v_bigrams_embedding.RData         | Matrix containing the terms (including bigrams) and their word vector extracted from the Word2Vec dataset     | Run final_script.Rmd
w2v_embedding_final.RData           | Matrix containing the terms (only unigrams) and their word vector extracted from the Word2Vec dataset         | Run final_script.Rmd

## Issue with reproducibility of one file 
Note that the file `asreview_embedding_sim_final.Rdata` cannot be reproduced and should therefore be used directly. 

This is because at the moment it is not possible to recreate the `dict_wordvec_sim.csv` file out of which the `asreview_embedding_sim_final.Rdata` is created. 

The reason for this is that currently the Python script in the file `gensim_to_dict.py`, in which the `gensim.model` is used to create the file `dict_wordvec_sim.csv` is not working. Most likely this is the case because there are some issues with how the `gensim.model` was created and the current gensim/Python version in the Python script which is used to load the model. 

The gensim model was created by running the simulation mode of ASReview on the 14th of September 2021. After this the Python file `gensim_to_dict.py` was run to create the `dict_wordvec_sim.csv` file. However, when rerunning the Python script as of today (15 february 2022) the error `UnpicklingError: could not find MARK` was received. The pages below point out that this probably has to do with the different gensim/Python version in which the gensim model was created and in with which it was loaded. 

* https://stackoverflow.com/questions/44022180/unpickling-error-while-using-word2vec-load
    
* https://github.com/RaRe-Technologies/gensim/issues/860 


At the current state of this project, I did not have the time to recreate the gensim model and see if this would solve the issue. Therefore, the `asreview_embedding_sim_final.Rdata` has been added to the repository so that the results in the paper can still be reproduced. 

