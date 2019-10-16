#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 30:00:00
#SBATCH --mem 50G
#SBATCH -p thin-shared

# Reading config

source ReadConfig.sh $1

# Loading modules

#module load cutadapt/1.14
module load gcc/6.4.0 cutadapt/1.18-python-2.7.15 #modified 22/01/2019

# Selecting samples

#SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST}Full | cut -f1)

# Checking the memory 

#source /opt/cesga/modules-util/top.sh

# Commands
ADAPTERS_FILE=${RESDIR}/AdaptersByLibrary
ADAPTER_FORWARD=`awk -F " " -v library=$LIBRARY '{if ($1 == library) {print $2}}' $ADAPTERS_FILE`
ADAPTER_REVERSE=`awk -F " " -v library=$LIBRARY '{if ($1 == library) {print $3}}' $ADAPTERS_FILE`

time(cutadapt -m 70 -a $ADAPTER_FORWARD -A $ADAPTER_REVERSE -o ${WORKDIR}/${SAMPLE}_1.trimmed.fastq.gz -p ${WORKDIR}/${SAMPLE}_2.trimmed.fastq.gz ${ORIDIR}/${SAMPLE}_1.fastq.gz ${ORIDIR}/${SAMPLE}_2.fastq.gz > ${WORKDIR}/${SAMPLE}.Cutadapt.log)

#echo $ADAPTER_FORWARD
#echo $ADAPTER_REVERSE

echo "FINISHED"
