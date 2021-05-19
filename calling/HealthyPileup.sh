#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 05:00:00
#SBATCH --mem 30G
#SBATCH -p thin-shared


# Reading config

source ReadConfig.sh $1


# Loading modules

module load jdk/8u181  
GATK=/mnt/netapp1/posadalab/APPS/gatk-4.1.3.0/gatk


HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`



# Commands

time(

$GATK GetPileupSummaries \
-I ${WORKDIR}/${HEALTHY}.recal.bam \
-V ${RESDIR}/small_exac_common_3_b37.vcf.gz \
--intervals ${RESDIR}/b37.bed \
-output ${WORKDIR}/${HEALTHY}.recal.bam_getpileupsummaries.GATK-4.1.3.0.table

)


echo "FINISHED"
