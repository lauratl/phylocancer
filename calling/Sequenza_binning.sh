#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 08:00:00
#SBATCH --mem 30G
#SBATCH -p thin-shared,cola-corta


# Reading config

source ReadConfig.sh $1


# Loading modules

module load miniconda2

conda activate /mnt/netapp2/Store_uni/home/uvi/be/ltl/CONDA_ENVIRONMENTS/sequenza_laura


# Selecting samples  (this selection by chromosome is for mutect2, not for this script)

#nchrs=`cat ${RESDIR}/${REF}.chrs | wc -l`     # Total number of chromosomes

#nchr=$(( ((${SLURM_ARRAY_TASK_ID}-1)%${nchrs})+1 )) # Get the number of the chromosome for this run
#ntum=$(( ((${SLURM_ARRAY_TASK_ID}-1)/${nchrs})+1 )) # Get the number of the tumor sample for this run


TUMOR=$(diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2|sed "${SLURM_ARRAY_TASK_ID}q;d")
#CHR=$(sed "${nchr}q;d" ${RESDIR}/${REF}.chrs)
HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`


# Commands


time(


sequenza-utils seqz_binning \
	-s ${WORKDIR}/${TUMOR}.out.seqz.gz \
	-w 50 \
	-o ${WORKDIR}/${TUMOR}.out.small.seqz.gz


)


