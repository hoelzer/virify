process generate_sankey_table {
      publishDir "${params.output}/${name}/${params.plotdir}", mode: 'copy', pattern: "${set_name}.sankey.*"
      label 'ruby'

    input:
      tuple val(name), val(set_name), file(krona_table)
    
    output:
      tuple val(name), val(set_name), file("${set_name}.sankey.json"), file("${set_name}.sankey.tsv")
    
    shell:
    """
    krona_table_2_sankey_table.rb ${krona_table} ${set_name}.sankey.tsv
    tsv2json.rb ${set_name}.sankey.tsv ${set_name}.sankey.json
    """
}

process sankey {
    publishDir "${params.output}/${name}/${params.plotdir}", mode: 'copy', pattern: "*.sankey.html"
    label 'sankey'

    input:
      tuple val(name), val(set_name), file(json), file(tsv)
    
    output:
      tuple val(name), val(set_name), file("*.sankey.html")
    
    shell:
    id = set_name
    if (set_name == "all") { id = name }
    """
    #!/usr/bin/env Rscript

    library(sankeyD3)
    library(magrittr)

    Taxonomy <- jsonlite::fromJSON("${json}")

    # print to HTML file
    sankeyNetwork(Links = Taxonomy\$links, Nodes = Taxonomy\$nodes, Source = "source", Target = "target", Value = "value", NodeID = "name", units = "count", fontSize = 22, nodeWidth = 30, nodeShadow = TRUE, nodePadding = 30, nodeStrokeWidth = 1, nodeCornerRadius = 10, dragY = TRUE, dragX = TRUE, numberFormat = ",.3g") %>% saveNetwork(file = '${id}.sankey.html')
    """
}