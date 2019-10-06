process spades {
    label 'spades'  
    publishDir "${params.output}/${name}/${params.assemblydir}", mode: 'copy', pattern: "${name}.fasta"
  input:
    set val(name), file(r1), file(r2)
  output:
    set val(name), file(r1), file(r2), file("${name}.fasta")
  script:
    """
    metaspades.py -1 ${r1} -2 ${r2} -t ${task.cpus} -m ${params.memory} -o assembly
    mv assembly/scaffolds.fasta ${name}.fasta
    """
  }

/* Comments:
*/