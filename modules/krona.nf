process krona {
    publishDir "${params.output}/${name}/${params.plotdir}", mode: 'copy', pattern: "*.krona.html"
    label 'krona'  
  input:
    tuple val(name), val(set_name), file(krona_file)
  output:
    file("*.krona.html")
  script:
    """
    if [[ ${set_name} == "all" ]]; then
      ktImportText -o ${name}.krona.html ${krona_file}
    else
      ktImportText -o ${set_name}.krona.html ${krona_file}
    fi
    """
  }

/* Comments:
*/