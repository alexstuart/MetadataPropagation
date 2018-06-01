#!/bin/bash
#
# Takes the raw data file with triples of timestamp, entityID, HTTP return code,
# runs it through first200.pl (to determine the first occurence of HTTP 200 success),
# and then through increasing.pl (to record timestamps when number increases).
#

INFILE=$1

if [ -z "$1" ]
then
	echo "Usage: $0 <results file>"
	exit 1
fi

./first200.pl $INFILE | ./increasing.pl > ${INFILE}.processed


