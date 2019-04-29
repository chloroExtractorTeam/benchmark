#!/usr/bin/env nextflow

/*
* Nextflow workflow for performance measurement for chloroplast assemblers
*
* Author:
* Frank Förster <frank.foerster@ime.fraunhofer.de>
*/


/*
* Defines the input sequence files as parameters
*/
/* params.reads    = "$baseDir/raw/*_R{1,2}*.fastq.gz" */
params.cpus     = 4

log.info """\
         PERFORMANCE MEASUREMENT FOR CHLOROPLAST ASSEMBLY PIPELINES
         ==========================================================
         reads    : ${params.reads}
         cpus     : ${params.cpus}
         """
.stripIndent()

/*
* Create the `read_pairs` channel that emits tuples containing three elements:
* the pair ID, the first read-pair file and the second read-pair file
*/

Channel
.fromFilePairs( params.reads )
.ifEmpty { error "Cannot find any reads matching: ${params.reads}" }
.view()
.set { read_pairs_preparation }

/*
* Create the `cpus` channel that emits the number of CPUs to use
*/
cpus = Channel.value( params.cpus )

process prepare_reads {
    tag "$pair_id"

    input:
    set pair_id, file(reads) from read_pairs_preparation

    output:
    file("*") into prepared_reads

    container 'chloroextractorteam/benchmark_chloroextractor:v1.0.9'

    script:
    forward=reads[0].toString()
    reverse=reads[1].toString()
    """
    # copy both read sets
    zcat $forward >forward.changed.fq
    zcat $reverse >reverse.changed.fq

    # generate quality information
    random_qual.pl forward.changed.fq
    random_qual.pl reverse.changed.fq

    # prepare beacons
    mkdir "read_sets_changed.started"
    touch read_sets_changed.done
    touch forward.fq
    touch reverse.fq

    """
}

prepared_reads.into{prepared_reads_ce;prepared_reads_orgasm;prepared_reads_getorganelle}

process chloroextractor {
    validExitStatus 0,129
    publishDir "$baseDir/chloroextractor", mode: 'copy', overwrite: false

    input:
    file(input) from prepared_reads_ce
    val cpu from cpus

    output:
    file("*.log") into chloroextractor_log
    file("chloroextractor/output.fa") into chloroextractor_assembly
    file("chloroextractor/ptx/ass/*.fastg") into chloroextractor_assembly_fastg
    file("chloroextractor/ptx/ass/*.gfa") into chloroextractor_assembly_gfa

    container 'chloroextractorteam/benchmark_chloroextractor:v1.0.9'

    script:
    """
    export NUMCPUS=$cpu
    wrapper.sh 2>&1 | tee --append chloroextractor.log
    """
}

process org_asm {
    validExitStatus 0,129
    publishDir "$baseDir/org-asm", mode: 'copy', overwrite: false

    input:
    file(input) from prepared_reads_orgasm
    val cpu from cpus

    output:
    file("*.log") into org_asm_log
    file("org-asm/output.fa") into org_asm_assembly

    container 'chloroextractorteam/benchmark_org-asm:v1.0.9'

    script:
    """
    export NUMCPUS=$cpu
    wrapper.sh 2>&1 | tee --append org-asm.log
    """
}

process getorganelle {
    validExitStatus 0,129
    publishDir "$baseDir/getorganelle", mode: 'copy', overwrite: false

    input:
    file(input) from prepared_reads_getorganelle
    val cpu from cpus

    output:
    file("*.log") into getorganelle_log
    file("get_organelle/output.fa") into getorganelle_assembly

    container 'chloroextractorteam/benchmark_getorganelle:v1.0.9'

    script:
    """
    export NUMCPUS=$cpu
    wrapper.sh 2>&1 | tee --append org-asm.log
    """
}
