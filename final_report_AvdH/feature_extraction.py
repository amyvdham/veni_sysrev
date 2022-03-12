# Import feature extractor
from asreview.models.feature_extraction import Doc2Vec

# Import ASReview data processor
from asreview import ASReviewData

# Load the data
# Note: first need to make sure whether the articles are labelled correctly in 
# this file. It could be that they are reversed code.
ASdata = ASReviewData.from_file("/Users/amyvanderham/Documents/Research_Assistant_Rgit/veni_sysrev/asreview_result_sysrevemotprob.csv")

# Create the feature extractor object
featureExtractorDV = Doc2Vec()

# Fit the model
featureExtractorDV.fit(ASdata.texts)

# Not sure what the difference between the models below: model_dm, model_dbow 
# is. Found the following on ASReview documentation:
# https://asreview.readthedocs.io/en/stable/_modules/asreview/models/feature_extraction/doc2vec.html
#  dm: int
#        Model to use.
#        0: Use distribute bag of words (DBOW).
#        1: Use distributed memory (DM).
#        2: Use both of the above with half the vector size and concatenate
#        them.
#
# # If self.dm is 2, train both models and concatenate the feature
# # vectors later. Resulting vector size should be the same.
#        if self.dm == 2:
#            model_param["vector_size"] = int(model_param["vector_size"] / 2)
#            self.model_dm = _train_model(corpus, **model_param, dm=1)
#            self.model_dbow = _train_model(corpus, **model_param, dm=0)
#        else:
#            self.model = _train_model(corpus, **model_param, dm=self.dm)

# Based on the information above I would expect model_dm to contain the 
# feature vectors resulting from using distributed memory(dm) since dm = 1
# and model_dbow those resulting from using distributed bag of words (dbow) 
# since dm = 0. However I do not know which model represent dm = 2 and 
# contains the concatenated feature vectors of both the models. I have tried
# model (featureExtractorDV.model_dm) but then I receive the error
# 'Doc2Vec' object has no attribute 'model'. Therefore, for now, I have 
# decided to just use the feature vectors from the dbow model. 

gensimobjecta = featureExtractorDV.model_dm

gensimobject = featureExtractorDV.model_dbow

# gensimobjectb = featureExtractorDV.model

# For some reason I get the error 'Word2VecKeyedVectors' object has no 
# attribute 'index_to_key. I can not figure out the reason for this since 
# the version of gensim that is downloaded (4.1.0) should contain this. 
# I have no used index2word instead. 
#gensimobject.wv.index_to_key
gensimobject.wv.index2word
#model.wv.key_to_index

# Use the model in which the feature vectors of dm and dbow are concatenated
# and save these vectors in a dictionary object in which they are stored 
# with there associated term. 
my_dict = dict({})
# note that you might have to use index_to_key instead of index2word here
# depending on the gensim version you are working with. 
for idx, key in enumerate(gensimobject.wv.index2word):
    my_dict[key] = gensimobject.wv[key]
    
    
import itertools

dict(itertools.islice(my_dict.items(), 4))


# load csv module
import csv

# open file for writing, "w" is writing
w = csv.writer(open("dict_feature_extraction_doc2vec.csv", "w"))

# loop over dictionary keys and values
for key, val in my_dict.items():

    # write every key and value to file
    w.writerow([key, val])



