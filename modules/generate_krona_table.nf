process generate_krona_table {
      publishDir "${params.output}/${name}/${params.plotdir}", mode: 'copy', pattern: "*.krona.tsv"
      label 'python3'

    input:
      tuple val(name), val(set_name), file(tbl)
    
    output:
      tuple val(name), val(set_name), file("*.krona.tsv")
    
    shell:
    """
    if [[ "${set_name}" == "all" ]]; then
      grep contig_ID *.tsv | awk 'BEGIN{FS=":"};{print \$2}' | uniq > ${name}.tsv
      grep -v "contig_ID" *.tsv | awk 'BEGIN{FS=":"};{print \$2}' | uniq >> ${name}.tsv
      generate_krona_table.py -f ${name}.tsv -o ${name}.krona.tsv
    else
      generate_krona_table.py -f ${tbl} -o ${set_name}.krona.tsv
    fi
    """
}
