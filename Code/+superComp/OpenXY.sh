#!/bin/bash

EMAIL=$1
JOB_NAME=$2
SEND_BEGIN=$3
SEND_END=$4
SEND_FAIL=$5
NUM_JOBS=$6
JOB_TIME=$7
JOB_MEMORY=$8

COMMAND="--array=1-$NUM_JOBS --time=$JOB_TIME --mem-per-cpu=$JOB_MEMORY -J $JOB_NAME "

EMAIL_COMMAND=""

if [ "$EMAIL" != "" ]
then
	EMAIL_COMMAND="--mail-user=$EMAIL "
	if [ "$SEND_BEGIN" == "y" ]
	then
		EMAIL_COMMAND="$EMAIL_COMMAND --mail-type=BEGIN "
	fi
	if [ "$SEND_END" == "y" ]
	then
		EMAIL_COMMAND="$EMAIL_COMMAND --mail-type=END "
	fi
	if [ "$SEND_FAIL" == "y" ]
	then
		EMAIL_COMMAND="$EMAIL_COMMAND --mail-type=FAIL "
	fi

	if [ "$EMAIL_COMMAND" != "" ]
	then
		COMMAND="$COMMAND $EMAIL_COMMAND "
	fi
fi

JOB_ID=$(sbatch $COMMAND jobScript.sh)

echo "Submitted batch job $JOB_ID"

sbatch --dependency=afterok:$JOB_ID $EMAIL_COMMAND compile.sh $JOB_NAME