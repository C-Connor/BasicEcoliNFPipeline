process RUN_FASTP {
    conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_8'
    tag "${id}"
    //errorStrategy 'ignore'


    input:
    tuple val(id), path(fwread), path(rvread)
    
    output:
    tuple val(id), \
		path("${id}_R1.trimmed.fastq.gz"), \
		path("${id}_R2.trimmed.fastq.gz"), \
		emit: fastpreads
	tuple val(id), path("${id}_fastp.json"), emit: fastpjson
	tuple val(id), path("${id}_fastp.html"), emit: fastphtml
    
    script:
    """
    fastp \
		-w 3 \
		-r \
		-W 4 \
		-M 20 \
		-l 36 \
		-j ${id}_fastp.json \
		-h ${id}_fastp.html \
		-R '${id}' \
		-i ${fwread} \
		-I ${rvread} \
		-o ${id}_R1.trimmed.fastq.gz \
		-O ${id}_R2.trimmed.fastq.gz
    """
}

process FASTP_JSONTOCSV {
    conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_1'
    tag "${id}"
    //errorStrategy 'ignore'

    input:
    tuple val(id), path(fastpJson)
    
    output:
    tuple val(id), path("${id}_fastp.csv"), emit: fastpCsv
    
    script:
	// might need to include 
	// | map(tostring) | @csv
	// instead of | @ csv to force "" around all values
	//might need to swtich to a shell block due to bash variables and nextflow variable clash
    """
	jq -r --arg sample "${id}" '
		["SampleID", "FASTP::total_reads_before", "FASTP::total_bases_before", "FASTP::gc_content_before", "FASTP::q30_rate_before",
					"FASTP::total_reads_after",  "FASTP::total_bases_after", "FASTP::gc_content_after",  "FASTP::q30_rate_after"],
		[\$sample,
		.summary.before_filtering.total_reads,
		.summary.before_filtering.total_bases,
		.summary.before_filtering.gc_content,
		.summary.before_filtering.q30_rate,
		.summary.after_filtering.total_reads,
		.summary.after_filtering.total_bases,
		.summary.after_filtering.gc_content,
		.summary.after_filtering.q30_rate]
		| @csv
		' ${fastpJson} > ${id}_fastp.csv
    """
}