#!/bin/sh
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type END
#SBATCH --cpus-per-task 1
#SBATCH -t 10:00
#SBATCH --mem 100G
#SBATCH -p thinnodes,cola-corta,thin-shared



# Reading config

source ReadConfig.sh $1

# Loading modules

module load gcccore/6.4.0 perl/5.26.1 gcc/6.4.0 samtools/1.7 R/3.5.0 bedtools/2.27.1 jdk/1.8.0

# Selecting chromosome

CHR=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${RESDIR}/${REF}.chrs)

# Creating bams folder 

mkdir ${WORKDIR}/${CHR}
mv ${WORKDIR}/*.realign.${CHR}.ba* ${WORKDIR}/${CHR}/

# Checking the memory

#source /opt/cesga/modules-util/top.sh    #Only for Cesga
       

# Commands

cd ${WORKDIR}/${CHR}

time(

/mnt/netapp1/posadalab/APPS/Nextflow/nextflow run iarcbioinfo/needlestack --bam_folder ${WORKDIR}/${CHR}/ --fasta_ref ${RESDIR}/{REF}.fa

)

echo "FINISHED"

