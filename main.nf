#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.input = 'test_samplesheet.csv'
params.outdir = 'demultiplexed'

//rename_rawdir = params.outdir+'/demultiplexed'


// set up raw reads (id, r1, r2) as channel raw_ch
include { fromSamplesheet } from 'plugin/nf-validation'
Channel.fromSamplesheet("input")
    .multiMap { meta, fastq_1, fastq_2, newid, guide, amplicon -> 
        rawreads: [meta, fastq_1, fastq_2, newid]
        editargs: [meta, newid, guide, amplicon]
        }
        .set { raw_ch }

raw_ch.rawreads.view()
raw_ch.editargs.view()


workflow {
    read_rename( raw_ch.rawreads )
    arg_parse( raw_ch.editargs )
}

process read_rename {

    input:
    tuple val(meta), path(r1), path(r2), val(newid)

    output:
    tuple val(newid), path("${newid}_R1.fq.gz"), path("${newid}_R2.fq.gz")

    publishDir params.outdir, mode: 'copy'

    script:
    """
    gsutil -m cp $r1 ${newid}_R1.fq.gz
    gsutil -m cp $r2 ${newid}_R2.fq.gz
    """
}

process arg_parse {
    
    input:
    tuple val(meta), val(newid), val(guide), val(amplicon)

    output:
    stdout

    script:
    """
    echo -e $newid'\t'$guide'\t'$amplicon
    """

}