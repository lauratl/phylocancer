#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopezslurm@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 8 
#SBATCH -t 80:00:00
#SBATCH --mem 100G
#SBATCH -p thin-shared,fatnode

# Reading config

source ReadConfig.sh $1

# Loading modules

#module load intel/2016 bwa/0.7.15
module load gcc/6.4.0 bwa/0.7.17       # modified 21/01/2019

# Selecting samples

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

# Commands
RG="@RG\\tID:${SAMPLE}\\tSM:${SAMPLE}\\tLB:${LIBRARY}\\tPL:ILLUMINA"

time(bwa mem -t 8 -M -R ${RG} ${RESDIR}/${REF}.fasta ${WORKDIR}/${SAMPLE}_1.trimmed.fastq.gz ${WORKDIR}/${SAMPLE}_2.trimmed.fastq.gz > ${WORKDIR}/${SAMPLE}.sam)


echo "FINISHED"
