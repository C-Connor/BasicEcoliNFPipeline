process CSVTK_KLEBORATE {
    //conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_1'
    tag "${id}"
    //errorStrategy 'ignore'
    
    input:
    tuple val(id), path(tab)

    output:
    tuple val(id), path("${id}_kleborate.csv"), emit: kleborateCsv

    script:
    //rename column, stip _contigs out and convert to csv
    //clean long assembly names as well
    """
    csvtk tab2csv ${tab} \
        | csvtk rename -f strain -n SampleID \
        | csvtk replace -f "SampleID" -p "_contigs\$" -r "" \
        | csvtk replace -f "SampleID" -p '(\\.\\d+)_.+\$' -r '\$1' \
        | csvtk rename2 -f -SampleID -p "(.+)" -r 'KLEBORATE::\${1}' \
        > ${id}_kleborate.csv
    """
}

process CSVTK_ABRITAMR {
    //conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_1'
    tag "${id}"
    //errorStrategy 'ignore'
    
    input:
    tuple val(id), path(tab)

    output:
    tuple val(id), path("${id}_abritamr.csv"), emit: abritamrCsv

    script:
    //rename column, stip _contigs out and convert to csv
    """
    csvtk tab2csv ${tab} \
        | csvtk rename -f Isolate -n SampleID \
        | csvtk rename2 -f -SampleID -p "(.+)" -r 'ABRITAMR::\${1}' \
        > ${id}_abritamr.csv
    """
}

process CSVTK_EZCLERMONT {
    //conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_1'
    tag "${id}"
    //errorStrategy 'ignore'
    
    input:
    tuple val(id), path(tab)

    output:
    tuple val(id), path("${id}_ezclermont.csv"), emit: ezclermontCsv

    script:
    """
    csvtk tab2csv ${tab} \
        | csvtk add-header -n SampleID,EZCLERMONT::PhyloGroup \
        | csvtk replace -f "SampleID" -p "_contigs\$" -r "" \
        | csvtk replace -f "SampleID" -p '(\\.\\d+)_.+\$' -r '\$1' \
         > ${id}_ezclermont.csv
    """
}

process CSVTK_KAPTIVE {
    //conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_1'
    tag "${id}"
    //errorStrategy 'ignore'
    
    input:
    tuple val(id), path(tab)

    output:
    tuple val(id), path("${id}_kaptive.csv"), emit: kaptiveCsv

    script:
    """
    csvtk tab2csv ${tab} \
        | csvtk rename -f Assembly -n SampleID \
        | csvtk replace -f "SampleID" -p "_contigs\$" -r "" \
        | csvtk replace -f "SampleID" -p '(\\.\\d+)_.+\$' -r '\$1' \
        | csvtk rename2 -f -SampleID -p "(.+)" -r 'KAPTIVE::\${1}' > ${id}_kaptive.csv
    """
}

process CSVTK_JOIN {
    // merge all blasthits from a tool in python
    // when collating blasthits need to account for multiple matches, matches are collapsed into , separated values
    //conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_1'
    tag "${id}"
    //errorStrategy 'ignore'
    
    input:
    tuple val(id), path(kleb_csv), path(read_csv), path(abritamr_csv), path(ezclermont_csv), path(kaptive_csv) //,path(blast_csv)

    output:
    path("${id}.joined.csv"), emit: joined_csv

    script:
    //handle instances where there is a missing csv (e.g. assembly only isolates)
    def files = [kleb_csv, read_csv, abritamr_csv, ezclermont_csv, kaptive_csv].findAll { it.name != "BLANK.csv" && it.size() > 0 }
    if (files.size() == 0) error "No valid CSV files found for ${id}"
    
    if (files.size() > 1)
        """
        csvtk join -f "SampleID" ${files.join(' ')} > ${id}.joined.csv
        """
    else
        """
        cp ${files[0]} ${id}.joined.csv
        """
}

process CSVTK_CONCAT {
    // merge all blasthits from a tool in python
    // when collating blasthits need to account for multiple matches, matches are collapsed into , separated values
    //conda "${moduleDir}/environment.yml"
    cache 'lenient'
    label 'process_1'
    //tag "${id}"
    //errorStrategy 'ignore'
    
    input:
    path(csv_files)

    output:
    path("FullResults.csv"), emit: fullcsv

    script:
    //re-order columns to put read columns first?
    """
    csvtk concat ${csv_files} > FullResults.csv
    """
}
