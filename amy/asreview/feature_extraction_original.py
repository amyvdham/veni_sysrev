# Import feature extractor
from asreview.models.feature_extraction import Doc2Vec

# Import ASReview data processor
from asreview import ASReviewData

# Load the data
ASdata = ASReviewData.from_file("/Users/amyvanderham/Documents/Research_Assistant_Rgit/veni_sysrev/asreview_result_sysrevemotprob.csv")

# Create the feature extractor object
featureExtractorDV = Doc2Vec()

# Fit the model
featureExtractorDV.fit(ASdata.texts)

gensimobjecta = featureExtractorDV.model_dm

gensimobject = featureExtractorDV.model_dbow

when_true = gensimobjecta == gensimobject
print(when_true)

gensimobject.wv.index_to_key
#model.wv.key_to_index

my_dict = dict({})
for idx, key in enumerate(gensimobject.wv.index_to_key):
    my_dict[key] = gensimobject.wv[key]
    
    
import itertools

dict(itertools.islice(my_dict.items(), 4))


# load csv module
import csv

# open file for writing, "w" is writing
w = csv.writer(open("/Users/amyvanderham/Documents/Research_Assistant_Rgit/veni_sysrev/amy/asreview/dict_feature_extraction_doc2vec.csv", "w"))

# loop over dictionary keys and values
for key, val in my_dict.items():

    # write every key and value to file
    w.writerow([key, val])



