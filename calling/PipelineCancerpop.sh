#!/bin/bash
# SNVs calling of Cancerpop WGS data


# Reading configuration file

source ReadConfig.sh $1


# Samples and chromosomes counting

number_samples=`wc -l ${WORKDIR}/${SAMPLELIST} | awk '{print $1}'`    # Total number of samples
nchrs=`cat ${RESDIR}/${REF}.chrs | wc -l`     # Total number of chromosomes
ntumors=`diff ${WORKDIR}/${SAMPLELIST} ${WORKDIR}/${CONTROL} | grep '^<'| wc -l`  # Total number of tumor samples

echo "Analyzing "$number_samples" samples, including $ntumors tumor samples"

njobs_bytumor_bychr=$(( nchrs*ntumors ))   # When splitting by chromosomes for each tumor sample


## Create a folder and put slurm output inside

pipeline_name=`basename $0`

slurm_info=$(echo `date` | awk -v argument=$pipeline_name '{print "Slurm"argument"_"$3"-"$2"-"$6"_"$4}')
mkdir -p ${WORKDIR}/$slurm_info
cd ${WORKDIR}/$slurm_info

echo "Launched at `date`"
echo "Launched at `date`" >> ${WORKDIR}/$slurm_info/README
echo "Sending slurm output to ${WORKDIR}/$slurm_info"
echo "Using Configuration file $1" >> ${WORKDIR}/$slurm_info/README

#### PIPELINE #####

## QUALITY CONTROL AND TRIMMING

#jid0=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/FastQCRaw.sh $1 | awk '{print $4}')
#jid0=$(sbatch --array=9,10 ${SCRIPTDIR}/FastQCRaw.sh $1 | awk '{print $4}')
echo "FastQCRaw.sh Job ID $jid0" | tee -a ${WORKDIR}/$slurm_info/README

#jid1=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/Cutadapt.sh $1 | awk '{print $4}')
#jid1=$(sbatch --array=24,25 ${SCRIPTDIR}/Cutadapt.sh $1 | awk '{print $4}')
#jid1=$(sbatch --array=11-23 ${SCRIPTDIR}/Cutadapt.sh $1 | awk '{print $4}')
echo "Cutadapt.sh Job ID $jid1" | tee -a ${WORKDIR}/$slurm_info/README

#jid2=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/FastQCTrimmed.sh $1 | awk '{print $4}')
#jid2=$(sbatch --dependency=afterok:$jid1 --array=1-${number_samples} ${SCRIPTDIR}/FastQCTrimmed.sh $1 | awk '{print $4}')
echo "FastQCTrimmed.sh Job ID $jid2" | tee -a ${WORKDIR}/$slurm_info/README

## MAPPING, SORTING AND STATS

#jid3=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/BWA.sh $1 | awk '{print $4}')
#jid3=$(sbatch --array=11-23 ${SCRIPTDIR}/BWA.sh $1 | awk '{print $4}')
#jid3=$(sbatch --array=23 ${SCRIPTDIR}/BWA.sh $1 | awk '{print $4}')
#jid3=$(sbatch --array=11 ${SCRIPTDIR}/BWA.sh $1 | awk '{print $4}')
#jid3=$(sbatch --dependency=afterok:$jid1 --array=1-${number_samples} ${SCRIPTDIR}/BWA.sh $1 | awk '{print $4}')
echo "BWA.sh Job ID $jid3"  | tee -a ${WORKDIR}/$slurm_info/README

#jid3b=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/Flagstat.sh $1 | awk '{print $4}')
#jid3b=$(sbatch --dependency=afterok:$jid3 --array=1-${number_samples} ${SCRIPTDIR}/Flagstat.sh $1 | awk '{print $4}')
#jid3b=$(sbatch --array=1,2,3,4,5,6,7,9,10 ${SCRIPTDIR}/Flagstat.sh $1 | awk '{print $4}')
echo "Flagstat.sh Job ID $jid3b" | tee -a ${WORKDIR}/$slurm_info/README

#jid4=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/SortSam.sh $1 | awk '{print $4}')
#jid4=$(sbatch --array=1-${number_samples} --dependency=afterok:$jid3 ${SCRIPTDIR}/SortSam.sh $1 | awk '{print $4}')
#jid4=$(sbatch --array=1,5 ${SCRIPTDIR}/SortSam.sh $1 | awk '{print $4}')
#jid4=$(sbatch --array=23 ${SCRIPTDIR}/SortSam.sh $1 | awk '{print $4}')
#jid4=$(sbatch --array=11 ${SCRIPTDIR}/SortSam.sh $1 | awk '{print $4}')
echo "SortSam.sh Job ID $jid4"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_Genomecov=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/Genomecov.sh $1 | awk '{print $4}')
#jid_Genomecov=$(sbatch --array=8 ${SCRIPTDIR}/Genomecov.sh $1 | awk '{print $4}')
echo "Genomecov.sh Job ID $jid_Genomecov"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_SamtoolsDepth=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/SamtoolsDepth.sh $1 | awk '{print $4}')
#jid_SamtoolsDepth=$(sbatch --array=8 ${SCRIPTDIR}/SamtoolsDepth.sh $1 | awk '{print $4}')
echo "SamtoolsDepth.sh Job ID $jid_SamtoolsDepth"  | tee -a ${WORKDIR}/$slurm_info/README

