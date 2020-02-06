process hmm_postprocessing {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}_modified.tbl"
      label 'hmm_postprocessing'

    input:
      tuple val(name), file(hmm) 
    
    output:
      tuple val(name), file("${name}_modified.tbl")
    
    shell:
    """
    sed '/^#/d; s/ \\+/\\t/g' ${hmm} > ${name}_modified.tbl

    echo "target name\\ttarget accession\\ttlen\\tquery name\\tquery accession\\tqlen\\tfull sequence E-value\\tfull sequence score\\tfull sequence bias\\t#\\tof\\tc-Evalue\\ti-Evalue\\tdomain score\\tdomain bias\\thmm coord from\\thmm coord to\\tali coord from\\tali coord to\\tenv coord from\\tenv coord to\\tacc\\tdescription of target" > tmp
    cat ${name}_modified.faa >> tmp
    mv tmp ${name}_modified.faa
    """
}

/*
input: File_hmmer_ViPhOG.tbl
output: File_hmmer_ViPhOG_modified.tbl
*/
