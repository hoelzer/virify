process shasta {
    label 'shasta'  
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.gfa"
 
  input:
    tuple val(name), file(read)

  output:
    tuple val(name), file("${read.baseName}"), file("${name}.fasta")
    tuple val(name), file("${name}.gfa") 

  script:
    """
    gunzip -f ${read}      
    shasta --threads ${task.cpus} --input ${read.baseName}
    mv ShastaRun/Assembly.fasta ${name}.fasta
    mv ShastaRun/Assembly.gfa ${name}.gfa
    """
  }

/* Comments:
shasta can not work with N bases! And also not with zipped files!
--Reads.minReadLength 10000 is default
--assemblyDirectory to change out dir
*/


