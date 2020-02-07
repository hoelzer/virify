process generate_krona_table {
      publishDir "${params.output}/${name}/${params.dir}", mode: 'copy', pattern: "${set_name}.krona.tsv"
      label 'python3'

    input:
      tuple val(name), val(set_name), file(tbl)
    
    output:
      tuple val(name), val(set_name), file("${set_name}.krona.tsv")
    
    shell:
    """
    generate_krona_table.py -f ${tbl} -o ${set_name}.krona.tsv
    """
}