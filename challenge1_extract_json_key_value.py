#!/usr/bin/python

import json


def process_json(object_dict,input_key):
	key_split=input_key.split('/')
	len=input_key.count('/')
	if ( len == 0 ):
		print(object_dict[key_split[0]])
	if ( len == 1 ):
		print(object_dict[key_split[0]][key_split[1]])
	if ( len == 2 ):
		print(object_dict[key_split[0]][key_split[1]][key_split[2]])
	if ( len >= 3 ):
		print("Invalid Key!")
	

input_object = input('Enter object: ')
object_dict = json.loads(input_object)
input_key = input('Enter key: ')
process_json(object_dict,input_key)

