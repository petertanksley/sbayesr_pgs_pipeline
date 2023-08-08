#!/bin/bash
#SBATCH -J tt_pgs
#SBATCH -o tt_pgs.o%j
#SBATCH -N 1
#SBATCH -n 24
#SBATCH -p normal
#SBATCH -t 01:00:00
#SBATCH -A Developmental-Behavi

#========================================================================================#
# SET WORKING ENVIRONMENT
#========================================================================================#

export PATH=$PATH:/work2/07624/tankslpr/stampede2/TOOLS
export PATH=$PATH:/work2/07624/tankslpr/stampede2/TOOLS/plink
export PATH=$PATH:/work2/07624/tankslpr/stampede2/TOOLS/plink2
export PATH=$PATH:/work2/07624/tankslpr/stampede2/TOOLS/gctb_2.04.3_Linux

#set up file structure (insert project name below)
proj_name = "2_ext"
mkdir -p ../projects/$proj_name/input
mkdir -p ../projects/$proj_name/output
mkdir -p ../projects/$proj_name/temp

#set path variables
INPUT="../projects/$proj_name/input"
OUTPUT="../projects/$proj_name/output"
TEMP="../projects/$proj_name/temp"

#========================================================================================#
# Format GWAS effects (.ma format)
#========================================================================================#

#Convert sumstats to .ma format (SNP A1 A2 freq b se p N)(N=SNPs, not necessary)

#EXAMPLE
#if [[	! -e $TEMP/non_cog_grch37.ma || \
#	! -s $TEMP/non_cog_grch37.ma ]]; then
#	gunzip $INPUT/GCST90011874_buildGRCh37.tsv.gz
#	awk 'BEGIN{FS="\t"; OFS=FS}{print $1, $4, $5, $6, $7, $8, $10, 510795}' $INPUT/GCST90011874_buildGRCh37.tsv > $TEMP/non_cog_grch37.ma
#	gzip $INPUT/GCST90011874_buildGRCh37.tsv
#fi

#========================================================================================#
# Run SBayesR. Steps: unzip ld-mat; format list; run SBayesR; zip ld-mat
#========================================================================================#

#EXAMPLE
#if [[	! -e $OUTPUT/non_cog_sbayesr_ukb2.8M.snpRes || \
#	! -s $OUTPUT/non_cog_sbayesr_ukb2.8M.snpRes ]]; then
#	unzip ../../ukb_ref_panels/ukb_50k_bigset_2.8M.zip; rm ../../ukb_ref_panels/ukb_50k_bigset_2.8M.zip
#	old_path="/gpfs1/scratch/group30days/cnsg_park/uqllloyd/sbayesr/post_review/ukb_50k_bigset_2.7M/ukb_50k_bigset_2.8M/"
#       new_path="/scratch/07624/tankslpr/ukb_ref_panels/ukb_50k_bigset_2.8M/"
#        sed "s#$old_path#$new_path#g" ../../ukb_ref_panels/ukb_50k_bigset_2.8M/ukb50k_2.8M_shrunk_sparse.mldmlist \
#        > ../../ukb_ref_panels/ukb_50k_bigset_2.8M/ukb50k_2.8M_shrunk_sparse_updated.mldmlist
#	gctb	--sbayes R \
#		--mldm ../../ukb_ref_panels/ukb_50k_bigset_2.8M/ukb50k_2.8M_shrunk_sparse_updated.mldmlist \
#		--gwas-summary ../temp/non_cog_grch37.ma \
#		--exclude-mhc \
#		--seed 12345 \
#		--impute-n \
#		--pi 0.95,0.02,0.02,0.01 \
#		--gamma 0.0,0.01,0.1,1 \
#		--chain-length 10000 \
#		--burn-in 2000 \
#		--out-freq 10 \
#		--out ../output/non_cog_sbayesr_ukb2.8M
#	zip -rm ../../ukb_ref_panels/ukb_50k_bigset_2.8M.zip ../../ukb_ref_panels/ukb_50k_bigset_2.8M
#fi

#========================================================================================#
# Compute PGS with Plink
#========================================================================================#

#target="/work2/07624/tankslpr/stampede2/TTP_GENOTYPES/IMPUTED_1KG/TEXAS_TWINS.1KG.EUR_noOutliers.chr1_22.updated.SNPs.maf1e-3.hwe1e-6.info90"
#snpRes="../output/non_cog_sbayesr_ukb2.8M.snpRes"


#plink 	--bfile $target \
#	--score $snpRes 2 5 8 header sum center \
#	--out ../output/ttp_non_cog_sbayesr_ukb2.8M
