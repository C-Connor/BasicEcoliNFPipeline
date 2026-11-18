include { ReadQCandAssemble } from './workflows/ReadQCandAssemble'
include { BasicGenomics } from './workflows/BasicGenomics'
include { Collate } from './workflows/Collate'

process STAGE_TO_PUBLISH {
    cache 'lenient'
    label 'process_1'
    tag "${id}"
    errorStrategy 'ignore'

    input:
    tuple val(id), path(assembly)
    
    output:
	tuple val(id), path(assembly)
    
    script:
    //stage input assemblies so they can be published
    """
    #do nothing
    """
}

workflow {
    sample_reads = Channel
        .fromPath(params.input_reads)
        .splitCsv(sep:'\t', header:['id','fastq1','fastq2'])
        .map { row ->
            [row.id,
            file(row.fastq1, checkIfExists: true),
            file(row.fastq2, checkIfExists: true)
            ]
        }

    sample_assemblies = Channel
        .fromPath(params.input_ass)
        .splitCsv(sep:'\t', header:['id','assembly'])
        .map { row ->
            [row.id,
            file(row.assembly, checkIfExists: true)
            ]
        }

    main:
    ReadQCandAssemble(
        sample_reads
    )

    STAGE_TO_PUBLISH(sample_assemblies)

    genome_assemblies = STAGE_TO_PUBLISH.out.mix(
        ReadQCandAssemble.out.denovoAss
    )

    BasicGenomics(
        file(params.ec_kaptive_db,checkIfExists:true),
        genome_assemblies
    )

    // RUN_KLEBORATE(
    //     genome_assemblies
    // )

    Collate(
        ReadQCandAssemble.out.trimReadsCsv,
        //RUN_KLEBORATE.out.kleborateResult
        BasicGenomics.out.kleborate_results,
        BasicGenomics.out.abritamr_results,
        BasicGenomics.out.ezclermont_results,
        BasicGenomics.out.kaptive_results
    )

    publish:
    contigs = genome_assemblies 
    combinedCsv = Collate.out.fullCsv 
}

output {
    contigs {
        path "AllGenomeAssemblies/" 
        mode 'symlink'
    }
    combinedCsv {
        mode 'symlink'
    }
}
