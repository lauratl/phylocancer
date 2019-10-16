#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopezslurm@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 20:00:00
#SBATCH --mem 50G
#SBATCH -p thin-shared


# Reading config

source ReadConfig.sh $1

# Loading modules

#module load gatk/4.0.0.0
module load gatk/4.0.10.0 # modified 21/01/2019

# Selecting samples

SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${WORKDIR}/${SAMPLELIST})

# Commands

DBSNP=${RESDIR}/dbsnp_138.${REF}.vcf
MILLS=${RESDIR}/Mills_and_1000G_gold_standard.indels.${REF}.sites.vcf
MILGEN=${RESDIR}/1000G_phase1.indels.${REF}.sites.vcf

time(

gatk BaseRecalibrator \
    -R ${RESDIR}/${REF}.fasta \
    -I ${WORKDIR}/${SAMPLE}.nodup.bam \
    --known-sites ${RESDIR}/dbsnp_138.${REF}.vcf \
    --known-sites ${RESDIR}/Mills_and_1000G_gold_standard.indels.${REF}.vcf \
    -O ${WORKDIR}/${SAMPLE}.recal.table
)


echo "FINISHED"




