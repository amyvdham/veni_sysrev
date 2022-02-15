import pandas as pd
import numpy as np
import csv
from gensim.models import KeyedVectors
import itertools

# load data frame than inludes the words we want the vectors of. 
data = pd.read_csv("bigrams_filter.csv")


# create a list of the set of words that we want to include
list_of_filter = data['filter_bigrams'].tolist()

# test simple list of filter to see if funtion works
#list_of_filter = {"sunlight", "sunshine", "rays", "sun", "london", "amsterdam", "testworddib"}

#print(f"\nlist_of_filter:\n{list_of_filter}\ntype:{type(list_of_filter)}")

# Load the google news word2vec model
filename = "GoogleNews-vectors-negative300.bin"
model = KeyedVectors.load_word2vec_format(filename, binary=True)

# run most similar to make sure that vectors_nome is not equal to None. 
model.most_similar("sun")
model.init_sims()

print(model.most_similar("sun"))

# create function that filters a restricted set of words from the word2vec model
def restrict_w2v(w2v, restricted_word_set):
    new_vectors = []
    new_vocab = {}
    new_index2entity = []
    new_vectors_norm = []

    for i in range(len(w2v.vocab)):
        word = w2v.index2entity[i]
        vec = w2v.vectors[i]
        vocab = w2v.vocab[word]
        vec_norm = w2v.vectors_norm[i]
        if word in restricted_word_set:
            vocab.index = len(new_index2entity)
            new_index2entity.append(word)
            new_vocab[word] = vocab
            new_vectors.append(vec)
            new_vectors_norm.append(vec_norm)

    w2v.vocab = new_vocab
    w2v.vectors = np.array(new_vectors)
    w2v.index2entity = np.array(new_index2entity)
    w2v.index2word = np.array(new_index2entity)
    w2v.vectors_norm = np.array(new_vectors_norm)
    

# apply function on pretrained word2vec model 
restrict_w2v(model, list_of_filter)

# check if result of most similar to sun have changed after the filter is 
# applied. Since we no have some words that are removed from the model such as
# beach and shine for example.
print(model.most_similar("sun"))

# create dictionary so that I can save the matrix 
my_dict = dict({})
for idx, key in enumerate(model.vocab):
    my_dict[key] = model[key]

dict(itertools.islice(my_dict.items(), 4))

# save matrix with word vectors as csv
# open file for writing, "w" is writing
w = csv.writer(open("pretrained_w2v_filtered_bigrams.csv", "w"))

# loop over dictionary keys and values
for key, val in my_dict.items():

    # write every key and value to file
    w.writerow([key, val])
