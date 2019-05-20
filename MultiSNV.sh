#!/bin/sh
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com 
#SBATCH --mail-type END
#SBATCH --cpus-per-task 1
#SBATCH -t 100:00:00
#SBATCH --mem 100G
#SBATCH -p gpu-shared-k2,gpu-shared,shared
#SBATCH --qos shared



# Reading config

source ReadConfig.sh $1

# Loading modules
module load gcc/5.3.0 multisnv/1.0
module load R

# Selecting samples and chromosomes

CHR=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${RESDIR}/${REF}.chrs) # We select the chromosome using the job array task id variable

HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`

SAMPLES=$( diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2 | awk -v healthyname=${HEALTHY} -v chr=${CHR} -v dir=$WORKDIR 'BEGIN{printf dir"/"healthyname".realign."chr".bam "}{printf dir"/"$0".realign."chr".bam "}' | tr '\n' ' ') #We select all the samples to pass them to MultiSNV

echo $SAMPLES



# Checking the memory

#source /opt/cesga/modules-util/top.sh    #Only for Cesga


# Estimate median coverage of samples

number_files=$(awk 'END {print NR}' ${WORKDIR}/${SAMPLELIST})
floatscale=6
prop=$(awk -v scale=$floatscale -v num=$number_files 'BEGIN { printf "%.*f\n", scale, 1/num}')
SAMPLE=$(echo $SAMPLELIST | sed 's/.FakeNames//')
#median=$(cat ${WORKDIR}/${SAMPLE}.collect_wgs_metrics.txt | grep -v "^#" | sed '/^$/d' | grep -v "^GENOME" | cut -f2 | head -1 )

#NormalMedianCoverage=$(echo "$median * $prop" | bc -l)
#TumorMedianCoverage=$NormalMedianCoverage

NormalMedianCoverage=40
TumorMedianCoverage=40

echo "Tumor median coverage= "${TumorMedianCoverage}
echo "Normal median coverage= "${NormalMedianCoverage}


# mva == V = number of variant reads to consider a site. i.e. If there is only one read carrying a variant allele I jump to the next position and  avoid calculations
# Run MultiSNV per chromosome

#number_samples=`cat ${WORKDIR}/${SAMPLELIST} | wc -l`

number_tumors=$( diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' |wc -l)
number_samples=$(($number_tumors + 1)) # Because I only use one of the healthy samples
OUT=$(basename $1 | sed 's/.Config//')

multiSNV \
	--number ${number_samples} \
	--fasta ${RESDIR}/${REF}.fasta \
        --bam $SAMPLES \
	--seed 2 \
	-f ${WORKDIR}/MultiSNV.${OUT}.${CHR}.100hours.vcf \
	--mu 0.000001 \
	--minBase 20 \
	--minMapQual 30 \
	--dmin 5 \
        --low_depth 6 \
	--dmax 300 \
	--mva 1 \
	--weak_evidence 0.03 \
	--normal_contamination 0.03 \ \
	--minVariantReadsForTriallelicSite 2 \
	--flag-homopolymer 5 \
        --medianN ${NormalMedianCoverage} \
        --medianT ${TumorMedianCoverage} \
	--Rmdups 0 \
	--include-germline 1 \
	--include-LOH 1 \
	--print 1 \
	--conv 1 \
	--regions $CHR
	
echo "Output "${OUT}" generated."

# Description="Somatic Status,Integer Variant status relative to Normal,0=wildtype,1=germline,2=somatic,3=LOH,4=unknown"

#The output is a standard VCF file. To get a high confidence set of calls, we suggest 
#retaining sites that are flagged as "PASS" or "LOW_QUAL". "LOW_QUAL" indicates 
#there is uncertainty about the somatic status in at least one sample, (perhaps due 
#to low depth and/or low mutation frequency) but this does not mean there is evidence
#that variation is artifactual. In our work, we tend to keep both "LOW_QUAL" and "PASS" sites.
