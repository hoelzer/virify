process virfinder {
      publishDir "${params.output}/${name}/${params.virusdir}/virfinder", mode: 'copy', pattern: "${name}.txt"
      label 'virfinder'
    input:
      set val(name), file(fasta) 
    output:
      set val(name), file("${name}.txt")
    script:
      """
      virfinderGO.R ${fasta} > ${name}.txt
      """
}