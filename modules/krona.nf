process krona {
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.out.html"
    label 'krona'  
  input:
    tuple val(name), file(fastqc)
  output:
    file("${name}.out.html")
  script:
    """
    ktImportText -o ${name}.out.html ${name}.out.krona
    """
  }

/* Comments:
*/