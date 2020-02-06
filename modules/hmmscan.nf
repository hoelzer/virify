process hmmscan {
      publishDir "${params.output}/${assembly_name}/", mode: 'copy', pattern: "${contig_set_name}_hmmscan.tbl"
      label 'hmmscan'

    input:
      tuple val(assembly_name), val(contig_set_name), file(faa) 
      file(db)
    
    output:
      tuple val(assembly_name), file("${contig_set_name}_hmmscan.tbl")
    
    shell:
    """
      hmmscan --cpu ${task.cpus} --noali -E "0.001" --domtblout ${contig_set_name}_hmmscan.tbl ${db}/vpHMM_database ${faa}
    """
}
