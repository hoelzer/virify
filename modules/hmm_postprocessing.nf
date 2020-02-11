process hmm_postprocessing {
      publishDir "${params.output}/${name}/${params.dir}/", mode: 'copy', pattern: "${set_name}_modified.tbl"
      label 'python3'

    input:
      tuple val(name), val(set_name), file(hmmer_tbl), file(faa) 
    
    output:
      tuple val(name), val(set_name), file("${set_name}_modified.tbl"), file(faa)
    
    shell:
    """
    hmmscan_format_table.py -t ${hmmer_tbl} -o ${set_name}_modified.tbl
    """
}

/*
input: File_hmmer_ViPhOG.tbl
output: File_hmmer_ViPhOG_modified.tbl
*/
