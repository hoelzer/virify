process hmm_postprocessing {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}_modified.faa"
      label 'hmm_postprocessing'

    input:
      tuple val(name), file(hmm) 
    
    output:
      tuple val(name), file("${name}_modified.faa")
    
    shell:
    """
    sed '/^#/d; s/ \\+/\\t/g' ${hmm} > ${name}_modified.faa

    echo "target name\\ttarget accession\\ttlen\\tquery name\\tquery accession\\tqlen\\tfull sequence E-value\\tfull sequence score\\tfull sequence bias\\t#\\tof\\tc-Evalue\\ti-Evalue\\tdomain score\\tdomain bias\\thmm coord from\\thmm coord to\\tali coord from\\tali coord to\\tenv coord from\\tenv coord to\\tacc\\tdescription of target" > tmp
    cat ${name}_modified.faa >> tmp
    mv tmp ${name}_modified.faa
    """
}
