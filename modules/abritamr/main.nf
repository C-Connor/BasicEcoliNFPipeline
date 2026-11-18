process RUN_ABRITAMR {
	conda "${moduleDir}/environment.yml"
	cache 'lenient'
	label 'process_8'
	tag "${id}"
	//errorStrategy 'ignore'

	input:
	tuple val(id), path(contigs)
	
	output:
	tuple val(id), path("${id}"), emit: abritamrdir
	tuple val(id), path("${id}_abritamr.tab"), emit: abritamrfile
	
	script:
	"""
	abritamr run \
		-c ${contigs} \
		-px ${id} \
		-j 8 \
		--species Escherichia
	if [[ -f ${id}/abritamr.txt ]]; then
        cp ${id}/abritamr.txt ${id}_abritamr.tab
    else
        # create minimal TSV
        printf "Isolate\n%s\n" "${id}" > ${id}_abritamr.tab
    fi
	"""
}