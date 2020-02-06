process krona {
    publishDir "${params.output}/${name}/${params.dir}", mode: 'copy', pattern: "${set_name}.krona.html"
    label 'krona'  
  input:
    tuple val(name), val(set_name), file(krona_file)
  output:
    file("${set_name}.krona.html")
  script:
    """
    ktImportText -o ${set_name}.krona.html ${krona_file}
    """
  }

/* Comments:
*/