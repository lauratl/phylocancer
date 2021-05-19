#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 03:00:00
#SBATCH --mem 30G
#SBATCH -p thin-shared,cola-corta


# Reading config

source ReadConfig.sh $1


# Loading modules



module load gcc/6.4.0 R/4.0.2


# Selecting samples  (this selection by chromosome is for mutect2, not for this script)

#nchrs=`cat ${RESDIR}/${REF}.chrs | wc -l`     # Total number of chromosomes

#nchr=$(( ((${SLURM_ARRAY_TASK_ID}-1)%${nchrs})+1 )) # Get the number of the chromosome for this run
#ntum=$(( ((${SLURM_ARRAY_TASK_ID}-1)/${nchrs})+1 )) # Get the number of the tumor sample for this run


TUMOR=$(diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2|sed "${SLURM_ARRAY_TASK_ID}q;d")
#CHR=$(sed "${nchr}q;d" ${RESDIR}/${REF}.chrs)
HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`


# Commands


mkdir -p ${WORKDIR}/Sequenza/${TUMOR}/
time(

Rscript --vanilla ${SCRIPTDIR}/SequenzaR.R $WORKDIR $TUMOR 


)




