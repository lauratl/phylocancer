#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 10:00:00
#SBATCH --mem 100G
#SBATCH -p cola-corta

# Reading config

source ReadConfig.sh $1

# Loading modules

#module load fastqc/0.11.5
module load cesga/2018 fastqc/0.11.7  #modified 21/01/2019

# Selecting samples

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

# Commands

time(fastqc -o $WORKDIR ${ORIDIR}/${SAMPLE}_1.fastq.gz ${ORIDIR}/${SAMPLE}_2.fastq.gz)


echo "FINISHED"
