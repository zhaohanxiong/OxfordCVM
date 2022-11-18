import json

def initialize_flags():

    # load dictionary
    fname = "test/test.json"
    test_dict = json.load(open(fname))

    # iterate through all groups (assumes only 2 layers to dictionary)
    for key_group, _ in test_dict.items():

        # iterate through each group
        for key, _ in test_dict[key_group].items():

            test_dict[key_group][key] = False

    filedict = open(fname, 'w')
    json.dump(test_dict, filedict, indent = 4, sort_keys = True)

if __name__ == "__main__":
    initialize_flags()
