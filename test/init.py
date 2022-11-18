import json

# load dictionary
fname = "test.json"
test_dict = json.load(open(fname))

# iterate through all groups (assumes only 2 layers to dictionary)
for key_group, value in test_dict.items():

    # iterate through each group
    for key, value2 in test_dict[key_group].items():

        test_dict[key_group][key] = False

filedict = open(fname, 'w')
json.dump(test_dict, filedict, indent = 4, sort_keys = True)
