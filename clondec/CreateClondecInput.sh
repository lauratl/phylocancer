#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopezslurm@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 5:00:00
#SBATCH --mem 50G
#SBATCH -p cola-corta


source ReadConfig.sh $1


mkdir -p ${WORKDIR}/Clondec

LOG=${WORKDIR}/Clondec/CreateClondecInput.log
TABLE=${WORKDIR}/Clondec/CreateClondecInput.log

mkdir -p ${WORKDIR}/Clondec



echo "Starting Lichee input creation" > $LOG
echo "#patient;healthy;initial_variants;non-diploid-genes;diploidvariants;snvs;retrieved;enoughdepth;somatic;final" > $TABLE



# Get sample names


SAMPLES=$( diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<' | cut -d " " -f2 | awk '{printf $0 " "}' )
HEALTHY=`head -1 ${WORKDIR}/${CONTROL}`


echo "Samples are $SAMPLES" >> $LOG
echo "Healthy sample is $HEALTHY" >>$LOG


# Remove variants in non-diploid regions


## Create bed file of the non-diploid regions from each sample's Ascat output


CNFILE=${WORKDIR}/Clondec/${PATIENT}.nondiploid.bed

awk 'BEGIN{print "chromosome\tstart\tend"}' > $CNFILE


for SAMPLE in ${SAMPLES}; do

ASCAT=${WORKDIR}/AscatNGS/${SAMPLE}/${SAMPLE}.copynumber.caveman.csv

awk -F "," '{if($7!="2" || $8!="1"){print $2"\t"$3-1"\t"$4}}' $ASCAT >> $CNFILE

done

# Remove indels

module load gatk/4.1.1.0

gatk SelectVariants \
        -V ${WORKDIR}/${PATIENT}.vcf \
        -R ${RESDIR}/${REF}.fasta \
        --select-type-to-include SNP \
		--restrict-alleles-to BIALLELIC \
        -O ${WORKDIR}/Clondec/${PATIENT}.snvs.vcf


SNVS=$(grep -v '^#' ${WORKDIR}/Clondec/${PATIENT}.snvs.vcf | wc -l)
echo "Diploid SNVs: $SNVS" >> $LOG

## Remove variants in non-diploid regions from the vcf

module load gcc/6.4.0 vcftools/0.1.15


vcftools \
    --vcf ${WORKDIR}/Clondec/${PATIENT}.snvs.vcf \
	--exclude-bed $CNFILE \
	--out ${WORKDIR}/Clondec/${PATIENT}.diploid \
	--recode

mv ${WORKDIR}/Clondec/${PATIENT}.diploid.recode.vcf ${WORKDIR}/Clondec/${PATIENT}.diploid.vcf

DIPLOID=$(grep -v '^#' ${WORKDIR}/Clondec/${PATIENT}.diploid.vcf | wc -l)
echo "Diploid variants: $DIPLOID" >> $LOG







# Recover read counts

## Get list of positions to recover read counts

grep -v '^#' ${WORKDIR}/Clondec/${PATIENT}.diploid.vcf | awk '{print $1"\t"$2-1"\t"$2}' > ${WORKDIR}/Clondec/${PATIENT}.pos.bed


## Locate the corresponding bam file

for SAMPLE in $SAMPLES; do

BAMFILE=${WORKDIR}/${SAMPLE}.recal.bam


## Get read counts from the bam

gatk CollectAllelicCounts \
          -I ${BAMFILE} \
          -R ${RESDIR}/${REF}.fasta \
          -L ${WORKDIR}/Clondec/${PATIENT}.pos.bed \
          -O ${WORKDIR}/Clondec/${PATIENT}.${SAMPLE}.allelicCounts.tsv

done



# Merge read counts from the different samples

for SAMPLE in $SAMPLES; do

grep -v '^@' ${WORKDIR}/Clondec/${PATIENT}.${SAMPLE}.allelicCounts.tsv | sed "s/COUNT/COUNT_$SAMPLE/g" | awk '{print $1":"$2"\t"$3"\t"$4"\t"$5"\t"$6 }' > ${WORKDIR}/${PATIENT}.${SAMPLE}.Counts.tsv

done

SAMPLESARRAY=($SAMPLES)



for SAMPLE in $SAMPLES; do

if [ $SAMPLE == ${SAMPLESARRAY[0]} ]; then
echo ""

elif [ $SAMPLE == ${SAMPLESARRAY[1]} ]; then
join ${WORKDIR}/Clondec/${PATIENT}.${SAMPLESARRAY[0]}.Counts.tsv ${WORKDIR}/Clondec/${PATIENT}.${SAMPLE}.Counts.tsv > ${WORKDIR}/Clondec/${PATIENT}.tmp.${SAMPLE}.Counts
PREVSAMPLE=${SAMPLE}

else
join ${WORKDIR}/Clondec/${PATIENT}.tmp.${PREVSAMPLE}.Counts ${WORKDIR}/Clondec/${PATIENT}.${SAMPLE}.Counts.tsv > ${WORKDIR}/Clondec/${PATIENT}.tmp.${SAMPLE}.Counts
PREVSAMPLE=${SAMPLE}

fi
done

mv ${WORKDIR}/Clondec/${PATIENT}.tmp.${PREVSAMPLE}.Counts ${WORKDIR}/Clondec/${PATIENT}.Counts
rm ${WORKDIR}/Clondec/${PATIENT}.tmp.*.Counts


RETRIEVED=$(grep -v '^CONTIG' ${WORKDIR}/Clondec/${PATIENT}.Counts | wc -l)
echo "Retrieved read counts from  $RETRIEVED variants" >> $LOG


# Convert to LICHeE and CloneFinder input format

module load gcccore/6.4.0 python/2.7.15

python CreateCDInput_targeted.py \
	--input ${WORKDIR}/Clondec/${PATIENT}.Counts \
	--lichee ${WORKDIR}/Clondec/${PATIENT}.LicheeInput \
	--cloneFinder ${WORKDIR}/Clondec/${PATIENT}.CloneFinderInput \
	--healthy "$HEALTHY" \
	--maxVafIfNotHealthy 0.9 \
	--minDepth 20 \
	--minVaf 0.05 \
	--germlineVaf 0.1



FINAL=$(grep -v '^#' ${WORKDIR}/Clondec/${PATIENT}.LicheeInput | wc -l)
echo "Finally kept $FINAL SNVs" >> $LOG

echo "$PATIENT;$HEALTHY;$INITIAL;$GENES;$DIPLOID;$SNVS;$RETRIEVED;$ENOUGH;$SOMATIC;$FINAL" >> $TABLE

