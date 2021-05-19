#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 10:00:00
#SBATCH --mem 30G
#SBATCH -p thin-shared,cola-corta


# Reading config

source ReadConfig.sh $1


# Loading modules

module load miniconda2

conda activate /mnt/netapp2/Store_uni/home/uvi/be/ltl/CONDA_ENVIRONMENTS/sequenza_laura


# Selecting sample and chr: call as 1-$((${ntumors}*${nchrs}))  


SAMPLE_ID=$((((${SLURM_ARRAY_TASK_ID} - 1)/25)+1))
CHR_ID=$((((${SLURM_ARRAY_TASK_ID} - 1)%25)+1))


CHR=$(sed "${CHR_ID}q;d" ${RESDIR}/${REF}.chrs) 
TUMOR=$(diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2|sed "${SAMPLE_ID}q;d")
#CHR=$(sed "${nchr}q;d" ${RESDIR}/${REF}.chrs)
HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`


# Commands


time(


sequenza-utils bam2seqz \
	-n ${WORKDIR}/$HEALTHY.recal.bam \
	-t ${WORKDIR}/$TUMOR.recal.bam \
	--fasta ${RESDIR}/${REF}.fasta \
	-gc ${RESDIR}/${REF}.gc50Base.wig.gz \
	-o ${WORKDIR}/${TUMOR}.${CHR}.out.seqz.gz \
	-C $CHR


)



