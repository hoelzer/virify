process prodigal {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "*.faa"
      label 'prodigal'

    input:
      tuple val(name), file(fasta) 
    
    output:
      tuple val(name), stdout, file("*.faa")
    
    shell:
    """
    BN=\$(basename ${fasta} .fna)
    prodigal -p "meta" -a \${BN}_prodigal.faa -i ${fasta} > /dev/null
    printf "\$BN"
    """
}
