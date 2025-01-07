# polygen-arch
Code for determining the polygenic nature of traits.

## Primary Aim
Most GWAS and related studies attempt to assign SNPs as causative by selecting SNPs on the basis of p-values (sometimes with some statistical corrections or with additional data such as eQTL information). These p-values are based on the combination of (1) betas (effect sizes) and (2) standard error, determined at least partially by sample size, i.e. the relative number of cases and controls, and partially by the precision with which traits can be measured.

This ignores to fact that when SNPs in a specific region of the genome are causal of trait differences, it is highly likely that other SNPs in the same region are also causal, but with lower effects. In addition, by focusing on genome-wide significant SNPs, large regions of the genome that may containt small-effect SNPs (or many small effect SNPs) are ignored. This is a critical problem because often we might expect that it is specifically these regions athat are the most relevant for developing treatments. Why? SNPs with large effects can apparently segregate in the population without having *critical* effects. This is very well phrased in this paper:

So here we ask whether we can detect these regions. We do this by averaging betas across rregions
 
This work asks whether different 
