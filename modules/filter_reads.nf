process filter_reads {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.unclassified.fastq"
      label 'ucsc'

    input:
      tuple val(name), file(kaiju_unclassified)
      tuple val(fastq_filtered_name), file(fastq) 
    
    output:
      tuple val(name), file("${name}.unclassified.fastq")
      tuple val(name), file("${name}.unclassified.fasta")
    
    shell:
    """
    sed '/^@/!d;s//>/;N' ${fastq} > ${name}.fasta
    faSomeRecords ${name}.fasta ${kaiju_unclassified} ${name}.unclassified.fasta
    faToFastq ${name}.unclassified.fasta ${name}.unclassified.fastq
    rm -f ${name}.fasta
    """
}
