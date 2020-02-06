#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*
* Nextflow -- Virus Analysis Pipeline
* Author: hoelzer.martin@gmail.com
*/

/************************** 
* Help messages & user inputs & checks
**************************/

/* Comment section:
First part is a terminal print for additional user information, followed by some help statements (e.g. missing input)
Second part is file channel input. This allows via --list to alter the input of --nano & --illumina to
add csv instead. name,path   or name,pathR1,pathR2 in case of illumina
*/

    // terminal prints
        println " "
        println "\u001B[32mProfile: $workflow.profile\033[0m"
        println " "
        println "\033[2mCurrent User: $workflow.userName"
        println "Nextflow-version: $nextflow.version"
        println "Starting time: $nextflow.timestamp"
        println "Workdir location:"
        println "  $workflow.workDir\u001B[0m"
        println " "
        if (workflow.profile == 'standard') {
        println "\033[2mCPUs to use: $params.cores"
        println "Output dir name: $params.output\u001B[0m"
        println " "}

        if (params.help) { exit 0, helpMSG() }
        if (params.profile) {
            exit 1, "--profile is WRONG use -profile" }
        if (params.illumina == '' &&  params.fasta == '' ) {
            exit 1, "input missing, use [--illumina] or [--fasta]"}

/************************** 
* INPUT CHANNELS 
**************************/

    // illumina reads input & --list support
        if (params.illumina && params.list) { illumina_input_ch = Channel
                .fromPath( params.illumina, checkIfExists: true )
                .splitCsv()
                .map { row -> ["${row[0]}", [file("${row[1]}"), file("${row[2]}")]] }
                .view() }
        else if (params.illumina) { illumina_input_ch = Channel
                .fromFilePairs( params.illumina , checkIfExists: true )
                .view() }
    
    // direct fasta input w/o assembly support & --list support
        if (params.fasta && params.list) { fasta_input_ch = Channel
                .fromPath( params.fasta, checkIfExists: true )
                .splitCsv()
                .map { row -> ["${row[0]}", file("${row[1]}")] }
                .view() }
        else if (params.fasta) { fasta_input_ch = Channel
                .fromPath( params.fasta, checkIfExists: true)
                .map { file -> tuple(file.simpleName, file) }
                .view() }

/************************** 
* MODULES
**************************/

/* Comment section: */

//db
include './modules/virsorterGetDB' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
include './modules/viphogGetDB' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)
include './modules/kaijuGetDB' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)

//detection
include './modules/virsorter' params(output: params.output, dir: params.virusdir)
include './modules/virfinder' params(output: params.output, dir: params.virusdir)
include './modules/kaiju' params(output: params.output, illumina: params.illumina, fasta: params.fasta)
include './modules/filter_reads' params(output: params.output)
include './modules/length_filtering' params(output: params.output)
include './modules/parse' params(output: params.output)
include './modules/prodigal' params(output: params.output)
include './modules/hmmscan' params(output: params.output)
include './modules/hmm_postprocessing' params(output: params.output)
include './modules/ratio_evalue' params(output: params.output)
include './modules/annotation' params(output: params.output)
include './modules/mapping' params(output: params.output)
include './modules/assign' params(output: params.output)

//visuals
include './modules/krona' params(output: params.output)


/************************** 
* DATABASES
**************************/

/* Comment section:
The Database Section is designed to "auto-get" pre prepared databases.
It is written for local use and cloud use.*/


workflow download_virsorter_db {
    main:
    // local storage via storeDir
    if (!params.cloudProcess) { virsorterGetDB(); db = virsorterGetDB.out }
    // cloud storage via db_preload.exists()
    if (params.cloudProcess) {
      db_preload = file("${params.cloudDatabase}/virsorter/virsorter-data")
      if (db_preload.exists()) { db = db_preload }
      else  { virsorterGetDB(); db = virsorterGetDB.out } 
    }
  emit: db    
}

