#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 10:00:00
#SBATCH --mem 50G
#SBATCH -p shared
#SBATCH --qos shared_short



# Reading config

source ReadConfig.sh $1

# Loading modules

#module load gatk/4.0.0.0
module load gatk/4.0.10.0 # modified 21/01/2019


# Selecting samples


################################## CHECK THIS!!!!!!!!!!
nchrs=`cat ${RESDIR}/${REF}.chrs | wc -l`     # Total number of chromosomes


nchr=$(( ((${SLURM_ARRAY_TASK_ID}-1)%${nchrs})+1 )) # Get the number of the chromosome for this run
ntum=$(( ((${SLURM_ARRAY_TASK_ID}-1)/${nchrs})+1 )) # Get the number of the tumor sample for this run

TUMOR=$(diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2|sed "${ntum}q;d")
CHR=$(sed "${nchr}q;d" ${RESDIR}/${REF}.chrs)
HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`

# Commands

GERMRES=${RESDIR}/af-only-gnomad.raw.sites.b37.vcf.gz

time(
gatk --java-options "-Xmx8g" Mutect2 \
	-R ${RESDIR}/${REF}.fasta \
	-I ${WORKDIR}/${TUMOR}.recal.bam \
	-I ${WORKDIR}/${HEALTHY}.recal.bam \
	-normal ${HEALTHY} \
	-tumor ${TUMOR} \
	--germline-resource ${GERMRES} \
	--af-of-alleles-not-in-resource 0.0000025 \
	--disable-read-filter MateOnSameContigOrNoMappedMateReadFilter \
	-L ${CHR} \
	-O ${WORKDIR}/Mutect2_GATK4.${TUMOR}.${CHR}.vcf \
	-bamout ${WORKDIR}/Mutect2_GATK4.${TUMOR}.${CHR}.bamout \
        -pon ${RESDIR}/PON.${LIBRARY}.vcf \
)


echo "FINISHED"
