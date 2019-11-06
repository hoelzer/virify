process canu {
    label 'canu'  
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.canu.fasta"
  input:
    tuple val(name), file(fastq), file(gsize)
  output:
    tuple val(name), file("${name}.canu.fasta")
  script:
    """
    GSIZE=\$(cat ${gsize})
    canu -p ${name} -d canu_results maxThreads=${task.cpus} maxMemory="${task.memory}" genomeSize=\${GSIZE} -correct corOutCoverage=400 stopOnLowCoverage=0 -nanopore-raw ${fastq}
    mv canu_results/${name}.contigs.fasta ${name}.canu.fasta
    """
  }

/* Comments:
  -- WARNING:
  -- WARNING:  Failed to run gnuplot using command 'gnuplot'.
  -- WARNING:  Plots will be disabled.
  -- WARNING:
*/