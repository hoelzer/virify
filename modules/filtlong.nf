process filtlong {
    label 'filtlong'
  input:
    tuple val(name), file(reads) 
  output:
	  tuple val(name), file("${name}_minlength_reduced.fastq.gz") 
  script:
    """
    filtlong --min_length 100 ${reads} | gzip > ${name}_minlength_reduced.fastq.gz
    """
}

/* Comments:
Input is .fastq or .fastq.gz 
*/