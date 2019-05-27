#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1 
#SBATCH -t 10:00:00
#SBATCH --mem 100G
#SBATCH -p shared,gpu-shared-k2
#SBATCH --qos shared 





# Reading config

source ReadConfig.sh $1

# Loading modules

module load intel/2016 
module load python/2.7.12
module load samtools/1.3
module load gcc/6.3.0 
module load pypy2/5.8.0

SLURM_ARRAY_TASK_ID=1
# Selecting samples

HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`  # Assuming only one healthy sample

nchrs=`cat ${RESDIR}/${REF}.chrs | wc -l`     # Get the total number of chromosomes
ntumors=`diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<'| wc -l`  # Get the total number of tumor samples

nchr=$(( ((${SLURM_ARRAY_TASK_ID}-1)%${nchrs})+1 ))    # Get the number of the chromosome for this run
ntum=$(( ((${SLURM_ARRAY_TASK_ID}-1)/${nchrs})+1 ))    # Get the number of the tumor sample for this run


TUMOR=$(diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2|sed "${ntum}q;d") # Select the tumor sample
CHR=$(sed "${nchr}q;d" ${RESDIR}/${REF}.chrs)   #Select the chromosome  # ADD chrs.${REF} FOR CESGA

echo "Healthy sample is $HEALTHY"
echo "Tumor sample is $TUMOR"
echo "Chromosome is $CHR"

# Selecting auxiliar files

GCFILE=${RESDIR}/${REF}.gc5Base.txt.gz

# Checking the memory

#source /opt/cesga/modules-util/top.sh   


# Commands

#SEQUTILS_SCRIPT=${SCRIPTDIR}/sequenza-utils.py
SEQUTILS_SCRIPT=$HOME/R/x86_64-pc-linux-gnu-library/3.3/sequenza/exec/sequenza-utils.py
time(pypy $SEQUTILS_SCRIPT bam2seqz -gc $GCFILE \
        --fasta ${RESDIR}/${REF}.fasta \
        -n ${WORKDIR}/${HEALTHY}.${TUMOR}.realign.bam \
        -t ${WORKDIR}/${TUMOR}.${HEALTHY}.realign.bam \
        --chromosome ${CHR} | gzip > ${WORKDIR}/${TUMOR}_${HEALTHY}.${CHR}.seqz.gz)



echo "FINISHED"
