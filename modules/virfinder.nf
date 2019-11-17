process virfinder {
      publishDir "${params.output}/${name}/${params.dir}/virfinder", mode: 'copy', pattern: "${name}.txt"
      label 'virfinder'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}.txt")
    script:
      """
      Rscript run_virfinder.Rscript ${fasta} ${name}.txt
      """
}