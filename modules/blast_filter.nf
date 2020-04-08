process blast_filter {
      publishDir "${params.output}/${assembly_name}/${params.blastdir}/", mode: 'copy', pattern: "*.meta"
      publishDir "${params.output}/${assembly_name}/${params.finaldir}/blast/", mode: 'copy', pattern: "*.meta"
      label 'ruby'

      errorStrategy 'retry'
      maxRetries 1

    input:
      tuple val(assembly_name), val(confidence_set_name), file(blast), file(blast_filtered)
      file(db)
    
    output:
      tuple val(assembly_name), val(confidence_set_name), file("*.meta")
    
    shell:
    if (task.attempt.toString() == '1')
    """
      blast_filter.rb ${blast_filtered} IMG_VR_2018-07-01_4/IMGVR_all_Sequence_information.tsv
    """
    else if (task.attempt.toString() == '2')
    """
      blast_filter.rb ${blast_filtered} ${db}/IMG_VR_2018-07-01_4/IMGVR_all_Sequence_information.tsv
    """
}
