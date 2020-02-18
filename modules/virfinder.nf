process virfinder {
      errorStrategy { task.exitStatus = 1 ? 'ignore' :  'terminate' }
      publishDir "${params.output}/${name}/${params.dir}/virfinder", mode: 'copy', pattern: "${name}.txt"
      label 'virfinder'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}.txt")
    script:
      """
      #Rscript /usr/local/bin/run_virfinder.Rscript ${fasta} ${name}.txt
      run_virfinder_non_parallel.Rscript ${fasta} ${name}.txt
      """
}