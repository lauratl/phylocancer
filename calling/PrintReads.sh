#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 8
#SBATCH -t 40:00:00
#SBATCH --mem 100G
#SBATCH -p thinnodes,thin-shared


# Reading config

source ReadConfig.sh $1

# Loading modules

module load gatk/3.7

# Selecting samples

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

# Commands

DBSNP=${RESDIR}/dbsnp_138.${REF}.vcf
MILLS=${RESDIR}/Mills_and_1000G_gold_standard.indels.${REF}.vcf
MILGEN=${RESDIR}/1000G_phase1.indels.${REF}.sites.vcf


time(java -jar $GATK -T PrintReads -I ${WORKDIR}/${SAMPLE}.nodup.bam -nct 8 -BQSR ${WORKDIR}/${SAMPLE}.recal.table -o ${WORKDIR}/${SAMPLE}.recal.bam -R ${RESDIR}/${REF}.fasta)


echo "FINISHED"
