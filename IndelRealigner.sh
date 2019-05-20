#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 40:00:00
#SBATCH --mem 100G
#SBATCH -p thinnodes,thin-shared


# Reading config

source ReadConfig.sh $1

# Loading modules

module load gatk/3.7

# Selecting samples and chromosomes


SAMPLES=$(awk -v dir=$WORKDIR '{printf "-I "; printf dir; printf "/"; printf $0; printf ".recal.bam "}' ${WORKDIR}/${SAMPLELIST} | tr '\n' ' ') #We select all the samples to create common realignment targets, so no job array variable is entered here. The variable includes the -I to enter every sample.

CHR=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${RESDIR}/${REF}.chrs) # We select the chromosome using the job array task id variable

# Creating map file

cd ${WORKDIR}  # nWayOut may not understand it with the absolute paths
awk -v dir=$WORKDIR -v chr=$CHR '{print $0".recal.bam\t"$0".realign."chr".bam"}' ${WORKDIR}/${SAMPLELIST} > ${WORKDIR}/nWayOut.${CHR}.map

# Commands

DBSNP=${RESDIR}/dbsnp_138.${REF}.vcf
MILLS=${RESDIR}/Mills_and_1000G_gold_standard.indels.${REF}.sites.vcf
MILGEN=${RESDIR}/1000G_phase1.indels.${REF}.sites.vcf


time(java -jar $GATK -T IndelRealigner $SAMPLES -known $MILLS -known $MILGEN -targetIntervals ${WORKDIR}/IndelRealignment.${CHR}.intervals -R ${RESDIR}/${REF}.fasta -L $CHR --nWayOut ${WORKDIR}/nWayOut.${CHR}.map)

rm ${WORKDIR}/nWayOut.${CHR}.map

echo "FINISHED"


