process add_virus_ids {
      //publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.unclassified.viruses"
      label 'ucsc'

    input:
      tuple val(name), file(kaiju_out), file(kaiju_unclassified) 

    //output:
      //tuple val(name), file("${name}.unclassified.viruses")
    
    shell:
      '''
      wget https://www.rna.uni-jena.de/supplements/viruses.taxids
      
      
      
      '''
}

/*
awk '{if($1=="U"){print $2}}' !{name}.out > !{name}.out.unclassified
*/

