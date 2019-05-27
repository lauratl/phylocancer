#!/bin/bash
# Pre-processing of whole-genome next-generation sequencing (WGS) data
# Tamara Prieto - 2017    Laura's version



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

#jid0=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/FastQCRaw.sh $1 | awk '{print $4}')
#jid0=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/FastQCRaw.sh $1 | awk '{print $4}')
echo "FastQCRaw.sh Job ID $jid0" | tee -a ${WORKDIR}/$slurm_info/README

#jid1=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/Cutadapt.sh $1 | awk '{print $4}')
#jid1=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/Cutadapt.sh $1 | awk '{print $4}')
echo "Cutadapt.sh Job ID $jid1" | tee -a ${WORKDIR}/$slurm_info/README

#jid2=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/FastQCTrimmed.sh $1 | awk '{print $4}')
#jid2=$(sbatch --dependency=afterok:$jid1 --array=1-${number_samples} ${SCRIPTDIR}/FastQCTrimmed.sh $1 | awk '{print $4}')
echo "FastQCTrimmed.sh Job ID $jid2" | tee -a ${WORKDIR}/$slurm_info/README

#jid3=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/BWA.sh $1 | awk '{print $4}')
#jid3=$(sbatch --array=8 ${SCRIPTDIR}/BWA.sh $1 | awk '{print $4}') 
#jid3=$(sbatch --dependency=afterok:$jid1 --array=1-${number_samples} ${SCRIPTDIR}/BWA.sh $1 | awk '{print $4}')
echo "BWA.sh Job ID $jid3"  | tee -a ${WORKDIR}/$slurm_info/README

#jid3b=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/Flagstat.sh $1 | awk '{print $4}')
#jid3b=$(sbatch --dependency=afterok:$jid3 --array=1-${number_samples} ${SCRIPTDIR}/Flagstat.sh $1 | awk '{print $4}')
echo "Flagstat.sh Job ID $jid3b" | tee -a ${WORKDIR}/$slurm_info/README




#jid4=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/SortSam.sh $1 | awk '{print $4}')
echo "SortSam.sh Job ID $jid4"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_Genomecov=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/Genomecov.sh $1 | awk '{print $4}')
echo "Genomecov.sh Job ID $jid_Genomecov"  | tee -a ${WORKDIR}/$slurm_info/README


#jid5=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/MarkDuplicatesWithMateCigar.sh $1 | awk '{print $4}')
echo "MarkDuplicatesWithMateCigar.sh Job ID $jid5"  | tee -a ${WORKDIR}/$slurm_info/README

#jid5b=$(sbatch --array=1-${number_samples} --dependency=afterok:$jid4 ${SCRIPTDIR}/MarkDuplicates.sh $1 | awk '{print $4}')
#jid5b=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/MarkDuplicates.sh $1 | awk '{print $4}')
echo "MarkDuplicates.sh Job ID $jid5b"  | tee -a ${WORKDIR}/$slurm_info/README


#jid6=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/BaseRecalibrator.sh $1 | awk '{print $4}')
echo "BaseRecalibrator.sh Job ID $jid6"  | tee -a ${WORKDIR}/$slurm_info/README
 
### BaseRecalibration with GATK4

#jid_BaseRecalibratorI=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/BaseRecalibratorI.sh $1 | awk '{print $4}')
echo "BaseRecalibratorI.sh Job ID $jid_BaseRecalibratorI"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_BaseRecalibratorII=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/BaseRecalibratorII.sh $1 | awk '{print $4}')
echo "BaseRecalibratorII.sh Job ID $jid_BaseRecalibratorII"  | tee -a ${WORKDIR}/$slurm_info/README

#jid_CalculateContamination=$(sbatch --array=1-${ntumors} ${SCRIPTDIR}/CalculateContamination.sh $1 | awk '{print $4}')
echo "CalculateContamination.sh Job ID $jid_CalculateContamination"  | tee -a ${WORKDIR}/$slurm_info/README

###

#jid7=$(sbatch --array=1-${number_samples} ${SCRIPTDIR}/PrintReads.sh $1 | awk '{print $4}')
echo "PrintReads.sh Job ID $jid7"  | tee -a ${WORKDIR}/$slurm_info/README
#jid8=$(sbatch --array=1-${nchrs} ${SCRIPTDIR}/RealignerTargetCreator.sh $1 | awk '{print $4}')
echo "RealignerTargetCreator.sh Job ID $jid8"  | tee -a ${WORKDIR}/$slurm_info/README
#jid9=$(sbatch --array=1-${nchrs} ${SCRIPTDIR}/IndelRealigner.sh $1 | awk '{print $4}')
echo "IndelRealigner.sh Job ID $jid9"  | tee -a ${WORKDIR}/$slurm_info/README
#jidMergeHealthySamples=$(sbatch ${SCRIPTDIR}/MergeHealthySamples.sh $1 | awk '{print $4}')
echo "MergeHealthySamples.sh Job ID $jidMergeHealthySamples"  | tee -a ${WORKDIR}/$slurm_info/README

#jidMergeBamFiles=$(sbatch --array=1-${ntumors} ${SCRIPTDIR}/MergeBamFiles.sh $1 | awk '{print $4}')
echo "MergeBamFiles.sh Job ID $jidMergeBamFiles"  | tee -a ${WORKDIR}/$slurm_info/README


#jid_Contest=$(sbatch --array=1-${ntumors} ${SCRIPTDIR}/Contest.sh $1 | awk '{print $4}')
echo "Contest.sh Job ID $jid_Contest"  | tee -a ${WORKDIR}/$slurm_info/README

#jidx=$(sbatch --array=1-${njobs_bytumor_bychr} ${SCRIPTDIR}/SequenzaUtils.sh $1 | awk '{print $4}')
echo "SequenzaUtils.sh Job ID $jidx" | tee -a ${WORKDIR}/$slurm_info/README

#jidMultiSNV=$(sbatch --array=1-${nchrs} ${SCRIPTDIR}/MultiSNV.sh $1 | awk '{print $4}') 
echo "MultiSNV.sh Job ID $jidMultiSNV"  | tee -a ${WORKDIR}/$slurm_info/README

#jidNeedlestack=$(sbatch --array=1-${nchrs} ${SCRIPTDIR}/Needlestack.sh $1 | awk '{print $4}') 
echo "Needlestack.sh Job ID $jidNeedlestack"  | tee -a ${WORKDIR}/$slurm_info/README

#jidMuTect2=$(sbatch --array=6-${njobs_bytumor_bychr} ${SCRIPTDIR}/MuTect2.sh $1 | awk '{print $4}') 
#jidMuTect2=$(sbatch --array=6-${njobs_bytumor_bychr} ${SCRIPTDIR}/MuTect2.sh $1 | awk '{print $4}')
#jidMuTect2=$(sbatch --array=126,12,151,152,153,154,155,156,158,159,162,163,164,165,166,167,168,170,176,185,56 ${SCRIPTDIR}/MuTect2.sh $1 | awk '{print $4}')
echo "MuTect2.sh Job ID $jidMuTect2"  | tee -a ${WORKDIR}/$slurm_info/README

#jidCollectWgsMetrics=$(sbatch --array=1-${ntumors} ${SCRIPTDIR}/CollectWgsMetrics.sh $1 | awk '{print $4}')
echo "CollectWgsMetrics.sh Job ID $jidCollectWgsMetrics"  | tee -a ${WORKDIR}/$slurm_info/README


echo "PIPELINE LAUNCHED"
