#!/usr/bin/env nextflow
nextflow.preview.dsl=2

/*
* Nextflow -- Analysis Pipeline
* Author: christian.jena@gmail.com
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
        if (params.nano == '' &&  params.illumina == '' ) {
            exit 1, "input missing, use [--nano] or [--illumina]"}

    // nanopore reads input & --list support
        if (params.nano && params.list) { nano_input_ch = Channel
                .fromPath( params.nano, checkIfExists: true )
                .splitCsv()
                .map { row -> ["${row[0]}", file("${row[1]}")] }
                .view() }
        else if (params.nano) { nano_input_ch = Channel
                .fromPath( params.nano, checkIfExists: true)
                .map { file -> tuple(file.baseName, file) }
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
    


/************************** 
* DATABASES
**************************/

/* Comment section:
The Database Section is designed to "auto-get" pre prepared databases.
It is written for local use and cloud use.
It also comes with a "auto-download" if a database is not available. Doing it the following way:
1. take userinput DB 2. add a cloud preload DB if cloud profile 3. check if the preload file exists (local or cloud)
4. if nothing is true -> download the DB and store it in the "preload" section (either cloud or local for step 3.)
*/

// get Virsorter Database
include 'modules/virsorterGetDB'
virsorterGetDB() 
database_virsorter = virsorterGetDB.out

/*
=======
>>>>>>> parent of c6d3749... implement initial pipeline steps
    // sourmash database
        // set cloud preload to empty
        sour_db_preload = ''
        // put user input or cloud preload into the database channel
        if (params.sour_db) { database_sourmash = file(params.sour_db) }
        else if (workflow.profile == 'googlegenomics' && (params.nano)) {
                sour_db_preload = file("gs://databases-nextflow/databases/sourmash/genbank-k31.lca.json") }
        if (workflow.profile == 'googlegenomics' && sour_db_preload.exists()) { database_sourmash = sour_db_preload }    
        // if preload and user input not present download the database
        if (!params.sour_db && !sour_db_preload && params.nano) {
                    include 'modules/sourmashgetdatabase'
                    sourmash_download_db() 
                    database_sourmash = sourmash_download_db.out } 

*/


/************************** 
* ILLUMINA ONLY WORKFLOW
**************************/

/* Comment section:


*/

if (!params.nano && params.illumina) {

    // modules
    include 'modules/fastp'
    include 'modules/fastqc'
    include 'modules/multiqc' params(output: params.output, readQCdir: params.readQCdir)
    include 'modules/spades' params(output: params.output, assemblydir: params.assemblydir, memory: params.memory)
    include 'modules/virsorter' params(output: params.output, virusdir: params.virusdir)
    include 'modules/virfinder' params(output: params.output, virusdir: params.virusdir)

    // Workflow            
        // trimming --> fastp
        fastp(illumina_input_ch)
 
        // read QC --> fastqc/multiqc?
        multiqc(fastqc(fastp.out))

        // assembly with asembler choice --> metaSPAdes
        if (params.assemblerLong == 'spades') { spades(fastp.out) ; assemblerOutput = spades.out }

        // virus detection --> VirSorter and VirFinder
        virsorter(spades.out, database_virsorter)
        virfinder(spades.out)


        // ORF detection --> prodigal

        // annotation --> hmmer

}










=======
>>>>>>> parent of c6d3749... implement initial pipeline steps
/************************** 
* NANOPORE ONLY WORKFLOW
**************************/

/* Comment section:
ONT-only Assembly Workflow Section. Contains:
    Read Filtering, Assembly, Polishing, Annotation etc.

Improvement Section:
Augustus makes sense and we can use it, would be good if it can download RNA-seq data and genes to generate model

Alternative assembly: 
shasta (https://github.com/chanzuckerberg/shasta)
https://www.biorxiv.org/content/10.1101/183780v1

Mitos workflow: mitochondriale prediction mit simplen circulärer plot 
https://academic.oup.com/nar/article/47/11/e63/5377471
*/

if (params.nano && !params.illumina) {

    // modules
        include 'modules/bandage' params(output: params.output, assemblydir: params.assemblydir)
        include 'modules/busco' params(output: params.output)
        include 'modules/filtlong'
        include 'modules/flye' params(output: params.output, gsize: params.gsize)
        include 'modules/medaka' params(output: params.output, model: params.model, assemblydir: params.assemblydir)
        include 'modules/minimap2'
        include 'modules/nanoplot' params(output: params.output)
        include 'modules/racon'
        include 'modules/removeSmallReads' params(output: params.output)
        include 'modules/shasta' params(output: params.output, gsize: params.gsize)
        include 'modules/sourclass' params(output: params.output)

    // Workflow
        // trimming and QC of trimmed reads
            filtlong(nano_input_ch)
        // read QC of all reads
            nanoplot(nano_input_ch)  
        // assembly with asembler choice via --assemblerLong
            if (params.assemblerLong == 'flye') { flye(filtlong.out) ; assemblerOutput = flye.out[0] ; graphOutput = flye.out[1]}
            if (params.assemblerLong == 'shasta') { shasta(filtlong.out) ; assemblerOutput = shasta.out[0] ; graphOutput = shasta.out[1]}
        // polishing 
            medaka(racon(minimap2(assemblerOutput)))
        // tax. classification
            sourclass(medaka.out, database_sourmash)
        // assembly graph
            bandage(graphOutput)
        // annotation
            /* see here: https://galaxyproject.github.io/training-material/topics/genome-annotation/tutorials/annotation-with-maker/tutorial.html
             augustus
             get or include more models to predict the genes
            */
        // busco “Mode”: Genome “Lineage”: fungi_odb9
            busco(medaka.out)    
                 
}

/************************** 
* ILLUMINA ONLY WORKFLOW
**************************/

/* Comment section:


*/

if (!params.nano && params.illumina) {

    // modules


    // Workflow
        // read QC
            
        // trimming
            
        // assembly with asembler choice
            
        // polishing 

        // tax. classification

        // assembly graph

}

/************************** 
* HYBRID WORKFLOW
**************************/

/* Comment section:


*/






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
    
    Product: Reconstruct strains for eukaryotic cells
    
    ${c_yellow}Usage example:${c_reset}
    nextflow run wf_reconstruct-strains_eukaryotic --nano '*/*.fastq' 

    ${c_yellow}Input:${c_reset}
    ${c_green} --nano ${c_reset}            '*.fasta' or '*.fastq.gz'   -> one sample per file
    ${c_green} --illumina ${c_reset}        '*.R{1,2}.fastq.gz'         -> file pairs
    ${c_dim}  ..change above input to csv:${c_reset} ${c_green}--list ${c_reset}            

    ${c_yellow}Options:${c_reset}
    --cores             max cores for local use [default: $params.cores]
    --output            name of the result folder [default: $params.output]
    --assemblerLong     long-read assembly tool used [spades, default: $params.assemblerLong]

    ${c_yellow}Parameters:${c_reset}
    --gsize             estimated genome size [default: $params.gsize]

    ${c_dim}Nextflow options:
    -with-report rep.html    cpu / ram usage (may cause errors)
    -with-dag chart.html     generates a flowchart for the process tree
    -with-timeline time.html timeline (may cause errors)

    Profile:
    -profile                 standard, googlegenomics [default: standard] ${c_reset}
    """.stripIndent()
}