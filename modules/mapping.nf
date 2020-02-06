process mapping {
      publishDir "${params.output}/${name}/${params.dir}/", mode: 'copy', pattern: "${set_name}_mapping_results"
      label 'mapping'

    input:
      tuple val(name), val(set_name), file(tab)
    
    output:
      tuple val(name), file("${set_name}_mapping_results")
    
    shell:
    """
    Rscript /Make_viral_contig_map.R -o ${set_name}_mapping_results -t ${tab}
    """
}

/*
*/