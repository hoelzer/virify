process fastqc {
    label 'fastqc'  
  input:
    set val(name), file(reads)
  output:
    set val(name), file("fastqc/${name}*fastqc*")
  script:
    """
    mkdir fastqc
    fastqc -t ${task.cpus} -o fastqc *.fastq.gz
    """
  }

/* Comments:
*/