process generate_sankey_table {
      publishDir "${params.output}/${name}/${params.plotdir}", mode: 'copy', pattern: "${tbl}.json"
      label 'ruby'

    input:
      tuple val(name), val(set_name), file(krona_table)
    
    output:
      tuple val(name), val(set_name), file("${tbl}.json")
    
    shell:
    """
    krona_table_2_sankey_table.rb ${krona_table} ${set_name}.sankey.tsv
    """
}

process sankey {
      publishDir "${params.output}/${name}/${params.plotdir}", mode: 'copy', pattern: "${tbl}.html"
      label 'sankey'

    input:
      tuple val(name), val(set_name), file(tbl)
    
    output:
      tuple val(name), val(set_name), file("${tbl}.json")
    
    shell:
    """
    tsv2json.rb ${tbl} 200
    """
}