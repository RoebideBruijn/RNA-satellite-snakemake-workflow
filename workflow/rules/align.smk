rule bwa_mem:
    input:
        reads=["results/fastq/trimmed/{sample}.{lane}.R1.fastq.gz", "results/fastq/trimmed/{sample}.{lane}.R2.fastq.gz"],
        idx=multiext(config["bwa_mem"]["fasta"], ".amb", ".ann", ".bwt", ".pac", ".sa"),
    output:
        ""results/bam/sorted/{sample}.{lane}.bam",
    log:
        "logs/bwa_mem/{sample}.{lane}.log",
    params:
        extra=r"-R '@RG\tID:{sample}.{lane}\tSM:{sample}.{lane}'",
        sorting="samtools",  # Can be 'none', 'samtools' or 'picard'.
        sort_order="coordinate",  # Can be 'queryname' or 'coordinate'.
        sort_extra="",  # Extra args for samtools/picard.
    threads: 30
    wrapper:
        "master/bio/bwa/mem"


#bwa mem -a -t 30 references/dfam-fasta-download_satellites_primates_2024_11_05.fasta input/"+f+" | samtools sort -@30 -o output/"+f[:-9]+"_output.bam -")

 #rule sambamba_sort:
 #   input:
 #       "results/bam/star/{sample}.{lane}/Aligned.out.bam",
 #   output:
 #       "results/bam/sorted/{sample}.{lane}.bam",
 #   params:
#      config["sambamba_sort"]["extra"],
#    threads: 30
#    log:
#        "results/logs/sambamba_sort/{sample}.{lane}.log",
#    wrapper:
#        "v5.1.0/bio/sambamba/sort"

 def merge_inputs(wildcards):
    lanes = get_sample_lanes(wildcards.sample)

    file_paths = [
        "results/bam/sorted/{}.{}.bam".format(wildcards.sample, lane) for lane in lanes
    ]

    return file_paths


rule samtools_merge:
    input:
        merge_inputs,
    output:
        "results/bam/final/{sample}.bam",
    params:
        config["samtools_merge"]["extra"],
    threads: 30
    log:
        "results/logs/samtools_merge/{sample}.log",
    wrapper:
        "v5.1.0/bio/samtools/merge"       


rule samtools_index:
    input:
        "results/bam/final/{sample}.bam",
    output:
        "results/bam/final/{sample}.bam.bai",
    log:
        "results/logs/samtools_index/{sample}.log",
    wrapper:
        "v5.1.0/bio/samtools/index"