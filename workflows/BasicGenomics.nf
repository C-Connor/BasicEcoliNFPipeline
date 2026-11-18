include { RUN_KLEBORATE     } from '../modules/kleborate'
include { RUN_ABRITAMR } from '../modules/abritamr'
include { RUN_EZCLERMONT } from '../modules/ezclermont'
include { RUN_KAPTIVE } from '../modules/kaptive'

workflow BasicGenomics {
    take:
    kaptive_db
    sample_assemblies

    main:
    RUN_KLEBORATE(
        sample_assemblies
    )
    
    RUN_ABRITAMR(
        sample_assemblies
    )

    RUN_EZCLERMONT(
        sample_assemblies
    )

    RUN_KAPTIVE(
        kaptive_db,
        sample_assemblies
    )

    emit:
    kleborate_results = RUN_KLEBORATE.out.kleborateResult
    abritamr_results = RUN_ABRITAMR.out.abritamrfile
    ezclermont_results = RUN_EZCLERMONT.out.ezclermontResult
    kaptive_results = RUN_KAPTIVE.out.kaptiveResult
}