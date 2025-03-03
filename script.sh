#!/bin/bash

# It is used to get the longest time response and unique endpoints response
# from the log file.

INPUT_FILE=logfile.log
OUTPUT_FILE=output.txt

echo -e "Longest Time Response\n" > $OUTPUT_FILE
grep -oE " in [0-9]+ms" $INPUT_FILE | sort -k2 -nr | head -1 | grep -f - -B1 $INPUT_FILE >> $OUTPUT_FILE

echo -e "\nUnique Endpoints Response\n" >> $OUTPUT_FILE
grep -oE "[A-Z]{3,7} \"/.+\"" $INPUT_FILE | sed "s/?.*\"/\"/" | sort | uniq -c | sort -k1 -nr >> $OUTPUT_FILE
