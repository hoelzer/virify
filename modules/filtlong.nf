process filtlong {
    label 'filtlong'
  input:
    tuple val(name), file(reads) 
  output:
	  tuple val(name), file("${name}_filtered_reduced.fastq.gz") 
  script:
    """
    filtlong --target_bases 4000000000 ${reads} --length_weight 5 | gzip > ${name}_filtered_reduced.fastq.gz
    """
}

/* Comments:
Does not include a "filter by length" because i added the --length_weight 10 flag.
So while removing reads to get the --target bases it favors long reads over shor ones

Input is .fastq or .fastq.gz 
*/