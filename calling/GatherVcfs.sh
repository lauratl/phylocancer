#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 00:05:00
#SBATCH --mem 10G
#SBATCH -p shared
#SBATCH --qos shared


#It was -p thin-shared

# Chr1 ~40x 57% 10hours
# Change to 30h and from shared_short to thin-shared
# Change to 40h
# Change to 50h for chr1 and 2 CRC02

# Reading config

source ReadConfig.sh $1

# Loading modules

module load jdk/8u181
GATK=/mnt/netapp1/posadalab/APPS/gatk-4.1.1.0/gatk

# Commands

$GATK GatherVcfs `seq 1 22 | awk -v pref="-I Mutect2_mseq." -v suf=".${PATIENT}.filtered.vcf " '{printf pref $0 suf}END{print pref"X"suf pref"Y"suf pref"MT"suf}'` \
        -O ${WORKDIR}/Mutect2_mseq.${PATIENT}.filtered.vcf


echo "FINISHED"
