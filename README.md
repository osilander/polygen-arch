# Polygenic Architecture
This repo summarises the justifications, som eliterature, and the methods for doing an analysis of the extent of polygeneicity of various traits.

## Primary Aim
Most GWAS and related studies attempt to assign SNPs as causative by selecting SNPs on the basis of p-values (sometimes with some statistical corrections for LD or with additional data such as eQTL information). These p-values are based on the combination of (1) betas (effect sizes) and (2) standard error. When looking across studies, these are determined at least partially by sample size, i.e. the relative number of cases and controls, and partially by the precision with which traits can be measured. Within studies, this is determined at least partially by the frequency of polymorphisms (rare vs. common) and the choice of statistical test (e.g. logistical regression vs. chi-square).

These analyses, which prioritise on per-SNP bases, ignore to fact that when one SNP in a specific region of the genome is causal of trait differences, it is highly likely that other SNPs in the same region are also causal, but with lower effects (it is necessarily true that one SNP has the largest effect). In addition, by focusing on genome-wide significant SNPs, large regions of the genome that may contain small-effect SNPs (or many small effect SNPs) are ignored. This is a critical problem because often we might expect that it is specifically these regions that are the most relevant for developing treatments. Why? SNPs with large effects can apparently segregate in the population without having *critical* effects.

## Some literature
This is very well phrased in the paper [Genetic architecture: the shape of the genetic contribution to human traits and disease](https://www.nature.com/articles/nrg.2017.101):

*The clinical effect of drugs on LDL cholesterol level and cystic fibrosis illustrate the dichotomy between variation explained and its utility to drug development...Pharmacological inhibition of HMG-CoA reductase reduces the level of LDL cholesterol by approximately 30–40%...the common SNP most strongly associated with LDL cholesterol level near HMGCR, the gene encoding HMG-CoA reductase, explains 0.26% of the variance in LDL cholesterol level...even though the HMGCR locus harbours a common genetic variant that
explains only a small amount of phenotypic variation, the pharmacological inhibition of HMG-CoA reductase is clinically beneficial...common variants near PCSK9, the gene encoding proprotein convertase subtilisin/kexin type 9, have small effects on LDL cholesterol level74 whereas pharmacological inhibition of PCSK9 has large effects...RANKL, the gene encoding receptor activator of nuclear factor κB ligand, harbours common variants of small effect on bone mineral density67, yet pharmacological inhibition of RANKL has large effects on bone mineral density...Thus, small-effect-size SNPs can serve to highlight proteins that, when targeted with large-effect-size pharmaceuticals, can have large effects on disease risk...The amount of variance explained by a genetic variant does not always correlate with the suitability of the gene as a therapeutic target because drugs work on proteins; the base pair associated with the disease serves to help identify the causal protein. The relevance of the variation explained to the clinic should be measured by assessing the effect of pharmacological agents on the protein and its resultant effect on disease...perhaps because natural selection makes such perturbing genetic variants so rare that they lack statistical power for such an association, could still be a good drug target*

So here we ask whether we can detect these regions. We do this by averaging betas across regions. We can theen correlate average beta across a region (median or mean), average absolute value of betas (median or mean), stdev (variance) of betas, etc. Furthermore, to remove the effects of regions with very large betas, we can remove the top N regions, (e.g. the top 1000). In many (all?) cases we might use *Spearman* to minimse the effect of outlier betas. Finally, we might want to look at general effects where we think there *should* be effects, for example, nonsyn mutations. So here we can use SNPEff or similar to find out which SNPSs (rsids) have which effects, and then plot or normalise the betas from those. In addition, we might wish to see which traits are more or less correlated with such cutoffs, which to some extent is an indication of their polygenicity (traits with low polygenicity should lose correlations quickly). Below I have specific code for doing these analyses.

There are several interesting additional analyses for insight. First, we are interested in genomic regions in which average betas are high, but max beta or max -log10(pval) are low. These would (in general) be areas in which there are many small effect mutations but no large effect mutations that would normally be detected. We shouild compare to evolutionary constraint across the genome to see whether some disease have high/low average beta relative to constriant, with those having high beta being largely selected against. We could also check by look for consistnelry smaller betas of syn mutations in windows, plotting nonsyn avg effect vs syn avg effect (and intergenic, etc.).

Note that to some extent this is analogous to burden tests, which almost always test on a *per gene* basis. Burden tests are unencumbered by LD (for the most part).

We will test this below.

## Data
First we require some GWAS summary data. This is pulled from using the `ieugwasr` package from the ieu [Opengwas](https://gwas.mrcieu.ac.uk/) website. We filter the results so that it is limited to (1) 

### Download per study summary data 

## Lift over to HG38 / GRCh38
Most SNP datasets are HG19 / GRCh37. We port these over the GRch38 for ease of use in future analyses (syn / nonsyn, annotations, etc.). Could port eventually to T2T-CHM13. This is via `slurm` using the following syntax. We use "partial beds" to minimse file sizes, and array jobs for speed.

```
# Input and output directories
INPUT_DIR="partial-beds-GRCh37"       # Directory with input BED files (GRCh37)
OUTPUT_DIR="partial-beds-GRCh38"      # Directory for output BED files (GRCh38)
CHAIN_FILE="GRCh37_to_GRCh38.chain" # Chain file for liftover
LOG_DIR="logs"                        # Directory for logs

./liftOver "$INPUT_BED" "$CHAIN_FILE" "$OUTPUT_BED" "$UNLIFTED_BED" >> "$LOG_DIR/liftover_$SLURM_ARRAY_TASK_ID.log" 2>&1

```

### Genomic windows
Use `bedtools` to divide the genome into regions.
