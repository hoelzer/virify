process hmm_postprocessing {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${set_name}_modified.tbl"
      label 'hmm_postprocessing'

    input:
      tuple val(name), val(set_name), file(hmmer_tbl), file(faa) 
    
    output:
      tuple val(name), val(set_name), file("${set_name}_modified.tbl"), file(faa)
    
    shell:
    """
    #cat *.tbl > all.tbl
    sed '/^#/d; s/ \\+/\\t/g' ${hmmer_tbl} > ${set_name}_modified.tbl

    echo "target name\ttarget accession\ttlen\tquery name\tquery accession\tqlen\tfull sequence E-value\tfull sequence score\tfull sequence bias\t#\tof\tc-Evalue\ti-Evalue\tdomain score\tdomain bias\thmm coord from\thmm coord to\tali coord from\tali coord to\tenv coord from\tenv coord to\tacc\tdescription of target" > tmp
    cat ${set_name}_modified.tbl >> tmp
    mv tmp ${set_name}_modified.tbl
    """
}

/*
input: File_hmmer_ViPhOG.tbl
output: File_hmmer_ViPhOG_modified.tbl
*/
