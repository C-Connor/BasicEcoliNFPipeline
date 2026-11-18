process RUN_SPADES {
    conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_8'
    tag "${id}"
    //errorStrategy 'ignore'

    input:
    tuple val(id), path(fwread), path(rvread)
    
    output:
    path("${id}_spades/"), emit: spadesdir
	tuple val(id), path("${id}_contigs.fa"), emit: contigs 
    
    script:
    """
	spades.py \
        --isolate \
		--threads 8 \
		-o ${id}_spades \
		-1 ${fwread} -2 ${rvread} \
		&& \
		cp ${id}_spades/contigs.fasta ${id}_contigs.fa
    """
}



// SHOVILL container was getting stuck for some reason, unclear why
// process RUN_SHOVILL {
//     conda "${moduleDir}/environment.yml"
//     cache 'lenient'
//     label 'process_8'
//     tag "${id}"
//     errorStrategy 'ignore'

//     input:
//     tuple val(id), path(fwread), path(rvread)
    
//     output:
//     path("${id}_shovill/"), emit: shovilldir
// 	tuple val(id), path("${id}_contigs.fa"), emit: contigs 
    
//     script:
//     """
// 	shovill \
// 		--cpus 8 \
// 		--outdir ${id}_shovill \
// 		--R1 ${fwread} --R2 ${rvread} \
// 		--minlen 200 \
// 		&& \
// 		cp ${id}_shovill/contigs.fa ${id}_contigs.fa
//     """
// }