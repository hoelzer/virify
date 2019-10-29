process kmerfreq {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: ""
      label 'marine_phage_paper_scripts'

    input:
      tuple val(name), file(kaiju_file_unclassified), file(krona_file)
      tuple val(name), file(fastq) 

    output:
      tuple val(name), file()

    script:
      """
      # collect all reads that are unclassified
      

      # calculate kmer frequencies
      kmer_freq.py ${}
      """
}