#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopezslurm@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 00:10:00
#SBATCH --mem 30G
#SBATCH -p shared
#SBATCH --qos shared


# Reading config

source ReadConfig.sh $1

# Loading modules

module load picard/2.18.14


# Selecting samples


CHR=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${RESDIR}/${REF}.chrs) # We select the chromosome using the job array task id variable
HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`
SAMPLES=$( diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2 | awk -v healthyname=${HEALTHY} -v chr=${CHR} -v dir=$WORKDIR 'BEGIN{printf "-I "dir"/"healthyname".recal.bam "}{printf "-I "dir"/"$0".recal.bam "}' | tr '\n' ' ') #We select all the samples to pass them to MultiSNV


# Commands

INPUTS=$(for i in {1..22}; do 
echo "I="${WORKDIR}/Mutect2_mseq.$i.${PATIENT}.filtered.vcf" "; 
done; 
echo "I="${WORKDIR}/Mutect2_mseq.X.${PATIENT}.filtered.vcf " "; 
echo "I="${WORKDIR}/Mutect2_mseq.Y.${PATIENT}.filtered.vcf " "; 
echo "I="${WORKDIR}/Mutect2_mseq.MT.${PATIENT}.filtered.vcf " ";)

java -jar $EBROOTPICARD/picard.jar MergeVcfs \
	$INPUTS \
	D=${RESDIR}/${REF}.dict \
	O=${WORKDIR}/${PATIENT}.vcf \







echo "FINISHED"
