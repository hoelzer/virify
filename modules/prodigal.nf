process prodigal {
      publishDir "${params.output}/${name}/${params.dir}", mode: 'copy', pattern: "*.faa"
      label 'prodigal'

    input:
      tuple val(name), file(fasta) 
    
    output:
      tuple val(name), env(BN), file("*.faa")
    
    shell:
    """
    BN=\$(basename ${fasta} .fna)
    prodigal -p "meta" -a \${BN}_prodigal.faa -i ${fasta}
    """
}
