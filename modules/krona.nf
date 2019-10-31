process krona {
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.kaiju.html"
    label 'krona'  
  input:
    tuple val(name), file(krona_file)
  output:
    file("${name}.kaiju.html")
  script:
    """
    ktImportText -o ${name}.kaiju.html ${krona_file}
    """
  }

/* Comments:
*/