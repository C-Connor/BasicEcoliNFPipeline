include {CSVTK_KLEBORATE;CSVTK_ABRITAMR;CSVTK_EZCLERMONT;CSVTK_KAPTIVE;CSVTK_JOIN;CSVTK_CONCAT} from '../modules/csvtk'

workflow Collate {
    take:
    fastpCsv //tuple val(id), path(csv)
    kleborateResult //tuple val(id), path(results)
    abritamrResult
    ezclermontResult
    kaptiveResult


    main:
    // combine read qc and results first, then combine rows
    // avoids large pattern matching search?
    //fastpCsv isn't available for genome only input - handled in processes

    //convert kleborate output to csv and rename column
    CSVTK_KLEBORATE(kleborateResult)

    CSVTK_ABRITAMR(abritamrResult)

    CSVTK_EZCLERMONT(ezclermontResult)

    CSVTK_KAPTIVE(kaptiveResult)

    //have to map in BLANK.csv to get around null path error
    //BLANK.csv filtered out in CSVTK_JOIN
    rows = CSVTK_KLEBORATE.out.kleborateCsv
        .join(
            fastpCsv,
            remainder : true
        )
        .join(
            CSVTK_ABRITAMR.out.abritamrCsv,
            remainder : true
        )
        .join(
            CSVTK_EZCLERMONT.out.ezclermontCsv,
            remainder : true
        )
        .join(
            CSVTK_KAPTIVE.out.kaptiveCsv,
            remainder : true
        )
        .map { sample_id, kleborateCsv, fastpCsv, abritamrCsv, ezclermontCsv, kaptiveCsv ->
            [
                sample_id,
                kleborateCsv ?: file("$projectDir/assets/BLANK.csv"),
                fastpCsv ?: file("$projectDir/assets/BLANK.csv"),
                abritamrCsv ?: file("$projectDir/assets/BLANK.csv"),
                ezclermontCsv ?:file("$projectDir/assets/BLANK.csv"),
                kaptiveCsv ?: file("$projectDir/assets/BLANK.csv")
            ]
        }

    CSVTK_JOIN(rows).collect() | CSVTK_CONCAT

    emit:
    fullCsv = CSVTK_CONCAT.out
}