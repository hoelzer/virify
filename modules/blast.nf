process blast {
      publishDir "${params.output}/${assembly_name}/${params.blastdir}/", mode: 'copy', pattern: "*.blast"
      label 'blast'

    input:
      tuple val(assembly_name), val(confidence_set_name), file(fasta) 
      file(db)
    
    output:
      tuple val(assembly_name), val(confidence_set_name), file("*.blast")
    
    shell:
    """
      HEADER_BLAST="qseqid\\tsseqid\\tpident\\tlength\\tmismatch\\tgapopen\\tqstart\\tqend\\tqlen\\tsstart\\tsend\\tevalue\\tbitscore\\tslen"
      HEADER_IMGVR="UViG\\tTAXON_OID\\tScaffold_ID\\tVIRAL_CLUSTERS\\tEcosystem\\tEcosystem_Category\\tEcosystem_Type\\tEcosystem_Subtype\\tHabitat\\tperc_VPF\\tHost	Host_detection\\tHost_domain\\tEstimated_completeness\\tQuality\\tPredicted_genome_size\\tRationale_for_predicted_genome_size\\tPOGs_ORDER\\tPOGs_FAMILY\\tPOGs_SUBFAMILY\\tPOGs_GENUS\\tputative_retrovirus"
      echo \$HEADER_BLAST > ${confidence_set_name}.blast
      echo \$HEADER_BLAST > ${confidence_set_name}.filtered.blast
      echo "\$HEADER_BLAST\\t\$HEADER_IMGVR" > ${confidence_set_name}.filtered.meta.blast

      blastn -task blastn -num_threads ${task.cpus} -query ${fasta} -db ${db}/IMG_VR_2018-07-01_4/IMGVR_all_nucleotides.fna -evalue 1e-10 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend qlen sstart send evalue bitscore slen" >> ${confidence_set_name}.blast
      awk '{if(\$4>0.8*\$9){print \$0}}' ${confidence_set_name}.blast >> ${confidence_set_name}.filtered.blast

      # add meta data for the filtered hits
      META=${db}/IMG_VR_2018-07-01_4/IMGVR_all_Sequence_information.tsv
      for HIT_LINE in \$(grep -v qseqid ${confidence_set_name}.filtered.blast); do
        HIT_ID=\$(awk '{print \$2}' \$HIT_LINE | sed 's/REF://g')
        HIT_LINE_CLEAN=\$(echo \$HIT_LINE | tr -d '\\n')
        printf \$HIT_LINE >> ${confidence_set_name}.filtered.meta.blast
        awk -v hit=\$HIT_ID '{if(\$1==hit){print \$0}}' \$META >> ${confidence_set_name}.filtered.meta.blast
      done
    """
}
