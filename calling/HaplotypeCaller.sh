#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopezslurm@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 100:00:00
#SBATCH --mem 100G
#SBATCH -p shared
#SBATCH --qos shared


#It was -p thin-shared

# Chr1 ~40x 57% 10hours
# Change to 30h and from shared_short to thin-shared
# Change to 40h
# Change to 50h for chr1 and 2 CRC02

# Reading config

source ReadConfig.sh $1

# Loading modules

module load jdk/8u181
GATK=/mnt/netapp1/posadalab/APPS/gatk-4.1.1.0/gatk


# Selecting samples

HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`


# Commands


time(

$GATK --java-options "-Xmx4g" HaplotypeCaller  \
   -R ${RESDIR}/${REF}.fasta \
   -I ${WORKDIR}/${HEALTHY}.recal.bam \
   -O ${WORKDIR}/${HEALTHY}.HaplotypeCaller.vcf.gz \
   -ERC NONE


)



echo "FINISHED"
