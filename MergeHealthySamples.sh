#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 20:00:00
#SBATCH --mem 100G
#SBATCH -p thinnodes,thin-shared


# Reading config

source ReadConfig.sh $1


# Loading modules

module load gcc/6.4.0 samtools/1.7

# Selecting samples and chromosomes

#SAMPLES=`awk -v workdir=${WORKDIR} '{printf workdir$1; printf ".realign.bam " }' ${WORKDIR}/${CONTROL}`

rm ${WORKDIR}/HealthySampleChrsListforSamtools

set -f
IFS='
'

for i in $(cat ${WORKDIR}/${CONTROL}); do
for j in $(cat ${RESDIR}/${REF}.chrs); do

sample=$i".realign."$j".bam"
echo ${WORKDIR}/${sample} >> ${WORKDIR}/HealthySampleChrsListforSamtools
done
done




# Selecting auxiliar files    
 


# Checking the memory

#source /opt/cesga/modules-util/top.sh    #Only for Cesga


# Commands

time(samtools merge ${WORKDIR}/${PATIENT}.HealthySamples.bam -b ${WORKDIR}/HealthySampleChrsListforSamtools )


echo "FINISHED"


