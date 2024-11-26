# RNA-satellite-snakemake-workflow

Quantify satellite expression using as input a Dfam fastafile.
- Trim reads using cutadapt
- Align reads using bwa mem
- count reads with samtoools idxstats
- QC with multiQC.
