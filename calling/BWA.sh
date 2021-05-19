#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopezslurm@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 8 
#SBATCH -t 4:00:00
#SBATCH --mem 50G
#SBATCH -p shared
#SBATCH --qos shared 

# Reading config

source ReadConfig.sh $1

# Loading modules

#module load intel/2016 bwa/0.7.15
module load gcc/6.4.0 bwa/0.7.17       # modified 21/01/2019

# Selecting samples

# Uncomment for one fastq per sample:
#SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})
#FASTQ=$SAMPLE

# Uncomment for several fastq per sample:
FASTQ=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST}Full | cut -f1)
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST}Full | cut -f2)

# Commands
RG="@RG\\tID:${FASTQ}\\tSM:${SAMPLE}\\tLB:${LIBRARY}\\tPL:ILLUMINA"

time(bwa mem -t 8 -M -R ${RG} ${RESDIR}/${REF}.fasta ${WORKDIR}/${FASTQ}_1.trimmed.fastq.gz ${WORKDIR}/${FASTQ}_2.trimmed.fastq.gz > ${WORKDIR}/${FASTQ}.sam)


echo "FINISHED"
