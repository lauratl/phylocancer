#!/bin/bash
# SNVs calling of Cancerpop WGS data


# Reading configuration file

source ReadConfig.sh $1

SCRIPTDIR=${SCRIPTDIR/calling/clondec/}
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

# Prepare input for clonal deconvolution tools

jid_CreateClondecInput=$(sbatch ${SCRIPTDIR}/CreateClondecInput.sh $1 | awk '{print $4}')
echo "CreateClondecInput.sh Job ID $jid_CreateClondecInput"  | tee -a ${WORKDIR}/$slurm_info/README



# Run clonal deconvolution tools

#jid_Lichee=$(sbatch --array=1 ${SCRIPTDIR}/Lichee.sh $1 | awk '{print $4}')
echo "Lichee.sh Job ID $jid_Lichee"  | tee -a ${WORKDIR}/$slurm_info/README



echo "PIPELINE LAUNCHED"
