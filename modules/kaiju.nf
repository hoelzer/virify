process kaiju {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.out.unclassified"
      label 'kaiju'

    input:
      tuple val(name), file(fastq) 
      file(database) 
    
    output:
      tuple val(name), file("${name}.out")
      tuple val(name), file("${name}.out.unclassified")
      tuple val(name), file("${name}.out.krona")
    
    shell:
      if (params.illumina) {
      '''
      kaiju -z !{task.cpus} -t !{database}/nodes.dmp -f !{database}/!{database}/kaiju_db_!{database}.fmi -i !{fastq[0]} -j !{fastq[1]} -o !{name}.out
      kaiju2krona -t !{database}/nodes.dmp -n !{database}/names.dmp -i !{name}.out -o !{name}.out.krona
      awk '{if($1=="U"){print $2}}' !{name}.out > !{name}.out.unclassified
      '''
      } 
      if (params.fasta) {
      '''
      kaiju -z !{task.cpus} -t !{database}/nodes.dmp -f !{database}/!{database}/kaiju_db_!{database}.fmi -i !{fastq} -o !{name}.out
      kaiju2krona -t !{database}/nodes.dmp -n !{database}/names.dmp -i !{name}.out -o !{name}.out.krona
      awk '{if($1=="U"){print $2}}' !{name}.out > !{name}.out.unclassified
      '''
      }
      if (params.nano) {
      '''
      kaiju -a greedy -e 5 -z !{task.cpus} -t !{database}/nodes.dmp -f !{database}/!{database}/kaiju_db_!{database}.fmi -i !{fastq} -o !{name}.out
      kaiju2krona -t !{database}/nodes.dmp -n !{database}/names.dmp -i !{name}.out -o !{name}.out.krona
      awk '{if($1=="U"){print $2}}' !{name}.out > !{name}.out.unclassified
      '''
      }
}

/*
todo: also get lists for the Classified reads!
todo: include viruses.taxids
*/