## REMOVING DUPLICATES AND RECALIBRATING (GATK4)
 
#jid5b=$(sbatch --array=1-${number_samples} --dependency=afterok:$jid4 ${SCRIPTDIR}/MarkDuplicates.sh $1 | awk '{print $4}')
jid5b=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/MarkDuplicates.sh $1 | awk '{print $4}')
#jid5b=$(sbatch --array=1,5,11,12,17,21,13,14,15,16,18,19,20,22,23 ${SCRIPTDIR}/MarkDuplicates.sh $1 | awk '{print $4}')
#jid5b=$(sbatch --array=1-10 ${SCRIPTDIR}/MarkDuplicates.sh $1 | awk '{print $4}')
echo "MarkDuplicates.sh Job ID $jid5b"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_BaseRecalibratorI=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/BaseRecalibratorI.sh $1 | awk '{print $4}')
echo "BaseRecalibratorI.sh Job ID $jid_BaseRecalibratorI"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_BaseRecalibratorII=$(sbatch --array=1-${number_samples} --dependency=afterok:$jid_BaseRecalibratorI ${SCRIPTDIR}/BaseRecalibratorII.sh $1 | awk '{print $4}')
echo "BaseRecalibratorII.sh Job ID $jid_BaseRecalibratorII"  | tee -a ${WORKDIR}/$slurm_info/README


## CONTAMINATION AND CALLING

#jid_CalculateContamination=$(sbatch --array=1-${ntumors} ${SCRIPTDIR}/CalculateContamination.sh $1 | awk '{print $4}')
#jid_CalculateContamination=$(sbatch --array=7 ${SCRIPTDIR}/CalculateContamination.sh $1 | awk '{print $4}')
echo "CalculateContamination.sh Job ID $jid_CalculateContamination"  | tee -a ${WORKDIR}/$slurm_info/README

#jidMuTect2=$(sbatch --array=1-${njobs_bytumor_bychr} ${SCRIPTDIR}/MuTect2.sh $1 | awk '{print $4}')
#jidMuTect2=$(sbatch --array=101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,117,118,121,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,183,184,187,188,191,192,197,198,199,200 ${SCRIPTDIR}/MuTect2.sh $1 | awk '{print $4}')

echo "MuTect2.sh Job ID $jidMuTect2"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_MuTect2_mseq=$(sbatch --array=1-${nchrs} ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#jid_MuTect2_mseq=$(sbatch --array=1 ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#jid_MuTect2_mseq=$(sbatch --array=10,12,2,3,5,6,7,8 ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#jid_MuTect2_mseq=$(sbatch --array=2-${nchrs} ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#jid_MuTect2_mseq=$(sbatch --array=10,11,12,13,14,15,16,17,19,1,2,3,4,5,6,7,8,9 ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#jid_MuTect2_mseq=$(sbatch --array=1,2 ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#jid_MuTect2_mseq=$(sbatch --array=17,19,21 ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#### Each chr the right time  ####
#jid_MuTect2_mseq_chr1_2=$(sbatch --array=1,2 -t 50:00:00 ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#jid_MuTect2_mseq2_chr3_12=$(sbatch --array=3-12 -t 40:00:00 ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#jid_MuTect2_mseq3_chr13_25=$(sbatch --array=13-25 -t 30:00:00 ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#jid_MuTect2_mseq=$(sbatch --array=23 -t 100:00:00 ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
#jid_MuTect2_mseq=$(sbatch --array=1-23 -t 60:00:00 ${SCRIPTDIR}/MuTect2_mseq.sh $1 | awk '{print $4}')
echo "MuTect2_mseq.sh Job ID $jid_MuTect2_mseq_chr1_2 $jid_MuTect2_mseq2_chr3_12 $jid_MuTect2_mseq3_chr13_25"  | tee -a ${WORKDIR}/$slurm_info/README
echo "MuTect2_mseq.sh Job ID $jid_MuTect2_mseq"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_FilterMutectCalls=$(sbatch --array=1-${nchrs} ${SCRIPTDIR}/FilterMutectCalls.sh $1 | awk '{print $4}')
#jid_FilterMutectCalls=$(sbatch --array=3 ${SCRIPTDIR}/FilterMutectCalls.sh $1 | awk '{print $4}')
echo "FilterMutectCalls.sh Job ID $jid_FilterMutectCalls"  | tee -a ${WORKDIR}/$slurm_info/README

echo "Run MergeMutect2mseqVCFs.sh"
#jid_GatherVcfs=$(sbatch --array=1 ${SCRIPTDIR}/GatherVcfs.sh $1 | awk '{print $4}')
#echo "GatherVcfs.sh Job ID $jid_GatherVcfs"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_AscatNGS=$(sbatch --array=1-${ntumors} --x11=all ${SCRIPTDIR}/AscatNGS.sh $1 | awk '{print $4}')
echo "AscatNGS.sh Job ID $jid_AscatNGS"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_Lichee=$(sbatch --array=1 ${SCRIPTDIR}/Lichee.sh $1 | awk '{print $4}')
echo "Lichee.sh Job ID $jid_Lichee"  | tee -a ${WORKDIR}/$slurm_info/README



echo "PIPELINE LAUNCHED"
