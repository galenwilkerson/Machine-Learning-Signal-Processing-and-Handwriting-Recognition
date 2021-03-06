import preprocess_linear

filename = "../data/MarieTherese_jul31_and_Aug07_all.pkl"

# preprocess the input file
preprocessed_output = preprocess_linear.preprocess(filename, 20)

#print preprocessed_output

print("data preprocessed")

import cPickle

# save to file
outfile = open("../data/preprocessed_data_linear.pkl", 'wb')
cPickle.dump(preprocessed_output, outfile)
