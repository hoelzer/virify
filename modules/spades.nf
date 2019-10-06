process spades {
    label 'spades'  
    publishDir "${params.output}/${name}/${params.assemblydir}", mode: 'copy', pattern: "${name}.fasta"
  input:
    set val(name), file(reads)
  output:
    set val(name), file(reads), file("${name}.fasta")
  script:
    """
    metaspades.py -1 ${reads[0]} -2 ${reads[1]} -t ${task.cpus} -m ${params.memory} -o assembly
    mv assembly/contigs.fasta ${name}.fasta
    """
  }

/* Comments:
*/