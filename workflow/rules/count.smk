from os import path
import numpy as np



#rule feature_counts:
#    input:
#        samples="results/bam/final/{sample}.bam",
#        annotation=config["feature_counts"]["annotation"],
#    output:
#        "results/counts/per_sample/{sample}.txt",
 #   params:
 #       extra=" -p",
 #   threads: config["feature_counts"]["threads"]
  #  log:
  #      "results/logs/feature_counts/{sample}.txt",
  #  wrapper:
  #      "v4.5.0/bio/subread/featurecounts"

rule samtools_idxstats:
    input:
        bam="results/bam/final/{sample}.bam",
        idx="results/bam/final/{sample}.bam.bai",
    output:
        "results/counts/per_sample/{sample}.txt",
    log:
        "results/logs/samtools/idxstats/{sample}.log",
    params:
        extra="",  # optional params string
    wrapper:
        "v5.1.0/bio/samtools/idxstats"

rule merge_counts:
    input:
        expand("results/counts/per_sample/{sample}.txt", sample=get_samples()),
    output:
        "results/counts/merged.txt",
    log:
        "results/logs/merge_counts.txt",
    run:
        # Merge count files.
        frames = (
            pd.read_csv(fp, sep="\t", skiprows=1, index_col=list(range(6)))
            for fp in input
        )
        merged = pd.concat(frames, axis=1)

        # Extract sample names.
        merged = merged.rename(columns=lambda c: path.splitext(path.basename(c))[0])

        merged.to_csv(output[0], sep="\t", index=True)