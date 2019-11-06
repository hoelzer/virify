process get_reads_per_bin {
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: "*.reads" //${name}.bin-*.fastq"
    label 'ucsc'

    input:
      tuple val(name), file(hdbscan_bins), file(filtered_bins), file(fasta) 
    
    output:
    file("*.reads")
      //tuple val(name), file("${name}.bin-*.fasta")
      //tuple val(name), file("${name}.bin-*.fastq")
    script:
    """
    for BIN_ID in \$(awk '{if(\$2=="True"){print \$1}}' ${filtered_bins}); do
      BIN_ID_NAME="BIN-"\${BIN_ID}
      echo \${BIN_ID} > foo.reads
    done
    """
}

/*
I add 1 to each bin number because for some reason the bins start with -1

      awk -v ID="\$BIN_ID" '{if(\$5==ID){print \$1}}' ${hdbscan_bins} > \${BIN_ID_NAME}.reads
      faSomeRecords ${fasta} \${BIN_ID_NAME}.reads ${name}.bin-\${BIN_ID_NAME}.fasta
      faToFastq ${name}.bin-\${BIN_ID_NAME}.fasta ${name}.bin-\${BIN_ID_NAME}.fastq

*/