#!/bin/bash

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
    -a|--aircam)
    AC="$2"
	shift # past argument
	shift # past value
    ;;
    -v|--vehicle)
    VEHICLE="$2"
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
echo "host will be {$HOST}"

# Get aircam 
if [ -z "$AC" ] ; then
    echo "aircam not specified, assuming script was ran from desired aircam root"
	AC_ROOT="$PWD/"
elif [[ $AC == "0" ]] ; then
	AC_ROOT="/home/skydio/aircam/"
elif [[ $AC == "1" ]] ; then
	AC_ROOT="/home/skydio/aircam1/"
elif [[ $AC == "2" ]] ; then
	AC_ROOT="/mnt/data0/aircam2/"
elif [[ $AC == "3" ]] ; then
	AC_ROOT="/mnt/data0/aircam3/"
else
	echo "Unknown aircam specified {$AC}"
	exit 2
fi

FP_REL_PATH="build/images/"
FP_BASE_NAME="flashpack_R28.2.0_arm64_"

# Set default identity file if not set.
if [ -z "$IDENTITY" ]
then
    IDENTITY="${AC_ROOT}infrastructure/vehicle_admin_id_rsa"
    echo "Defaulting to this aircam's identity file: {$IDENTITY}"
fi


# Apply vehicle type
if [[ $VEHICLE == "r3" ]] || [[ -z $VEHICLE ]] ; then
	echo "Using r3 flashpack"
	FP_VEHICLE_TYPE="r3_prod"
elif [[ $VEHICLE == "e1" ]] ; then
	echo "Using e1 flashpack"
	FP_VEHICLE_TYPE="e1_prod"
else
	echo "Unrecognized vehicle type {$VEHICLE}. Should be one of {r3, e1}"
fi

FLASHPACK_PATH="$AC_ROOT$FP_REL_PATH$FP_BASE_NAME$FP_VEHICLE_TYPE"

COMMAND="$FLASHPACK_PATH ota-direct --target $HOST --identity $IDENTITY"

echo "\nRunning command..."
echo "$COMMAND"

eval $COMMAND

