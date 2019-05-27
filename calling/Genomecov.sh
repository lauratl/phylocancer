#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopezslurm@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 30:00:00
#SBATCH --mem 100G
#SBATCH -p fatnode,thin-shared


# Reading config

source ReadConfig.sh $1


# Loading modules

#module load gcc/5.3.0
#module load bedtools/2.26.0

module load cesga/2018 gcccore/6.4.0 bedtools/2.27.1 # modified 21/01/2019


# Selecting samples and chromosomes



SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

# Selecting auxiliar files



# Checking the memory

#source /opt/cesga/modules-util/top.sh    #Only for Cesga


# Commands

time(bedtools genomecov -ibam ${WORKDIR}/${SAMPLE}.sorted.bam -g ${RESDIR}/${REF}.fasta > ${WORKDIR}/${SAMPLE}.genomecov)


echo "FINISHED"

