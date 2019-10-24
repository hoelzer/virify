process virsorter {
      publishDir "${params.output}/${name}/${params.dir}/", mode: 'copy', pattern: "*"
      label 'virsorter'

    input:
      tuple val(name), file(fasta) 
      file(database) 
    
    output:
      tuple val(name), file("*")
    
    script:
      """
      wrapper_phage_contigs_sorter_iPlant.pl -f ${fasta} -db 1 --wdir virsorter --ncpu ${task.cpus} --data-dir ${database}
      """
}