process phanotate {
      publishDir "${params.output}/${name}/${params.dir}", mode: 'copy', pattern: "*.faa"
      label 'phanotate'

    input:
      tuple val(name), file(fasta) 
    
    output:
      tuple val(name), stdout, file("*.faa")
    
    shell:
    """
    BN=\$(basename ${fasta} .fna)
    phanotate.py -f fasta -o \${BN}_phanotate.fna ${fasta} > /dev/null
    transeq -sequence \${BN}_phanotate.fna -outseq \${BN}_phanotate.faa > /dev/null
    printf "\$BN"
    """
}
