#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 10:00:00
#SBATCH --mem 100G
#SBATCH -p thinnodes,fatnode,thin-shared,cola-corta


# Reading config

source ReadConfig.sh $1


# Loading modules

module load gcc/5.3.0 samtools/1.6

# Selecting samples and chromosomes


SAMPLES=""

set -f
IFS='
'

TUMOR=$(diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2|sed "${SLURM_ARRAY_TASK_ID}q;d")

for j in $(cat ${RESDIR}/${REF}.chrs); do

sample=$TUMOR".realign."$j".bam"
SAMPLES=$SAMPLES" "${WORKDIR}"/"${sample}

done




# Selecting auxiliar files



# Checking the memory

#source /opt/cesga/modules-util/top.sh    #Only for Cesga


# Commands

time(samtools merge ${WORKDIR}/${TUMOR}.merged.bam $SAMPLES )


echo "FINISHED"

