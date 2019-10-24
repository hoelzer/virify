process multiqc {
    publishDir "${params.output}/${name}/${params.dir}", mode: 'copy', pattern: "multiqc_report.html"
    label 'multiqc'  
  input:
    tuple val(name), file(fastqc)
  output:
    tuple val(name), file("multiqc_report.html")
  script:
    """
    multiqc -i ${name} .
    """
  }

/* Comments:
*/