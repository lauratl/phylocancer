#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 20:00:00
#SBATCH --mem 100G
#SBATCH -p shared
#SBATCH --qos shared


# Reading config

source ReadConfig.sh $1


# Loading modules

module load gatk/3.7
module load gcc/5.3.0 samtools/1.6

# Selecting samples and chromosomes


TUMOR=$(diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2|sed "${SLURM_ARRAY_TASK_ID}q;d")

HEALTHY=${WORKDIR}/${PATIENT}.HealthySamples.bam



echo "Healthy sample is $HEALTHY"
echo "Tumor sample is $TUMOR"





# Selecting auxiliar files    #### CHANGE FOR CESGA

DBSNP="${RESDIR}/dbsnp_138.b37.vcf"
HAPMAP="${RESDIR}/hapmap_3.3.b37.vcf

# Checking the memory

#source /opt/cesga/modules-util/top.sh    #Only for Cesga


# Commands

time(gatk ContEst -R ${RESDIR}/${REF}.fasta -I:eval ${WORKDIR}/${TUMOR}.merged.bam -I:genotype ${WORKDIR}/${HEALTHY} --popfile $HAPMAP -isr INTERSECTION -o ${WORKDIR}/${TUMOR}.ContEst.txt)


echo "FINISHED"

