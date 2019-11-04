process filter_reads {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.unclassified.fastq"
      label 'ucsc'

    input:
      tuple val(name), file(kaiju_unclassified)
      tuple val(fastq_filtered_name), file(fastq) 
    
    output:
      tuple val(name), file("${name}.unclassified.fastq")
    
    shell:
    """
    gunzip -f ${fastq}
    sed '/^@/!d;s//>/;N' ${fastq_filtered_name}.fastq > ${name}.fasta
    faSomeRecords ${name}.fasta ${kaiju_unclassified} ${name}.unclassified.fasta
    faToFastq ${name}.unclassified.fasta ${name}.unclassified.fastq
    rm -f ${fastq_filtered_name}.fastq ${name}.fasta ${name}.unclassified.fasta
    """
}

/*
Super slow, re-code

old code:
    #!/usr/bin/env ruby

    out = File.open('${name}.unclassified.fastq', 'w')

    unclassified = File.open('${kaiju_unclassified}', 'r')
    list = []
    unclassified.each do |l|
      list.push("@#{l.chomp}")
    end
    unclassified.close

    line = 1
    write_next = false
    File.open('${fastq}','r').each do |l|
      if write_next
        out << l
        write_next = false if line == 4 
      end
      if line == 1
        id = l.split(' ')[0]
        if list.include?(id)
          out << l
          write_next = true
        end
      end
      line += 1
      line = 1 if line == 5
    end

    out.close

*/