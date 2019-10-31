process kmerfreq {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.kmers"
      label 'marine_phage_paper_scripts'

    input:
      tuple val(name), file(filtered_fastq) 

    output:
      tuple val(name), file("${name}.kmers")

    script:
      """
      kmer_freq.py -t ${task.cpus} ${filtered_fastq} > ${name}.kmers
      """
}