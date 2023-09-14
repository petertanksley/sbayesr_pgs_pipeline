#!/bin/bash
#SBATCH -J tt_pgs         # Job name
#SBATCH -o tt_pgs.o%j     # Name of stdout output file
#SBATCH -N 1		  # Total # of nodes (must be 1 for serial)
#SBATCH -n 1		  # Total # of mpi tasks (should be 1 for serial)
#SBATCH -p normal   	  # Queue (partition) name
#SBATCH -t 10:00:00	  # Run time (hh:mm:ss)
#SBATCH -A OTH21060	  # Project/Allocation name (req'd if you have more than 1)
#SBATCH --mail-type=all   # Send email at begin and end of job
#SBATCH --mail-user=peter.tanksley@austin.utexas.edu

#========================================================================================#
# SET WORKING ENVIRONMENT
#========================================================================================#

#paths to tools
export PATH=$PATH:/work/07624/tankslpr/ls6/TOOLS
export PATH=$PATH:/work/07624/tankslpr/ls6/TOOLS/plink
export PATH=$PATH:/work/07624/tankslpr/ls6/TOOLS/plink2
export PATH=$PATH:/work/07624/tankslpr/ls6/TOOLS/gctb_2.05beta_Linux

#path to ref panels
LD_DIR="/work/07624/tankslpr/ls6/TOOLS/gctb_2.05beta_Linux/ld_panels"

#path to sumstats
SUMSTATS_DIR="../../sumstats/1_formatted_ma"

#path to output
OUTPUT_DIR="../output"

#sumstat prefix (e.g., "sumstats_PREFIX.ma")
SUMSTAT="ea4"

#path to genotypes
GENOTYPES="/work/07624/tankslpr/ls6/TTP_GENOTYPES/PLINK_FILES/ttp_imputed_info90_maf1e2_hwe1e6_chr1_22_rsid"

#========================================================================================#
# Run SBayesR. Steps: unzip LD panels, process sumstats, rezip LD panels
#========================================================================================#

if [[	! -e ${OUTPUT_DIR}/${SUMSTAT}/${SUMSTAT}_sbayesr_ukb2.8M.snpRes || \
	! -s ${OUTPUT_DIR}/${SUMSTAT}/${SUMSTAT}_sbayesr_ukb2.8M.snpRes ]]; then

	#set up list of LD panels
	for chr in {1..22}
	do
		echo "/work/07624/tankslpr/ls6/TOOLS/gctb_2.05beta_Linux/ld_panels/ukb_50k_bigset_2.8M/ukb50k_shrunk_chr${chr}_mafpt01.ldm.sparse" >> ld_list.txt
	done

	mkdir -p ${OUTPUT_DIR}/${SUMSTAT}

	#decompress LD panels (remove .zip file to save space)
	#unzip $LD_DIR/ukb_50k_bigset_2.8M.zip -d $LD_DIR ; rm $LD_DIR/ukb_50k_bigset_2.8M.zip

	#execute SBayesR
	gctb	--sbayes R \
		--mldm ld_list.txt \
		--gwas-summary ${SUMSTATS_DIR}/sumstats_${SUMSTAT}.ma \
		--exclude-mhc \
		--seed 12345 \
		--impute-n \
		--pi 0.95,0.02,0.02,0.01 \
		--gamma 0.0,0.01,0.1,1 \
		--chain-length 10000 \
		--burn-in 2000 \
		--out-freq 10 \
		--out ${OUTPUT_DIR}/${SUMSTAT}/${SUMSTAT}_sbayesr_ukb2.8M

	#compress LD panels (remove individual files to save space)
	#zip -rm $LD_DIR/ukb_50k_bigset_2.8M.zip $LD_DIR/ukb_50k_bigset_2.8M
	rm ld_list.txt
fi

#========================================================================================#
# Compute PGS with Plink
#========================================================================================#

mkdir -p ${OUTPUT_DIR}/${SUMSTAT}/PGS

snpRes="${OUTPUT_DIR}/${SUMSTAT}/${SUMSTAT}_sbayesr_ukb2.8M.snpRes"
OUTPUT_PGS="${OUTPUT_DIR}/${SUMSTAT}/PGS"

if [[   ! -e ${OUTPUT_PGS}/ttp_${SUMSTAT}_sbayesr_ukb2.8M.sscore || \
        ! -s ${OUTPUT_PGS}/ttp_${SUMSTAT}_sbayesr_ukb2.8M.sscore ]]; then
	plink2 	--pfile $GENOTYPES \
		--score $snpRes 2 5 8 header center \
		--out ${OUTPUT_PGS}/ttp_${SUMSTAT}_sbayesr_ukb2.8M
fi
