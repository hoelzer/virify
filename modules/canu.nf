process canu {
    label 'canu'  
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: ""
  input:
    tuple val(name), file(read)
  output:
    tuple val(name), file(read), file("${name}.fasta")
  script:
    """
    """
  }

/* Comments:
*/