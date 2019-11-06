process canu {
    label 'canu'  
    publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.BIN*.canu.fasta"
  input:
    tuple val(name), file(fastq), file(gsize)
  output:
    tuple val(name), file("${name}.BIN*.canu.fasta")
  script:
    """
    GSIZE=\$(cat ${gsize})
    BIN=\$(echo "${gsize}" | sed 's/${name}.//g' | sed 's/.gsize//g')
    canu -p ${name} -d canu_results maxThreads=${task.cpus} maxMemory=16 genomeSize=\${GSIZE} -correct corOutCoverage=400 stopOnLowCoverage=0 -nanopore-raw ${fastq}
    mv canu_results/${name}.contigs.fasta ${name}.\${BIN}.canu.fasta
    """
  }

/* Comments:
  -- WARNING:
  -- WARNING:  Failed to run gnuplot using command 'gnuplot'.
  -- WARNING:  Plots will be disabled.
  -- WARNING:
*/