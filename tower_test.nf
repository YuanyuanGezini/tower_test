#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.gcloud_dir = ''
rename_rawdir = params.gcloud_dir+'/demultiplexed'

// set up raw reads (id, r1, r2) as channel raw_ch
Channel
    .fromFilePairs("gs://starlit-myth-tower/ngs_test/wR1-AAVS1-2-TR1_S1_L001_R{1,2}_001.fastq.gz", checkIfExists: true, flat:true)
    .map{ id, file1, file2 -> tuple(file1.simpleName.replaceFirst(/_L001_R1_001/, ''), file1, file2) }
    .set { raw_ch }


workflow {
    read_rename(raw_ch?)
    raw_reads_count(?)
}

process read_rename {

    input:
    tuple val(id), path(r1), path(r2)
    tuple val(newid)

    output:
    tuple val(newid), path("${newid}_R1.fq.gz"), path("${newid}_R2.fq.gz")

    publishDir rename_rawdir, mode: 'copy'

    script:
    """
    mv $r1 ${newid}_R1.fq.gz
    mv $r2 ${newid}_R2.fq.gz
    """
}

process arg_parse {
    
    input:
    tuple val(newid), val(guide), val(amplicon)

    output:
    stdout

    script:
    """
    echo -e $newid'\t'$guide'\t'$amplicon
    """

}