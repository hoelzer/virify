process filtlong {
    label 'filtlong'
  input:
    tuple val(name), file(reads) 
  output:
	  tuple val(name), file("${name}_minlength_reduced.fastq") 
  script:
    """
    filtlong --min_length 100 ${reads} > ${name}_minlength_reduced.fastq
    """
}

/* Comments:
Input is .fastq or .fastq.gz 
*/