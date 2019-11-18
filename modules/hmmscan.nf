process hmmscan {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}_hmmscan.tbl"
      label 'hmmscan'

    input:
      tuple val(name), file(faa) 
    
    output:
      tuple val(name), file("${name}_hmmscan.tbl")
    
    shell:
    """
      hmmscan -E "0.001" --domtblout ${name}_hmmscan.tbl /vpHMM_database/vpHMM_database --noali
    """
}
