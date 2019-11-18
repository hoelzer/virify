process prodigal {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}_prodigal.faa"
      label 'prodigal'

    input:
      tuple val(name), file(fasta) 
    
    output:
      tuple val(name), file("${name}_prodigal.faa")
    
    shell:
    """
    prodigal -p "meta" -a ${name}_prodigal.faa -i ${fasta}
    """
}
