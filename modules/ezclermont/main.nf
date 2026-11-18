process RUN_EZCLERMONT {
    conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_1'
    tag "${id}"
    //errorStrategy 'ignore'

    input:
    tuple val(id), path(assembly)
    
    output:
	tuple val(id), path("${id}_clermont.tab"), emit: ezclermontResult
    
    script:
    """
    ezclermont \
        ${assembly} \
        1> ${id}_clermont.tab \
        2> ${id}_clermont.log
    """
}