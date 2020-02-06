process hmmscan {
      publishDir "${params.output}/${name}/${params.dir}/${params.db}", mode: 'copy', pattern: "${set_name}_${params.db}_hmmscan.tbl"
      label 'hmmscan'

    input:
      tuple val(name), val(set_name), file(faa) 
      file(db)
    
    output:
      tuple val(name), val(set_name), file("${set_name}_${params.db}_hmmscan.tbl"), file(faa)
    
    shell:
    """
      hmmscan --cpu ${task.cpus} --noali -E "0.001" --domtblout ${set_name}_${params.db}_hmmscan.tbl ${db}/${db}.hmm ${faa}
    """
}

process hmmscan_cut_ga {
      publishDir "${params.output}/${name}/${params.dir}/${params.db}_cut_ga", mode: 'copy', pattern: "${set_name}_${params.db}_hmmscan.tbl"
      label 'hmmscan'

    input:
      tuple val(name), val(set_name), file(faa) 
      file(db)
    
    output:
      tuple val(name), val(set_name), file("${set_name}_${params.db}_hmmscan.tbl"), file(faa)
    
    shell:
    """
      hmmscan --cpu ${task.cpus} --noali --cut_ga --domtblout ${set_name}_${params.db}_hmmscan.tbl ${db}/${db}.hmm ${faa}
      # TODO filter evalue afterward
    """
}
