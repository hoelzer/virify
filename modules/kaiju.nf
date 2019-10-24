process kaiju {
      publishDir "${params.output}/${name}/${params.virusdir}/", mode: 'copy', pattern: "*"
      label 'kaiju'

    input:
      tuple val(name), file(fastq) 
      file(database) 
    
    output:
      tuple val(name), file("${name}.out"), file("${name}.out.krona")
    
    script:
      if (params.illumina) {
      """
      kaiju -z ${task.cpus} -t ${database}/nodes.dmp -f ${database}/kaiju_db_*.fmi -i ${fastq[0]} -j ${fastq[1]} -o ${name}.out
      """
      } 
      if (params.fasta) {
      """
      kaiju -z ${task.cpus} -t ${database}/nodes.dmp -f ${database}/kaiju_db_*.fmi -i ${fastq} -o ${name}.out
      """
      }
      if (params.nano) {
      """
      kaiju -a greedy -e 5 -z ${task.cpus} -t ${database}/nodes.dmp -f ${database}/kaiju_db_*.fmi -i ${fastq} -o ${name}.out
      """
      }
      """
      kaiju2krona -t ${database}/nodes.dmp -n ${database}/names.dmp -i ${name}.out -o ${name}.out.krona
      """
}