workflow download_viphog_db {
    main:
    // local storage via storeDir
    if (!params.cloudProcess) { viphogGetDB(); db = viphogGetDB.out }
    // cloud storage via db_preload.exists()
    if (params.cloudProcess) {
      db_preload = file("${params.cloudDatabase}/vpHMM_database/vpHMM_database")
      if (db_preload.exists()) { db = db_preload }
      else  { viphogGetDB(); db = viphogGetDB.out } 
    }
  emit: db    
}


workflow download_kaiju_db {
    main:
    // local storage via storeDir
    if (!params.cloudProcess) { kaijuGetDB(); db = kaijuGetDB.out }
    // cloud storage via db_preload.exists()
    if (params.cloudProcess) {
      db_preload = file("${params.cloudDatabase}/kaiju/nr_euk")
      if (db_preload.exists()) { db = db_preload }
      else  { kaijuGetDB(); db = kaijuGetDB.out } 
    }
  emit: db    
}


/************************** 
* SUB WORKFLOWS
**************************/

/* Comment section:
*/
workflow detection {
    get:    assembly
            virsorter_db
            viphog_db

    main:
        // filter contigs by length
        length_filtering(assembly)

        // virus detection --> VirSorter and VirFinder
        virsorter(length_filtering.out, virsorter_db)     
        virfinder(length_filtering.out)

        // parsing predictions
        parse(length_filtering.out.join(virfinder.out).join(virsorter.out))
        parse.out.transpose().view()

        // ORF detection --> prodigal
        prodigal(parse.out.transpose())
        prodigal.out.view()

        // annotation --> hmmer
        hmmscan(prodigal.out, viphog_db)
        hmm_postprocessing(hmmscan.out)

        ratio_evalue(hmmscan.out)

        annotation(ratio_evalue.out, prodigal.out)

        mapping(annotation.out)
        assign(annotation.out)
}


/* Comment section:
Maybe as an pre-step
*/
workflow assembly_illumina {
    get:    reads

    main:
        // trimming --> fastp
        fastp(reads)
 
        // read QC --> fastqc/multiqc?
        multiqc(fastqc(fastp.out))

        // assembly with asembler choice --> metaSPAdes
        spades(fastp.out)

    emit:
        spades.out
}


/************************** 
* WORKFLOW ENTRY POINT
**************************/

/* Comment section: */

workflow {
    if (params.virsorter) {
        virsorter_db = file(params.virsorter)
    } else {
        download_virsorter_db()
        virsorter_db = download_virsorter_db.out
    }

    if (params.viphog) {
        viphog_db = file(params.viphog)
    } else {
        download_viphog_db()
        viphog_db = download_viphog_db.out
    }


    //download_kaiju_db()
    //kaiju_db = download_kaiju_db.out

    // only detection based on an assembly
    if (params.fasta) {
        detection(fasta_input_ch, virsorter_db, viphog_db)
    }

    // illumina data
    if (params.illumina) { 
        assembly_illumina(illumina_input_ch)           
    }

}




/*************  
* --help
*************/
def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """
    ____________________________________________________________________________________________
    
    VIRify
    
    ${c_yellow}Usage example:${c_reset}
    nextflow run main.nf --fasta 'assembly.fasta' 

    ${c_yellow}Input:${c_reset}
    ${c_green} --illumina ${c_reset}          '*.R{1,2}.fastq.gz'         -> file pairs
    ${c_green} --fasta ${c_reset}             '*.fasta'                   -> one sample per file, no assembly produced
    ${c_dim}  ..change above input to csv:${c_reset} ${c_green}--list ${c_reset}            

    ${c_yellow}Options:${c_reset}
    --cores             max cores for local use [default: $params.cores]
    --memory            max memory for local use [default: $params.memory]
    --output            name of the result folder [default: $params.output]

    ${c_yellow}Parameters:${c_reset}
    --virsorter         a virsorter database [default: $params.virsorter]
    --viphog            a viphog database [default: $params.viphog]

    ${c_dim}Nextflow options:
    -with-report rep.html    cpu / ram usage (may cause errors)
    -with-dag chart.html     generates a flowchart for the process tree
    -with-timeline time.html timeline (may cause errors)

    Profile:
    -profile                 standard, googlegenomics [default: standard] ${c_reset}
    """.stripIndent()
}