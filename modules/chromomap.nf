process generate_chromomap_table {
      publishDir "${params.output}/${name}/${params.finaldir}/chromomap/", mode: 'copy', pattern: "${set_name}.filtered-*.contigs.txt"
      label 'ruby'

    input:
      tuple val(name), val(set_name), file(annotation_table)
    
    output:
      tuple val(name), val(set_name), file("${set_name}.filtered-*.contigs.txt"), file("${set_name}.filtered-*.anno.txt")
    
    shell:
    id = set_name
    if (set_name == "all") { id = name }
    """
    # combine
    if [[ ${id} == "all" ]]; then
      cat *.tsv | grep -v Abs_Evalue_exp | sort | uniq > ${id}.tsv
    else
      cp ${annotation_table} > ${id}.tsv
    fi

    # get contigs and sort
    awk '{print \$1}' ${id}.tsv | awk '{printf \$0"\\t"1"\\t"};BEGIN{FS="_"};{print \$4}' | uniq | awk 'BEGIN{FS="_"}{print \$1"_"\$2"\\t"\$6}' | awk '{print \$1"\\t"\$3"\\t"\$4}' | sort -k3n > ${id}.contigs.txt

    # get annotations
    awk '{print \$2"\\t"\$1"\\t"\$3"\\t"\$4"\\t"\$6"\\t"\$7}' ${id}.tsv | awk 'BEGIN{FS="_"}{print \$1"_"\$2"_"\$7"_"\$8"\\t"\$12}' | awk '{print \$1"\\t"\$2"\\t"\$4"\\t"\$5"\\t"\$6"\\t"\$7}' > tmp
    awk '{if(\$6<10){print \$1"\\t"\$2"\\t"\$3"\\t"\$4"\\tLow confidence"}}' tmp > lc.txt
    awk '{if(\$6=="hit"){print \$1"\\t"\$2"\\t"\$3"\\t"\$4"\\tNo hit"}}' tmp > no.txt
    awk '{if(\$6>=10 && \$6!="hit"){print \$1"\\t"\$2"\\t"\$3"\\t"\$4"\\tHigh confidence"}}' tmp > hc.txt
    cat hc.txt lc.txt no.txt > ${id}.anno.txt

    # now we remove contigs shorter 1500 kb and very long ones because ChromoMap has an error when plotting to distinct lenghts
    # we also split into multiple files when we have many contigs, chunk size default 30
    filter_for_chromomap.rb ${id}.contigs.txt ${id}.anno.txt 1500
    """
}

process chromomap {
    publishDir "${params.output}/${name}/${params.finaldir}/chromomap/", mode: 'copy', pattern: "*.html"
    label 'chromomap'

    input:
      tuple val(name), val(set_name), file(contigs), file(annotations)
    
    output:
      tuple val(name), val(set_name), file("*.html")
    
    shell:
    id = set_name
    if (set_name == "all") { id = name }
    """
    #!/usr/bin/env Rscript

    library(chromoMap)
    library(ggplot2)
    library(plotly)

    contigs <- list()
    annos <- list()
    contigs <- dir(pattern = "*.contigs.txt")
    annos <- dir(pattern = "*.anno.txt")

    for (k in 1:length(contigs)){
      c = contigs[k]
      a = annos[k]
      p <-  chromoMap(paste(c, a,
        data_based_color_map = T,
        data_type = "categorical",
        data_colors = list(c("limegreen", "orange","grey")),
        legend = T, lg_y = 400, lg_x = 100, segment_annotation = T,
        left_margin = 100, canvas_width = 1000, chr_length = 8, ch_gap = 6)
      htmlwidgets::saveWidget(as_widget(p), paste("${id}.chromomap-", k, ".html", sep=''))
    }    
    """
}