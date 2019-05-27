#!/bin/bash
# Read parameters from a configuration file
# Tamara Prieto 2017
# This Script must be located inside a directory included in $PATH


if [ "$#" -ne 1 ]
then
        echo "You must specify absolute path to a configuration file as argument. More info about how to create this file: ReadConfig.sh --help"
        exit
elif [ "$1" = "--help" ]
then
        echo ""
        echo "INSTRUCTIONS IN HOW TO CREATE A CONFIG FILE"
        echo ""
        echo "The config file must contain following arguments and directories must be absolute (environmental variables are not allowed):"
        echo "s | sample_list File containing one sample name per row. This file must be located in the resources directory."
        echo "c | control_list File containing the name of the control samples."
        echo "ori | original_directory Absolute path of the folder containing raw data and sample lists."
        echo "work | working_directory Absolute path to the working directory."
        echo "ref | reference_name Name of the reference genome."
        echo "res | resources_directory Absolute path of the reference and other resources directory."
        echo "script | scripts_directory Absolute path to the scripts directory"
        echo "target | target_capture Name of the file containing sequences selected in a  WES experiment or any other kind of targeted sequencing experiment."
        echo "c | control_list File containing the name of the control samples."
        echo "exc | excavator File to run excavator."
        echo ""
        echo "Example of lines in config file:"
        echo ""
        echo "sample_list=mysamples.txt"
        echo "c=mycontrols.txt"
        echo "resources_directory=/mnt/lustre/scratch/home/uvi/be/phylocancer/RESOURCES/"
        echo ""
        echo "These variables will correspond to:"
        echo '$SAMPLELIST,$CONTROL,$ORIDIR,$WORKDIR,$RESDIR,$SCRIPTDIR,$REF,$TARGET,$EXCAVATOR'
        exit
else
        if [ -e $1 ]
        then
        while read i; do
                case $i in
                s=*|sample_list=*)
                SAMPLELIST="${i#*=}"
                ;;
                c=*|control_list=*)
                CONTROL="${i#*=}"
                ;;
                ori=*|original_directory=*)
                ORIDIR="${i#*=}"
                ;;
                work=*|working_directory=*)
                WORKDIR="${i#*=}"
                ;;
                res=*|resources_directory=*)
                RESDIR="${i#*=}"
                ;;
                script=*|scripts_directory=*)
                SCRIPTDIR="${i#*=}"
                ;;
                ref=*|reference_name=*)
                REF="${i#*=}"
                ;;
                targ=*|target_capture=*)
                TARGET="${i#*=}"
                ;;
                pat=*|patient=*)
                PATIENT="${i#*=}"
                ;;
		tumolist=*|tumor_list=*)
                TUMOR="${i#*=}"
                ;;
                exc=*|excavator=*)
                EXCAVATOR="${i#*=}"
                ;;
		p=*|queue=*)
                QUEUE="${i#*=}"
                ;;
		lib=*|library=*)
		LIBRARY="${i#*=}"
		;;
                *)
                echo "$i is not a valid parameter"
                exit
                ;;
                esac
        done < $1
        else
        echo "File $1 is not in current directory or does not exist"
        exit
        fi
fi

