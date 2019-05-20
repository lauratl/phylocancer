#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 30:00:00
#SBATCH --mem 100G
#SBATCH -p thinnodes,thin-shared,fatnode


# Reading config

source ReadConfig.sh $1

# Loading modules

module load picard/2.2.1

# Selecting samples

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

# Commands

mkdir -p ${WORKDIR}/${SAMPLE}_Temp

time(java -jar $PICARD MarkDuplicatesWithMateCigar I=${WORKDIR}/${SAMPLE}.sorted.bam O=${WORKDIR}/${SAMPLE}.nodupmate.bam CREATE_INDEX=true TMP_DIR=${WORKDIR}/${SAMPLE}_Temp METRICS_FILE=${WORKDIR}/${SAMPLE}.MarkDuplicatesMateMetrics.txt VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=TRUE)


echo "FINISHED"
