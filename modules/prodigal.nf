process prodigal {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "*.faa"
      label 'prodigal'

    input:
      tuple val(name), file(fasta) 
    
    output:
      tuple stdout, file("*.faa")
    
    shell:
    """
    BN=\$(basename ${fasta} .fna)
    prodigal -p "meta" -a \${BN}_prodigal.faa -i ${fasta}
    reset
    printf \$BN
    """
}



//[PRJNA530103_raw_assembly, /hps/nobackup2/production/metagenomics/mhoelzer/nextflow-work-mhoelzer/df/522290fdefe55952cdd3438a7f1e46/High_confidence_putative_viral_contigs.fna]
