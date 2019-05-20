#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 24:00:00
#SBATCH --mem 100G
#SBATCH -p fatnode,thin-shared



# Reading config

source ReadConfig.sh $1

# Loading modules

module load picard/2.2.1
module load picard/2.18.14 # modified 21/01/2019


# Selecting samples

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

# Commands

mkdir -p ${WORKDIR}/${SAMPLE}_Temp

#time(java -jar $PICARD MarkDuplicates I=${WORKDIR}/${SAMPLE}.sorted.bam O=${WORKDIR}/${SAMPLE}.nodup.bam CREATE_INDEX=true TMP_DIR=${WORKDIR}/${SAMPLE}_Temp METRICS_FILE=${WORKDIR}/${SAMPLE}.MarkDuplicatesMetrics.txt VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=TRUE)

time(java -jar $EBROOTPICARD/picard.jar MarkDuplicates I=${WORKDIR}/${SAMPLE}.sorted.bam O=${WORKDIR}/${SAMPLE}.nodup.bam CREATE_INDEX=true TMP_DIR=${WORKDIR}/${SAMPLE}_Temp METRICS_FILE=${WORKDIR}/${SAMPLE}.MarkDuplicatesMetrics.txt VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=TRUE)
# modified 21/01/2019
echo "FINISHED"
