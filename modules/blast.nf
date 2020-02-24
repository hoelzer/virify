process blast {
      publishDir "${params.output}/${assembly_name}/${params.blastdir}/", mode: 'copy', pattern: "*.blast"
      label 'blast'

    input:
      tuple val(assembly_name), val(confidence_set_name), file(fasta) 
      file(db)
    
    output:
      tuple val(assembly_name), val(confidence_set_name), file("${confidence_set_name}.blast"), file("${confidence_set_name}.filtered.blast")
    
    shell:
    """
      HEADER_BLAST="qseqid\\tsseqid\\tpident\\tlength\\tmismatch\\tgapopen\\tqstart\\tqend\\tqlen\\tsstart\\tsend\\tevalue\\tbitscore\\tslen"
      HEADER_IMGVR="UViG\\tTAXON_OID\\tScaffold_ID\\tVIRAL_CLUSTERS\\tEcosystem\\tEcosystem_Category\\tEcosystem_Type\\tEcosystem_Subtype\\tHabitat\\tperc_VPF\\tHost	Host_detection\\tHost_domain\\tEstimated_completeness\\tQuality\\tPredicted_genome_size\\tRationale_for_predicted_genome_size\\tPOGs_ORDER\\tPOGs_FAMILY\\tPOGs_SUBFAMILY\\tPOGs_GENUS\\tputative_retrovirus"
      printf "\$HEADER_BLAST\\n" > ${confidence_set_name}.blast
      printf "\$HEADER_BLAST\\n" > ${confidence_set_name}.filtered.blast

      blastn -task blastn -num_threads ${task.cpus} -query ${fasta} -db ${db}/IMG_VR_2018-07-01_4/IMGVR_all_nucleotides.fna -evalue 1e-10 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend qlen sstart send evalue bitscore slen" >> ${confidence_set_name}.blast
      awk '{if(\$4>0.8*\$9){print \$0}}' ${confidence_set_name}.blast >> ${confidence_set_name}.filtered.blast
    """
}
