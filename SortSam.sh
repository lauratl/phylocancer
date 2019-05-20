#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 30:00:00
#SBATCH --mem 50G
#SBATCH -p fatnode,thin-shared


# Reading config

source ReadConfig.sh $1
#source /home/uvi/be/ltl/bin/ReadConfig.sh $1

# Loading modules

#module load picard/2.2.1
module load picard/2.18.14 #modified 21/01/2019

# Selecting samples


SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

# Commands


#time(java -jar $PICARD SortSam I=${WORKDIR}/${SAMPLE}.bam TMP_DIR=${WORKDIR} O=${WORKDIR}/${SAMPLE}.sorted.bam CREATE_INDEX=true SORT_ORDER=coordinate)

time(java -jar $EBROOTPICARD/picard.jar SortSam I=${WORKDIR}/${SAMPLE}.sam TMP_DIR=${WORKDIR} O=${WORKDIR}/${SAMPLE}.sorted.bam CREATE_INDEX=true SORT_ORDER=coordinate)
#MODIFIED 21/01/2019

echo "FINISHED"
