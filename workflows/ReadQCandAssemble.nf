include {RUN_FASTP;FASTP_JSONTOCSV} from '../modules/fastp'
include {RUN_SPADES} from '../modules/spades'

workflow ReadQCandAssemble {
    take:
    sample_reads

    main:
    RUN_FASTP(
        sample_reads
    )
    FASTP_JSONTOCSV(
        RUN_FASTP.out.fastpjson
    )
    //RUN_KRAKEN2(
    //    RUN_FASTP.out.fastpreads,
    //    params.gtdbversion,
    //    params.gtdb_path
    //)
    RUN_SPADES(
        RUN_FASTP.out.fastpreads
    )
    //RUN_QUAST(
    //    RUN_SHOVILL.out.contigs
    //)

    emit:
    trimReads = RUN_FASTP.out.fastpreads
    trimReadsCsv = FASTP_JSONTOCSV.out.fastpCsv
    denovoAss = RUN_SPADES.out.contigs
}
