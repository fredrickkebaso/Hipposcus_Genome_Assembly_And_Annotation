#!/bin/bash
#PBS -l select=1:ncpus=56:mpiprocs=56:mem=950gb
#PBS -q bigmem
#PBS -W group_list=bigmemq
#PBS -l walltime=24:00:00
#PBS -o /mnt/lustre/users/fkebaso/hippo/hcamelina_male/results/velvet/velvet.out
#PBS -e /mnt/lustre/users/fkebaso/hippo/hcamelina_male/results/velvet/velvet.err
#PBS -m abe
#PBS -M fredrickkebaso@gmail.com
#PBS -N velvet

# ---------------- Velvet Assembly ----------------

# De novo genome assembly of short reads

# ---------------- Modules -----------------------

echo "Loading required modules..."

module load chpc/BIOMODULES
module load velvet/1.2.10_51

# ---------------- Inputs/Outputs/Parameters ------------------

echo "Creating output variables..."

basedir="/mnt/lustre/users/fkebaso/hippo/hcamelina_male"
results="${basedir}/results/velvet"
assembly_name="hcamelina_m_velvet_genome.fa"
forward_read="${basedir}/results/kraken/hcamelina_male_unclassified_reads_1.fq" 
reverse_read="${basedir}/results/kraken/hcamelina_male_unclassified_reads_2.fq"
kmer=51 


# Remove output directory if it already exists

echo "Removing old output directory (if exists)..."

# if [ -d ${results} ]; then
#     rm -r ${results}
# fi

echo "Creating output directories"

mkdir -p "${results}"
touch "${results}/velvet.out" "${results}/velvet.err"

# -------------------Run ---------------------------

echo "Running velvet..."

echo "Recommended Version 1.2.10."

# Generate hash tables from the input sequence data
# Hash length is set to 51
# Input data is fastq
# Paired-end reads are in separate files

echo "Running velveth command..."

velveth "${results}" "${kmer}" -fastq.gz -shortPaired -separate "${forward_read}" "${reverse_read}"

# Construct the contigs from the hash tables generated by velveth
# Expected coverage is automatically estimated from the input data
# Coverage cutoff is set based on the expected coverage
# Insert size of the paired-end reads is 290

echo "Running velvetg command..."

velvetg "${results}" -exp_cov auto -cov_cutoff auto 

# Remove intermediate files
echo "Removing intermediate files..."
rm "${results}"/{Graph2,LastGraph,Log,PreGraph,Roadmaps,Sequences}

# Rename the generated assembly, contigs.fa to match the organism
echo "Renaming the generated assembly file..."
mv "${results}"/contigs.fa "${results}"/"${assembly_name}"

# Rename the stats file to match the organism
echo "Renaming the stats file..."
mv "${results}"/stats.txt "${results}"/"${assembly_name}"_stats.txt

echo "Completed assembling genome with Velvet successfully!"
