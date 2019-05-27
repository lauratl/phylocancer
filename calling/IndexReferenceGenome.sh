#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user lauratomaslopez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 5:00:00
#SBATCH --mem 100G
#SBATCH -p cola-corta




module load intel/2016
module load bwa/0.7.15




bwa index -a bwtsw /mnt/lustre/scratch/home/uvi/be/ltl/RESOURCES/b37.fasta
