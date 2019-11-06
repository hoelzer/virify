process get_reads_per_bin {
      //publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.bin-*.fasta"
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "foo"
      label 'ucsc'

    input:
      tuple val(name), file(hdbscan_bins), file(filtered_bins), file(fasta) 
    
    output:
      file('foo')
    //  tuple val(name), file("${name}.bin-*.fasta")
    //  tuple val(name), file("${name}.bin-*.fastq")
    script:
    """
    echo ${filtered_bins} > foo
    """
    /*shell:
    '''
    for BIN_ID in $(awk '{if($2=="True"){print $1}}' !{filtered_bins}); do
      echo $BIN_ID
      #awk -v ID="$BIN_ID" '{if($5==ID){print $1}}' !{bins} > $BIN_ID.reads
      #faSomeRecords !{fasta} $BIN_ID.reads !{name}.bin-${BIN_ID}.fasta
      #faToFastq !{name}.bin-${BIN_ID}.fasta !{name}.bin-${BIN_ID}.fastq
    done
    '''
    */
}


/*

    #for BIN_ID in $(awk '{if($2=="True"){print $1}}' !{filtered_bins}); do
    #  echo $BIN_ID > foo
    #done


*/