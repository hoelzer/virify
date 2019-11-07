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
        if (params.nano == '' &&  params.illumina == '' &&  params.fasta == '' ) {
            exit 1, "input missing, use [--nano] or [--illumina] or [--fasta]"}

/************************** 
* INPUT CHANNELS 
**************************/

    // nanopore reads input & --list support
        if (params.nano && params.list) { nano_input_ch = Channel
                .fromPath( params.nano, checkIfExists: true )
                .splitCsv()
                .map { row -> ["${row[0]}", file("${row[1]}")] }
                .view() }
        else if (params.nano) { nano_input_ch = Channel
                .fromPath( params.nano, checkIfExists: true)
                .map { file -> tuple(file.simpleName, file) }
                .view() }

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
include './modules/kaijuGetDB' params(cloudProcess: params.cloudProcess, cloudDatabase: params.cloudDatabase)

//detection
include './modules/virsorter' params(output: params.output, dir: params.virusdir)
include './modules/virfinder' params(output: params.output, dir: params.virusdir)
include './modules/kaiju' params(output: params.output, illumina: params.illumina, nano: params.nano, fasta: params.fasta)
include './modules/filter_reads' params(output: params.output)
include './modules/kmerfreq' params(output: params.output)
include './modules/umap' params(output: params.output)
include './modules/hdbscan' params(output: params.output)
include './modules/filter_bins' params(output: params.output)
include './modules/get_reads_per_bin' params(output: params.output)
include './modules/filter_kaiju' params(output: params.output)

//qc
include './modules/fastp'
include './modules/fastqc'
include './modules/multiqc' params(output: params.output, dir: params.readQCdir)
include './modules/nanoplot' params(output: params.output)
include './modules/filtlong'

//assembly
include './modules/spades' params(output: params.output, assemblydir: params.assemblydir, memory: params.memory)
include './modules/flye' params(output: params.output)
include './modules/canu' params(output: params.output)
include './modules/medaka' params(output: params.output, model: params.model, assemblydir: params.assemblydir)
include './modules/minimap2'
include './modules/racon'
include './modules/shasta' params(output: params.output, gsize: params.gsize)

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

    main:
        // virus detection --> VirSorter and VirFinder
        virsorter(assembly, virsorter_db)
        //virfinder(fasta_input_ch)

        // ORF detection --> prodigal

        // annotation --> hmmer

}


/* Comment section:
This sub workflow is based on Beaulaurier et al. 2019, Assembly-free single-molecule nanopore sequencing
recovers complete virus genomes from natural microbial communities. [https://www.biorxiv.org/content/biorxiv/early/2019/04/26/619684.full.pdf]
*/
workflow detection_nanopore {
    get:    nanopore_reads
            kaiju_db

    main:
        //kaiju
        kaiju(filtlong(nanopore_reads), kaiju_db)

        //add virus classified reads to the read list
        filter_kaiju(kaiju.out[0])

        //krona
        krona(kaiju.out[1])

        //kmer frequencies
        //TODO run this in parallel for filter_kaiju.out[0] (cellular) and filter_kaiju.out[1] (noncellular)
        filter_reads(filter_kaiju.out[1].join(filtlong.out))
        kmerfreq(filter_reads.out[0])

        //UMAP
        umap(kmerfreq.out)

        //HDBSCAN
        hdbscan(umap.out)

        //filter bins
        filter_bins(hdbscan.out)

        //generate a fastq for each bin
        get_reads_per_bin_ch = hdbscan.out.join(filter_bins.out).join(filter_reads.out[1])
        get_reads_per_bin(get_reads_per_bin_ch)

        //flye
        //flye(get_reads_per_bin.out[0].transpose())
        //flye.out[0].view()

        //canu
        //canu(get_reads_per_bin.out[0].transpose())
        //canu.out.view()

        //Bandage?

        //filter reads

        //FastANI

        //cluster ANI

        //polishing

        //orf prediction

        //find DTR (direct terminal repeats)

}



/* Comment section:
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

/* Comment section:
*/
workflow assembly_nanopore {
    get:    reads

    main:
        // trimming and QC of trimmed reads
        filtlong(reads)
        // read QC of all reads
        nanoplot(reads)  
        // assembly with asembler choice via --assemblerLong
        if (params.assemblerLong == 'flye') { flye(filtlong.out) ; assemblerOutput = flye.out[0] ; graphOutput = flye.out[1]}
        if (params.assemblerLong == 'shasta') { shasta(filtlong.out) ; assemblerOutput = shasta.out[0] ; graphOutput = shasta.out[1]}
        // polishing 
        medaka(racon(minimap2(assemblerOutput)))

    emit:
        assemblerOutput
}


/************************** 
* WORKFLOW ENTRY POINT
**************************/

/* Comment section: */

workflow {
    //download_virsorter_db()
    //virsorter_db = download_virsorter_db.out
    download_kaiju_db()
    kaiju_db = download_kaiju_db.out

    // only detection based on an assembly
    if (params.fasta) {
        //detection(fasta_input_ch, virsorter_db)
    }

    // illumina data
    if (!params.nano && params.illumina) { 
        detection(assembly_illumina(illumina_input_ch), virsorter_db)   
    }

    // nanopore data
    if (params.nano && !params.illumina) { 
        detection_nanopore(nano_input_ch, kaiju_db)           
    }

    // hybrid data
    if (params.nano && params.illumina) { 
        
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
    nextflow run main.nf --nano '*/*.fastq' 

    ${c_yellow}Input:${c_reset}
    ${c_green} --nano ${c_reset}              '*.fasta' or '*.fastq.gz'   -> one sample per file
    ${c_green} --illumina ${c_reset}          '*.R{1,2}.fastq.gz'         -> file pairs
    ${c_green} --fasta ${c_reset}             '*.fasta'                   -> one sample per file, no assembly produced
    ${c_dim}  ..change above input to csv:${c_reset} ${c_green}--list ${c_reset}            

    ${c_yellow}Options:${c_reset}
    --cores             max cores for local use [default: $params.cores]
    --memory            max memory for local use [default: $params.memory]
    --output            name of the result folder [default: $params.output]
    --assemblerLong     long-read assembly tool used [spades, default: $params.assemblerLong]

    ${c_yellow}Parameters:${c_reset}
    --gsize             estimated genome size [default: $params.gsize]
    --virsorter         a virsorter database [default: $params.virsorter_db]

    ${c_dim}Nextflow options:
    -with-report rep.html    cpu / ram usage (may cause errors)
    -with-dag chart.html     generates a flowchart for the process tree
    -with-timeline time.html timeline (may cause errors)

    Profile:
    -profile                 standard, googlegenomics [default: standard] ${c_reset}
    """.stripIndent()
}