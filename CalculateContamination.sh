#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 05:00:00
#SBATCH --mem 30G
#SBATCH -p thin-shared,cola-corta


# Reading config

source ReadConfig.sh $1


# Loading modules

#module load gatk/4.0.0.0
#module load gatk/4.0.10.0 # modified 21/01/2019

# Changed 20/05/2019 due to incompatibilities of CalculateContamination output with the new FilterMutectCalls:
module load jdk/8u181  
GATK=/mnt/netapp1/posadalab/APPS/gatk-4.1.1.0/gatk

# Selecting samples  (this selection by chromosome is for mutect2, not for this script)

#nchrs=`cat ${RESDIR}/${REF}.chrs | wc -l`     # Total number of chromosomes

#nchr=$(( ((${SLURM_ARRAY_TASK_ID}-1)%${nchrs})+1 )) # Get the number of the chromosome for this run
#ntum=$(( ((${SLURM_ARRAY_TASK_ID}-1)/${nchrs})+1 )) # Get the number of the tumor sample for this run


TUMOR=$(diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2|sed "${SLURM_ARRAY_TASK_ID}q;d")
#CHR=$(sed "${nchr}q;d" ${RESDIR}/${REF}.chrs)
HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`


# Commands

time(

$GATK GetPileupSummaries \
-I ${WORKDIR}/${TUMOR}.recal.bam \
-V ${RESDIR}/small_exac_common_3_b37.vcf.gz \
--intervals ${RESDIR}/b37.bed \
-O ${WORKDIR}/${TUMOR}.recal.bam_getpileupsummaries.GATK-4.1.1.0.table

$GATK CalculateContamination \
-I ${WORKDIR}/${TUMOR}.recal.bam_getpileupsummaries.GATK-4.1.1.0.table \
-O ${WORKDIR}/${TUMOR}.recal.bam_calculatecontamination.GATK-4.1.1.0.table

)


echo "FINISHED"
