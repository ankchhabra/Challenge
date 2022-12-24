#!/usr/bin/python

import json


def extract_value_from_json_key(object_dict,input_key):
    key_split=input_key.split('/')
    
    # Convert key into Dictionary key format For e.g. Input key x/y will be converted to object_dict['x']['y']  (which is formatted_dict value)
    formatted_key=input_key.replace('/', '\'][\'')
    formatted_dict='object_dict[\'' + formatted_key + '\']'
    
    print("\nValue is:")
    print(eval(formatted_dict)) # eval(formatted_dict) will run command extracted out of a formatted_dict variable value i.e. Input as an expression


input_object = input('\nEnter object: ')
input_key = input('Enter key: ')
len_object=input_object.count(':')
len_key=input_key.count('/')

object_in_key_format=input_object.replace('\"', '').replace('{', '').replace('}', '').replace(':', '/')

if len_key >= len_object:       # Error Handling: if Key length is equal or greater than Object Length
    print("\nInvalid Key Length, Exiting!\n")
    exit()
elif input_key not in object_in_key_format or input_key.split('/')[0]!=object_in_key_format.split('/')[0]:    # Error Handling: if Key is not valid
    print("\nInvalid Key, Exiting!\n")
    exit()
else:
    object_dict = json.loads(input_object)
    extract_value_from_json_key(object_dict,input_key)

