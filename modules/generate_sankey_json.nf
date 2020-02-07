process generate_sankey_json {
      publishDir "${params.output}/${name}/${params.dir}", mode: 'copy', pattern: "${tbl}.json"
      label 'ruby'

    input:
      tuple val(name), val(set_name), file(tbl)
    
    output:
      tuple val(name), val(set_name), file("${tbl}.json")
    
    shell:
    """
    tsv2json.rb ${tbl} 200
    """
}