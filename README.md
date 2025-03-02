# Polygenic Architecture
This repo summarises the justifications, some literature, and the methods for doing an analysis of the extent of polygeneicity of various traits.

## Primary Aim
Most GWAS and related studies attempt to assign SNPs as causative by selecting SNPs on the basis of p-values (sometimes with some statistical corrections for LD or with additional data such as eQTL information). These p-values are based on the combination of (1) betas (effect sizes) and (2) standard error. When looking across studies, these are determined at least partially by sample size, i.e. the relative number of cases and controls, and partially by the precision with which traits can be measured. Within studies, this is determined at least partially by the frequency of polymorphisms (rare vs. common) and the choice of statistical test (e.g. logistical regression vs. chi-square).

These analyses, which prioritise on per-SNP bases, often ignore that fact that when one SNP in a specific region of the genome is causal of trait differences, it is highly likely that other SNPs in the same region are also causal, but with lower effects (it is necessarily true that one SNP has the largest effect). In addition, by focusing on genome-wide significant SNPs, large regions of the genome that may contain small-effect SNPs (or many small effect SNPs) are ignored. This is a critical problem because often we might expect that it is specifically these regions that are the most relevant for developing treatments. Why? Only SNPs with small effects on critical targets can segregate in the population. Those with large effects (but which prove that the target *can* be influenced by large effects) do not usually segregate. Phrased so well here: *small-effect-size SNPs can serve to highlight proteins that, when targeted with large-effect-size pharmaceuticals, can have large effects on disease risk.*

