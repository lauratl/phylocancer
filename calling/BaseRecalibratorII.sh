#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopezslurm@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1 
#SBATCH -t 10:00:00
#SBATCH --mem 50G
#SBATCH -p shared
#SBATCH --qos shared

# Reading config

source ReadConfig.sh $1

# Loading modules

#module load gatk/4.0.0.0
module load gatk/4.0.10.0 # modified 21/01/2019


# Selecting samples

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

# Commands



time(
gatk ApplyBQSR \
        -I ${WORKDIR}/${SAMPLE}.nodup.bam \
        --bqsr-recal-file ${WORKDIR}/${SAMPLE}.recal.table \
        -O ${WORKDIR}/${SAMPLE}.recal.bam \
        -R ${RESDIR}/${REF}.fasta
)

echo "FINISHED"
