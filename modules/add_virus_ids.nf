process add_virus_ids {
      //publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.unclassified.viruses"
      label 'ruby'

    input:
      tuple val(name), file(kaiju_out), file(kaiju_unclassified) 

    //output:
      //tuple val(name), file("${name}.unclassified.viruses")
    
    shell:
      '''
      #!/usr/bin/env ruby

      `wget https://www.rna.uni-jena.de/supplements/viruses.taxids`
      
      virus_ids = []
      viruses = File.open('viruses.taxids','r')
      viruses.each do |l|
        virus_ids.push(l.chomp)
      end
      viruses.close

      
      
      
      '''
}

/*
awk '{if($1=="U"){print $2}}' !{name}.out > !{name}.out.unclassified
*/

