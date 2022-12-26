#!/bin/bash


url="http://169.254.169.254/latest/meta-data/"

imds_version=$(curl $url| wc -l)
echo 

# Code to identify if IMDS is version 1 or 2

if [ "$imds_version" != 0 ]; then
	echo "Its IMDSv1"
	metadata_command="curl http://169.254.169.254/latest/meta-data/"
else
	echo "Its IMDSv2"
	TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
	metadata_command=$(echo "curl -H \"X-aws-ec2-metadata-token: \$TOKEN\" -v http://169.254.169.254/latest/meta-data/")

fi

echo
echo
echo -e "Please choose option: \n\n1. Display whole metadata in Json Format\n2. Search for a particular data key's value\n\nEnter your choice: "
read choice

echo -e "{" > ec2_metadata_json_key_values.txt

eval "$metadata_command" > ec2_metadata.txt

for i in `cat ec2_metadata.txt`;
do
        # Condition to filter metadata without subsequent path
        if [[ "$i" !=  *"/" ]]; then

                echo -ne "\t\"$i\": \""  >> ec2_metadata_json_key_values.txt # Json Formatting
                eval "$metadata_command/$i" >> ec2_metadata_json_key_values.txt
                echo -ne "\",\n" >> ec2_metadata_json_key_values.txt

        else
                # Temporary file to store subsequent path if above condition is not met
                echo -ne "\t\"$i\": {\n" | sed 's#/##g' >> ec2_metadata_json_key_values.txt
                eval "$metadata_command/$i" > temp1.txt
                
                # Recursively fetch one row at a time from temporary file
                for j in `cat temp1.txt`;
                do
                if [[ "$j" !=  *"/" ]]; then
                        echo -ne "\t\t\"$j\": \"" >> ec2_metadata_json_key_values.txt
                        eval "$metadata_command/$i/$j" >> ec2_metadata_json_key_values.txt
                        echo -ne "\",\n" >> ec2_metadata_json_key_values.txt                        
                        
                else
                        echo -ne "\t\t\"$j\": {\n" | sed 's#/##g' >> ec2_metadata_json_key_values.txt
                        eval "$metadata_command/$i/$j" > temp2.txt
                        for k in `cat temp2.txt`;
                        do
                        if [[ "$k" !=  *"/" ]]; then
                                echo -ne "\t\t\t\"$k\": \"" >> ec2_metadata_json_key_values.txt
                                eval "$metadata_command/$i/$j/$k" >> ec2_metadata_json_key_values.txt
                                echo -ne "\",\n" >> ec2_metadata_json_key_values.txt                                
                                
                        else
                                echo -ne "\t\t\t\"$k\": {\n" | sed 's#/##g' >> ec2_metadata_json_key_values.txt
                                eval "$metadata_command/$i/$j/$k" > temp3.txt
                                for l in `cat temp3.txt`;
                                do
                                if [[ "$l" !=  *"/" ]]; then
                                        echo -ne "\t\t\t\t\"$l\": \"" >> ec2_metadata_json_key_values.txt
                                        eval "$metadata_command/$i/$j/$k/$l" >> ec2_metadata_json_key_values.txt
                                        echo -ne "\",\n" >> ec2_metadata_json_key_values.txt
                                                                               
                                else
                                        echo -ne "\t\t\t\t\"$l\": {\n" | sed 's#/##g' >> ec2_metadata_json_key_values.txt
                                        eval "$metadata_command/$i/$j/$k/$l" > temp4.txt
                                        for m in `cat temp4.txt`;
                                        do

                                        if [[ "$m" !=  *"/" ]]; then
                                                echo -ne "\t\t\t\t\t\"$m\": \"" >> ec2_metadata_json_key_values.txt
                                                eval "$metadata_command/$i/$j/$k/$l/$m" >> ec2_metadata_json_key_values.txt
                                                echo -ne "\",\n" >> ec2_metadata_json_key_values.txt
                                                                                            
                                        else
                                                echo -ne "\t\t\t\t\t\"$m\": {\n" | sed 's#/##g' >> ec2_metadata_json_key_values.txt
                                                eval "$metadata_command/$i/$j/$k/$l/$m" > temp5.txt
                                                for n in `cat temp5.txt`;
                                                do

                                                if [[ "$n" !=  *"/" ]]; then
                                                        echo -ne "\t\t\t\t\t\t\"$n\": \"" >> ec2_metadata_json_key_values.txt
                                                        eval "$metadata_command/$i/$j/$k/$l/$m/$n" >> ec2_metadata_json_key_values.txt
                                                        echo -ne "\",\n" >> ec2_metadata_json_key_values.txt
                                                        echo -e "\t\t\t\t\t\t}" >> ec2_metadata_json_key_values.txt
                                                fi
                                                done
                                            echo -e "\t\t\t\t\t}" >> ec2_metadata_json_key_values.txt
                                        fi
                                        done
                                        echo -e "\t\t\t\t}" >> ec2_metadata_json_key_values.txt
                                fi
                                done
                            echo -e "\t\t\t}" >> ec2_metadata_json_key_values.txt
                        fi
                        done
                    echo -e "\t\t}" >> ec2_metadata_json_key_values.txt
                fi
                done
            echo -e "\t}," >> ec2_metadata_json_key_values.txt
        fi
done

echo "}" >> ec2_metadata_json_key_values.txt


sed -i  ':a;N;$!ba;s/,\n}/\n}/g' ec2_metadata_json_key_values.txt 
sed -i 's/"{/{/g'   ec2_metadata_json_key_values.txt
sed -i 's/}"/}/g' ec2_metadata_json_key_values.txt
sed -i  ':a;N;$!ba;s/,\n\t[\t]*}/\n\t\t}/g' ec2_metadata_json_key_values.txt

#Cleanup temp dir
rm -rf temp1.txt temp2.txt temp3.txt temp4.txt temp5.txt

if [ $choice == 1 ]; then
		echo
		echo "Metadata Output:::"
		echo
        cat ec2_metadata_json_key_values.txt
elif [ $choice == 2 ]; then
                echo
        echo "Enter the key whose value you want to find: "
        read key
        echo
        echo "Output::"
        echo
        grep "$key" ec2_metadata_json_key_values.txt | sed 's/\"//g' | sed 's/^ *//g' | sed 's/^\t*//g' | sed 's/,//g'
                echo

        if [ $? != 0 ]; then
                echo "Key doesnt exists!"
        fi
else
        echo
                echo "Invalid Choice, Exiting!!!"
                echo
        exit;
fi

