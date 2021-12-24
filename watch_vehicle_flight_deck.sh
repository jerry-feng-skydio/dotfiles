#!/bin/bash

# Default to 100 lines.
NUM_LINES=100

POSITIONAL=()
while [[ $# -gt 0 ]]
do 
key="$1"

case $key in
	-w|--wifi)
	WIFI=1
	shift # past argument
	;;
	-t|--target)
	TARGET="$2"
	shift # past argument
	shift # past value
	;;
    -i|--identity)
    IDENTITY="$2"
	shift # past argument
	shift # past value
	;;
	-n|--num_lines)
	NUM_LINES="$2"
	shift # past argument
	shift # past value
	;;
    -g|--grep)
    GREP_PATTERN="$2"
	shift # past argument
	shift # past value
    ;;
	*)    # Unknown option
	POSITIONAL+=("$1") # Save it in an array for later
	shift # past argument
	;;
esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

# Apply wifi if target is not set
if [ ! -z "$WIFI" ]
then
    if [ ! -z "$TARGET" ]
    then 
        echo "Both wifi and target were set. Using specified target instead!"
    else
        HOST="192.168.10.1"
    fi
fi

# Apply target if set
if [ ! -z "$TARGET" ]
then
    HOST=${TARGET}
fi

# Apply default host if not yet set
if [ -z "$HOST" ]
then
    echo "Using default host!"
    HOST="192.168.11.1"
fi

if [ ! -z "$IDENTITY" ]
then
    echo "Using identity file $IDENTITY"
    IDENTITY_ARG="-i $IDENTITY"
fi

LOG_FILE=/home/skydio/semi_persistent/process_logs/latest/flight_deck.txt

ssh -t aircam@${HOST} ${IDENTITY_ARG} watch -n 0.1 tail -n ${NUM_LINES} ${LOG_FILE}
