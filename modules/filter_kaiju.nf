process filter_kaiju {
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.out.*cellular"
    label 'ruby'

    input:
      tuple val(name), file(kaiju_out) 

    output:
      tuple val(name), file("${name}.out.cellular")
      tuple val(name), file("${name}.out.noncellular")
    
    script:
      """
      #!/usr/bin/env ruby

      `wget https://www.rna.uni-jena.de/supplements/viruses.taxids`
      
      virus_ids = []
      viruses = File.open('viruses.taxids','r')
      viruses.each do |l|
        virus_ids.push(l.chomp)
      end
      viruses.close

      out_unclassified= File.open("${name}.out.unclassified",'w')
      out_viruses = File.open("${name}.out.viruses",'w')
      out_cellular = File.open("${name}.out.cellular",'w')

      hits = File.open('${kaiju_out}','r')
      hits.each do |l|
        s = l.split("\\t")
        read_id = s[1].chomp
        tax_id = s[2].chomp

        if s[0].chomp == "U"
          out_unclassified << read_id << "\\n"
        else
          if virus_ids.include?(tax_id)
            out_viruses << read_id << "\\n"
          else
            out_cellular << read_id << "\\n"
          end
        end
      end
      hits.close
      out_viruses.close
      out_cellular.close
      out_unclassified.close

      `cat ${name}.out.unclassified ${name}.out.viruses > ${name}.out.noncellular`
      `rm ${name}.out.unclassified`
      `rm ${name}.out.viruses`
      """
}

/*
*/

