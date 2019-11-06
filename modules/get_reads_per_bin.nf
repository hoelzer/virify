process get_reads_per_bin {
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.BIN-*.fastq"
    label 'ucsc'

    input:
      tuple val(name), file(hdbscan_bins), file(filtered_bins), file(fasta) 
    
    output:
      tuple val(name), file("${name}.BIN-*.fastq"), file("${name}.BIN-*.gsize")
      tuple val(name), file("${name}.BIN-*.fasta"), file("${name}.BIN-*.gsize")
    script:
    """
    for BIN_ID in \$(awk '{if(\$2=="True"){print \$1}}' ${filtered_bins}); do
      BIN_ID_NAME="BIN-"\${BIN_ID}
      awk -v ID="\$BIN_ID" '{if(\$1==ID){print \$3}}' ${filtered_bins} > ${name}.\${BIN_ID_NAME}.gsize
      awk -v ID="\$BIN_ID" '{if(\$5==ID){print \$1}}' ${hdbscan_bins} > \${BIN_ID_NAME}.reads
      faSomeRecords ${fasta} \${BIN_ID_NAME}.reads ${name}.\${BIN_ID_NAME}.fasta
      faToFastq ${name}.\${BIN_ID_NAME}.fasta ${name}.\${BIN_ID_NAME}.fastq
    done
    """
}

/*
*/