## Data
### Per study summary data
#### UKBB
The data we will use is the UKBB from the Neale Lab; and from the IEU GWAS resource.
From the Neale Lab: [heritability scores](https://www.dropbox.com/s/8vca84rsslgbsua/ukb31063_h2_topline.02Oct2019.tsv.gz?dl=1)
We first filter on heritbalility,
only taking those studies with h2 p-value < 1e-5.

Then we filter on notes:
``` 
isBadPower;
isExtremeSE;
isHighSE;
isLowNeff;
isMidNeff;
isSexBias;
```
Then we filter on repeated or obviously indirect effects or questionable traits, including:
- Usual side of head for mobile phone use: Left
- Cereal type: Muesli
- Workplace very noisy: Often

This is all implemented in the `ukbb-preprocess.R` script.

#### IEU GWAS
First we grab all studies using the `ieugwasr` package and the following syntx:
```
datasets <- gwasinfo()

### filter only on test
!is.na(trait) & !grepl("TEST", trait, ignore.case = TRUE)

```

The whole dataseet is filtered with the `ieu-preprocess.R`.

Finally, to remove (reduce) redundancy in ieu and ukbb, the two are intersected and only the ieu and non-redundant ukbb are used (i.e. when there are duplicates, priority is given to ieu). This is done with `ukbb-ieugwas-intersect.R`.

### Downloading
### UKBB
UKBB studies are named with a phenotype number such as 1100, 1697, etc. The vcf files for these (annotated) are available 

### IEU GWAS

`ieu-gwas-original.txt` contains descriptions for 49,455 studies.

The ieu gwas data are named by study group and number, which does not correspond to 
the ukbb number. 
For example, `ieu-b-4808` or `ukb-a-283`. These can be downloaded by incorporating
an absolute file path and checking that it is contained in one of two locations.

Notes: file `filtered-ieugwas-traits.txt` contains the study number and full description. 
`filtered-ieugwas-studies.txt` contains the numbers only that can be used for downloading (335 in total)

`filtered-ieugwas-vcf` DIRECTORY contains the downloaded vcfs. There are 316 of those. 
`small-files` DIRECTORY contains the other 19 "missing" studies, those are all vcfs less than 40Mb
(zipped), total range from 232Kb to 39Mb.

Further filtering based on average effect size for 1000 SNPs reduced this to 270, 
which was used for the 2025-02-19 analysis. This filtering removed studies with average effects less than 
1e-4 and greater than 2e2 (or something)

`filtered-ukbb-traits.txt` contains 256 studies.

`ukbb-ieugwas-intersect.txt` contains 161 studies and descriptions, none of which are in the `filtered-ieugwas-vcf` 
and despite some seeming non-heritable, are actually strong, e.g. "drive fast than speed limit" has heritbalilityat z7.

So the next step is to pull the vcf files for the `ukbb-ieugwas-intersect.txt` files. In this, do not take studies that match this: `\b(?!\d)[A-Z_][A-Z0-9_]*\b` as they are not available from ieugwas. Furthermore studies like 20002_1074 are named 20002#1074 in the ieugwas, so replace underscores.
Cannot find with ukbb ID in ieugwas manifest:
1697 Comparative height size at age 10
20117_0 Alcohol drinker status: Never
and several others. Removing those gives 128 studies in total.


(chrom sizes)[https://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.chrom.sizes]
`ml BEDTools/2.25.0-GCC-7.4.0`

Move out small `vcf` files (seems like a reasonable quality control):
`find . -type f -name "*.vcf.gz" -size -40M -exec mv {} ../small-files/ \;`

improve above step: output total SNPs for each vcf and remove those with fewer than 1.8M SNPs (there is a clear natural cutoff here). To count:

```
# also checks whether files are complete.

for G in *gz; do echo $G; echo $G >> vcf-snp-counts.txt;
zcat $G | grep PASS | wc -l >> vcf-snp-counts.txt; done
```
ieu-a-1009.vcf.gz is incomplete
ieu-b-4813.vcf.gz is incomplete

This leaves 434 studies in total.

```
ml VCFtools/0.1.15-GCC-9.2.0-Perl-5.30.1
ml BCFtools/1.19-GCC-11.3.0
```
To do this we use an array job submitted wtih `effect_sizes.slurm`.

```
sbatch --array=1-434 effect_sizes.slurm
```

Glancing through some files we see that some effects sizes are huge (> 1000). These need to be trimmed or removed.
We get an average for 1000 samples rows and then plot those to see if there is some natural cutoff.
To do that there is `bash` script.

There is a natural cutoff where the average/median should be less than 0.5 and anything where 
median is less than 1e-4 *or* mean is greater than 0.5 should be discarded.
Out of 434 studies this yields 408.

Here is the step in `R`:
```
write.table(efs[which(efs$Median>0.0001 & efs$Median<0.5),1], file="~/Desktop/good-value-studies.txt", sep="\t",quote=F, row.names=F)
```

### Full set of stats
With the redueced set of files we get the full required set of stats including beta, 
abs(beta), beta^2, pval, MAF; put in `.bed` format, sort, compress, and index.

We run `effect_sizes.slurm`.

NOTE THE FIELDS:
```
chrom, pos, pos+1, es, abs_es, es_sq, pval, af
```
ukb-d-2654_4-per is repeatedly not indexed. This is removed from the data.

Now we run `get-windowed-values.slurm

### Genomic windows
Use `bedtools` to divide the genome into regions.

### Additional QC
ukb-d-20453 has no descriptors that I can find. Removed, for a total of 406 studies.

### UMAP analysis
(On previous data) - use windowed shrucnk average betas, ~64K in total at 50Kbp bin sizes. Combining all files (unfiltered for study similarity or heritbalility) with script then clean for `NA` rows:
```awk -F'\t' '{if ($0 !~ /^(NA\t)*NA$/) print}' merged_columns.txt > cleaned_data.txt```
Remove cols with excess `NA` values
Then load into `R` for analysis using `uwot`.
Remove cols with excess `NA` values:
```filtered_data <- data[, colSums(is.na(data)) <= 3500]```
*Then* remove rows with any NA values:
```data_clean <- na.omit(filtered_data)```

## get desciptors
With assistance from ChatGPT, these are given in the trait_abbrev.txt file

## Some literature
This is very well phrased in the paper [Genetic architecture: the shape of the genetic contribution to human traits and disease](https://www.nature.com/articles/nrg.2017.101):

*The clinical effect of drugs on LDL cholesterol level and cystic fibrosis illustrate the dichotomy between variation explained and its utility to drug development...Pharmacological inhibition of HMG-CoA reductase reduces the level of LDL cholesterol by approximately 30–40%...the common SNP most strongly associated with LDL cholesterol level near HMGCR, the gene encoding HMG-CoA reductase, explains 0.26% of the variance in LDL cholesterol level...even though the HMGCR locus harbours a common genetic variant that
explains only a small amount of phenotypic variation, the pharmacological inhibition of HMG-CoA reductase is clinically beneficial...common variants near PCSK9, the gene encoding proprotein convertase subtilisin/kexin type 9, have small effects on LDL cholesterol level whereas pharmacological inhibition of PCSK9 has large effects...RANKL, the gene encoding receptor activator of nuclear factor κB ligand, harbours common variants of small effect on bone mineral density, yet pharmacological inhibition of RANKL has large effects on bone mineral density...Thus, small-effect-size SNPs can serve to highlight proteins that, when targeted with large-effect-size pharmaceuticals, can have large effects on disease risk...The amount of variance explained by a genetic variant does not always correlate with the suitability of the gene as a therapeutic target because drugs work on proteins; the base pair associated with the disease serves to help identify the causal protein. The relevance of the variation explained to the clinic should be measured by assessing the effect of pharmacological agents on the protein and its resultant effect on disease...perhaps because natural selection makes such perturbing genetic variants so rare that they lack statistical power for such an association, could still be a good drug target*

Some additional background and motivation is here 
[Specificity, length, and luck: How genes are prioritized by rare and common variant association studies Dec 2024 preprint](https://www.biorxiv.org/content/10.1101/2024.12.12.628073v1.full). This notes specifically that, as expected: 
*GWAS prioritize genes near trait-specific variants, while burden tests prioritize trait-specific genes...burden tests and GWAS reveal different aspects of trait biology*

This also gives a relatively precise (and narrow) definition of burden tests: "*Burden tests aggregate variants — typically loss-of-function (LoF) variants — within a gene to create a “burden genotype”, which is then tested gene-by-gene for association with phenotypes. This is similar to common-variant GWAS but focused on rare variants collapsed at the gene level...burden tests appear less polygenic and tend to prioritize genes that are seemingly more closely related to trait biology*"

So here we ask whether we can detect these regions. We do this by averaging betas across regions. We can then correlate average beta across a region (median or mean), average absolute value of betas (median or mean), stdev (variance) of betas, etc. Furthermore, to remove the effects of regions with very large betas, we can remove the top N regions, (e.g. the top 1000). In many (all?) cases we might use *Spearman* to minimse the effect of outlier betas. Finally, we might want to look at general effects where we think there *should* be effects, for example, nonsyn mutations. So here we can use SNPEff or similar to find out which SNPSs (rsids) have which effects, and then plot or normalise the betas from those. In addition, we might wish to see which traits are more or less correlated with such cutoffs, which to some extent is an indication of their polygenicity (traits with low polygenicity should lose correlations quickly). Below I have specific code for doing these analyses.

There are several interesting additional analyses for insight. First, we are interested in genomic regions in which average betas are high, but max beta or max -log10(pval) are low. These would (in general) be areas in which there are many small effect mutations but no large effect mutations that would normally be detected. We shouild compare to evolutionary constraint across the genome to see whether some disease have high/low average beta relative to constriant, with those having high beta being largely selected against. We could also check by look for consistnelry smaller betas of syn mutations in windows, plotting nonsyn avg effect vs syn avg effect (and intergenic, etc.). One could also window, collapse on LD (relatively high), and then average. One might also find regions with high betas in only a single disease.

Note that to some extent this is analogous to burden tests, which almost always test on a *per gene* basis. Burden tests are unencumbered by LD (for the most part).

We will test this below.