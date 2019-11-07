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

      out_viruses = File.open("${name}.out.viruses",'w')
      out_classified = File.open("${name}.out.classified",'w')

      hits = File.open('${kaiju_out}','r')
      hits.each do |l|
        s = l.split("\t")
        next if s[0].chomp == "U"
        read_id = s[1].chomp
        tax_id = s[2].chomp
        if virus_ids.include?(tax_id)
          out_viruses << read_id << "\n"
        else
          out_classified << read_id << "\n"
        end
      end
      hits.close
      out_viruses.close
      out_classified.close
      '''
}

/*
awk '{if($1=="U"){print $2}}' !{name}.out > !{name}.out.unclassified
*/

