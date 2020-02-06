process hmmscan {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}_hmmscan.tbl"
      label 'hmmscan'

    input:
      tuple val(name), file(faa) 
      file(db)
    
    output:
      tuple val(name), file("${name}_hmmscan.tbl")
    
    shell:
    """
      hmmscan  --noali -E "0.001" --domtblout ${name}_hmmscan.tbl ${db}/vpHMM_database ${faa}
    """
}
