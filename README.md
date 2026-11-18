# Basic Nextflow pipeline for quick E. coli analysis

Pipeline intended to take publicaly available data (fastq and / or assemblies), run QC checks, assemble and run basic characterisation (using Kleborate E. coli modules). Also runs capsule typing.

For running pipeline, copy repository `git clone`. Create run environment with conda `conda env create -f environment.yml`.



For creating input files (fastq)

```bash
#for creating read input file
for f in *.fastq.gz ; do echo ${f%_[1-2].fastq.gz} ; done | sort | uniq > ../id.list

paste id.list <(realpath reads/*_1.fastq.gz) <(realpath reads/*_2.fastq.gz) > input_reads.list
```

For creating input files (assemblies)

```bash
#for creating assembly input file
for dir in */ ; do sample=$(basename "$dir") ; fasta=$(realpath "$dir"/*.fna) ; echo -e "${sample}\t${fasta}" ; done > ../input_assembly.list
```


For running pipeline

```bash
nextflow run main.nf --input_reads input_reads.list --input_ass input_assembly.list -c nextflow.config -resume
```


Pipeline uses Wave containers for each process.

To find the software versions used in analysis `modules > <tool name> > environment.yaml`. To get the commands / parameters specified for tool runs `modules > <tool name> > main.nf`, below the `script:` line is tool command, with some post-processing steps to get the results into a nice format.


