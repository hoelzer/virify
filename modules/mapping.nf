process mapping {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}_mapping_results"
      label 'mapping'

    input:
      tuple val(name), file(tab)
    
    output:
      tuple val(name), file("${name}_mapping_results")
    
    shell:
    """
    Rscript /Make_viral_contig_map.R -o ${name}_mapping_results -t ${tab}
    """
}

/*
*/