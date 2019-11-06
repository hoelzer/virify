process get_reads_per_bin {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${hdbscan_name}.bin-*.fasta"
      label 'ucsc'

    input:
      tuple val(hdbscan_name), file(hdbscan_bins)
      tuple val(bin_rl_name), file(filtered_bins) 
      tuple val(fasta_filtered_name), file(fasta) 
    
    output:
      tuple val(name), file("${hdbscan_name}.bin-*.fasta")
      tuple val(name), file("${hdbscan_name}.bin-*.fastq")
    
    script:
    '''
    # for each True bin collect the corresponding read IDs
    for BIN_ID in $(awk '{if($2=="True"){print $1}}' !{filtered_bins}); do
      awk -v ID="$BIN_ID" '{if($5==ID){print $1}}' !{hdbscan_bins} > $BIN_ID.reads
      faSomeRecords !{fasta} $BIN_ID.reads !{hdbscan_name}.bin-${BIN_ID}.fasta
      faToFastq !{hdbscan_name}.bin-${BIN_ID}.fasta !{hdbscan_name}.bin-${BIN_ID}.fastq
    done
    '''
}