#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopezslurm@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 10:00:00
#SBATCH --mem 30G
#SBATCH -p cola-corta

# Reading config

source ReadConfig.sh $1

# Loading modules

#module load gcc/5.3.0
#module load samtools/1.3.1

module load gcc/6.4.0 samtools/1.9   # modified 21/01/2019 


# Selecting samples

#SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${CONTROL})


# Commands

#time(samtools depth ${WORKDIR}/${SAMPLE}.sorted.bam > ${WORKDIR}/${SAMPLE}.sorted.bam.depth)
time(samtools depth ${WORKDIR}/${SAMPLE}.recal.bam > ${WORKDIR}/${SAMPLE}.recal.bam.depth)

echo "FINISHED"

