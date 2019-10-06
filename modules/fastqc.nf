process fastqc {
    label 'fastqc'  
  input:
    set val(name), file(r1), file(r2)
  output:
    set val(name), file("${name}.R1_fastqc.html"), file("${name}.R2_fastqc.html"), file("${name}.R1_fastqc.zip"), file("${name}.R2_fastqc.zip")
  script:
    """
    mkdir fastqc
    fastqc -t ${task.cpus} -o fastqc *.fastq.gz
    """
  }

/* Comments:
*/