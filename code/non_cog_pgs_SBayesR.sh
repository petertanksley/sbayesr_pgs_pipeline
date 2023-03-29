#!/bin/bash
#SBATCH -J tt_pgs
#SBATCH -o tt_pgs.o%j
#SBATCH -N 2
#SBATCH -n 24
#SBATCH -p skx-normal
#SBATCH -t 010:00:00
#SBATCH -A Developmental-Behavi

#========================================================================================#
# SET WORKING ENVIRONMENT
#========================================================================================#

export PATH=$PATH:/work2/07624/tankslpr/stampede2/TOOLS
export PATH=$PATH:/work2/07624/tankslpr/stampede2/TOOLS/gctb_2.04.3_Linux

#========================================================================================#
# OPERATIONS
#========================================================================================#

#Convert sumstats to .ma format

if [[	! -e ../temp/non_cog_grch37.ma || \
	! -s ../temp/non_cog_grch37.ma ]]; then
	gunzip ../input/GCST90011874_buildGRCh37.tsv.gz
	echo "SNP A1 A2 freq b se p N" | tr -s " " "\t" > ../temp/non_cog_grch37.ma 
	tail -n +2 ../input/GCST90011874_buildGRCh37.tsv | \
	awk 'BEGIN{FS="\t"; OFS=FS}{print $1, $4, $5, $6, $7, $8}' | \
	awk 'BEGIN{FS="\t"; OFS=FS}{$(NF+1) = 510795; print }'>> ../temp/non_cog_grch37.ma
	gzip ../input/GCST90011874_buildGRCh37.tsv
fi

#decompress ld matrix
#unzip ../../TOOLS/gctb_2.04.3_Linux/ld_matrix/ukb_50k_bigset_2.8M.zip -d ../../TOOLS/gctb_2.04.3_Linux/ld_matrix

ls ../../ukb_50k_bigset_2.8M/*.bin | \
	sed -r 's/.{4}$//' > ../temp/ld_mat_list.txt

#run SBayesR
gctb	--sbayes R \
	--mldm ../temp/ld_mat_list.txt \
	--gwas-summary ../temp/non_cog_grch37.ma \
	--pi 0.95,0.02,0.02,0.01 \
	--gamma 0.0,0.01,0.1,1 \
	--exclude-mhc \
	--hsq 0.5 \
	--chain-length 25000 \
	--burn-in 5000 \
	--seed 12345 \
	--thread 48 \
	--no-mcmc-bin \
	--impute-n \
	--out ../output/non_cog_sbayesr
