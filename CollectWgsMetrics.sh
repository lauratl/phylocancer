#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 5:00:00
#SBATCH --mem 20G
#SBATCH -p thinnodes,thin-shared,cola-corta

# Reading config

source ReadConfig.sh $1

# Loading modules


module load picard/2.2.1

# Selecting samples

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

java -jar $PICARD CollectWgsMetrics \
	I=${WORKDIR}/${SAMPLE}.nodup.bam \
	O=${WORKDIR}/${SAMPLE}.nodup.bam.CollectWgsMetrics \
	R=${RESDIR}/${REF}.fasta
