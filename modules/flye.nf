process flye {
    label 'flye'  
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.flye.fasta"
  input:
    tuple val(name), file(fastq), file(gsize)
  output:
    tuple val(name), file(read), file("${name}.flye.fasta")
    tuple val(name), file("${name}.flye.gfa") 
  script:
    """
    GSIZE=\$(cat ${gsize})
    flye --plasmids -g \${GSIZE} --meta -t ${task.cpus} --nano-raw ${fastq} -o assembly
    mv assembly/assembly.fasta ${name}.fly.fasta
    mv assembly/assembly_graph.gfa ${name}.fly.gfa
    """
  }

/* Comments:
This process needs the ${params.gsize} added to it.
e.g. 20   
equals 20 Megabases
Current "state of the art" is --meta and --plasmids for best assembly results
*/