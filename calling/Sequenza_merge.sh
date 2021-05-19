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

module load miniconda2

conda activate /mnt/netapp2/Store_uni/home/uvi/be/ltl/CONDA_ENVIRONMENTS/sequenza_laura


# Selecting sample   


TUMOR=$(diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2|sed "${SLURM_ARRAY_TASK_ID}q;d")




# Commands


SEQZ_FILES=$(awk -v prefix=${WORKDIR}/${TUMOR} '{printf prefix"."$0".out.seqz.gz "}' ${RESDIR}/${REF}.chrs)

time(

zcat $SEQZ_FILES | \
    gawk '{if (NR!=1 && $1 != "chromosome") {print $0}}' | bgzip > \
    ${WORKDIR}/${TUMOR}.out.seqz.gz
tabix -f -s 1 -b 2 -e 2 -S 1 ${WORKDIR}/${TUMOR}.out.seqz.gz



)



