#!/usr/bin/python

import json


def extract_json_key_value(object_dict,input_key):
    key_split=input_key.split('/')
    
    # Convert key into Dictionary key format For e.g. Input key x/y will be converted to object_dict['x']['y']  (which is formatted_dict value)
    formatted_key=input_key.replace('/', '\'][\'')
    formatted_dict='object_dict[\'' + formatted_key + '\']'
    
    print("\nValue is:")
    print(eval(formatted_dict)) # eval(formatted_dict) will run command extracted out of a formatted_dict variable value i.e. Input as an expression


input_object = input('\nEnter object: ')
input_key = input('Enter key: ')

try:    
    object_dict = json.loads(input_object)  # To parse a valid JSON string and convert it into a Python Dictionary
except:
    print("\nInvalid Input JSON Object, Exiting!\n")
    exit()
	
try:
    extract_json_key_value(object_dict,input_key)
except:
    print("Sorry, Invalid Key, Exiting!")

