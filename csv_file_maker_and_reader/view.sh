#!/bin/bash

csv_file=$1

if [ -z "$csv_file" ]; then
	  echo "Usage: $0 <csv_file>"
	    exit 1
fi

column -s, -t < "$csv_file"
