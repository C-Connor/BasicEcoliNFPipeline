process RUN_KLEBORATE {
    conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_8'
    tag "${id}"
    //errorStrategy 'ignore'

    input:
    tuple val(id), path(assembly)
    
    output:
	tuple val(id), path("${id}_kleborate.tab"), emit: kleborateResult
    
    script:
    //rename strain column to SampleID, and move outside directory
    //convert to csv file
    """
    kleborate \
        --threads 8 \
        -a ${assembly} \
        -o ${id}_kleborateOut \
        -p escherichia \
        -m klebsiella__cbst
    cp ${id}_kleborateOut/klebsiella__cbst_output.txt ${id}_kleborate.tab
    """
}