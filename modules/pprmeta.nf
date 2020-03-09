process pprmeta {
      label 'pprmeta'
      publishDir "${params.output}/${name}/${params.virusdir}/pprmeta", mode: 'copy', pattern: "${name}_pprmeta.csv"

    input:
      tuple val(name), file(fasta), val(contig_number)
    
    when: 
      contig_number.toInteger() > 0 

    output:
      tuple val(name), file("${name}_pprmeta.csv")

    script:
      """
      git clone https://github.com/Stormrider935/PPR-Meta.git
      cp PPR-Meta/* .  
      ./PPR_Meta ${fasta} ${name}_pprmeta.csv
      """
}

 // .fasta is not working here. has to be .fa
 // need to implement this so its fixed 