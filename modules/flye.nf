process flye {
    label 'flye'  
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.gfa"
  input:
    tuple val(name), file(read)
  output:
    tuple val(name), file(read), file("${name}.fasta")
    tuple val(name), file("${name}.gfa") 
  script:
    """
    flye --plasmids -g ${params.gsize}m --meta -t ${task.cpus} --nano-raw ${read} -o assembly
    mv assembly/assembly.fasta ${name}.fasta
    mv assembly/assembly_graph.gfa ${name}.gfa
    """
  }

/* Comments:
This process needs the ${params.gsize} added to it.
e.g. 20   
equals 20 Megabases
Current "state of the art" is --meta and --plasmids for best assembly results
*/