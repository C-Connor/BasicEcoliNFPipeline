process RUN_KAPTIVE {
    conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_8'
    tag "${id}"
    //errorStrategy 'ignore'

    input:
    path(db)
    tuple val(id), path(assembly)
    
    output:
	tuple val(id), path("${id}_kaptive.tab"), emit: kaptiveResult
    
    script:
    """
    kaptive assembly \
        ${db} \
        ${assembly} \
        -o ${id}_kaptive.tab \
        --threads 8
    """
}