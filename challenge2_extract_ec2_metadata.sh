#!/bin/bash

curl http://169.254.169.254/latest/meta-data/ > ec2_metadata.txt
echo -e "Please choose option: \n\n1. Display whole metadata in Json Format\n2. Search for a particular data key's value\n\nEnter your choice: "
read choice


> ec2_metadata_json_key_values.txt
for i in `cat ec2_metadata.txt`; 
do
	# Condition to filter metadata without subsequent path
	if [[ "$i" !=  *"/" ]]; then
		
		echo -ne "{\n\"$i\" : \"" >> ec2_metadata_json_key_values.txt # Json Formatting
		curl http://169.254.169.254/latest/meta-data/$i >> ec2_metadata_json_key_values.txt
		
		echo "\"" >> ec2_metadata_json_key_values.txt # Json Formatting
		echo "}" >> ec2_metadata_json_key_values.txt # Json Formatting
	else
		# Temporary file to store subsequent path if above condition is not met
		
		curl http://169.254.169.254/latest/meta-data/$i > temp1.txt
		
		# Recursively fetch one row at a time from temporary file
		
		for j in `cat temp1.txt`; 
		do
		if [[ "$j" !=  *"/" ]]; then
			echo -ne "{\n\"$j\" : \"" >> ec2_metadata_json_key_values.txt
			curl http://169.254.169.254/latest/meta-data/$i/$j >> ec2_metadata_json_key_values.txt
			echo "\"" >> ec2_metadata_json_key_values.txt
			echo "}" >> ec2_metadata_json_key_values.txt
		else 
			curl http://169.254.169.254/latest/meta-data/$i/$j > temp2.txt
			for k in `cat temp2.txt`; 
			do
			if [[ "$k" !=  *"/" ]]; then
				echo -ne "{\n\"$k\" : \"" >> ec2_metadata_json_key_values.txt
				curl http://169.254.169.254/latest/meta-data/$i/$j/$k >> ec2_metadata_json_key_values.txt				
				echo "\"" >> ec2_metadata_json_key_values.txt
				echo "}" >> ec2_metadata_json_key_values.txt
				else 
				curl http://169.254.169.254/latest/meta-data/$i/$j/$k > temp3.txt
				for l in `cat temp3.txt`; 
				do
				if [[ "$l" !=  *"/" ]]; then
					echo -ne "{\n\"$l\" : \"" >> ec2_metadata_json_key_values.txt
					curl http://169.254.169.254/latest/meta-data/$i/$j/$k/$l >> ec2_metadata_json_key_values.txt				
					echo "\"" >> ec2_metadata_json_key_values.txt
					echo "}" >> ec2_metadata_json_key_values.txt
				else 
					curl http://169.254.169.254/latest/meta-data/$i/$j/$k/$l > temp4.txt
					for m in `cat temp4.txt`; 
					do

					if [[ "$m" !=  *"/" ]]; then
						echo -ne "{\n\"$m\" : \"" >> ec2_metadata_json_key_values.txt
						curl http://169.254.169.254/latest/meta-data/$i/$j/$k/$l/$m >> ec2_metadata_json_key_values.txt
						echo "\"" >> ec2_metadata_json_key_values.txt
						echo "}" >> ec2_metadata_json_key_values.txt
					else 
						curl http://169.254.169.254/latest/meta-data/$i/$j/$k/$l/$m > temp5.txt
						for n in `cat temp5.txt`; 
						do

						if [[ "$n" !=  *"/" ]]; then
							echo -ne "{\n\"$n\" : \"" >> ec2_metadata_json_key_values.txt	
							curl http://169.254.169.254/latest/meta-data/$i/$j/$k/$l/$m/$n >> ec2_metadata_json_key_values.txt					
							echo "\"" >> ec2_metadata_json_key_values.txt
							echo "}" >> ec2_metadata_json_key_values.txt
						fi
						done
					fi
					done
				fi
				done
			fi
			done
		fi
		done
	fi
done


rm -rf temp1.txt temp2.txt temp3.txt temp4.txt temp5.txt

if [ $choice == 1 ]; then
	cat ec2_metadata_json_key_values.txt
elif [ $choice == 2 ]; then
	echo "Enter the key whose value you want to find: "
	read key
	echo
	echo "Output::"
	echo
	grep "$key" ec2_metadata_json_key_values.txt | sed 's/\"//g' | sed 's/^ *//g' | sed 's/,//g'

	if [ $? != 0 ]; then
		echo "Key doesn't exists!"
	fi
else
	echo "Invalid Choice, Exiting!!!"
	exit;
fi


