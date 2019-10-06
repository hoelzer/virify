process multiqc {
    publishDir "${params.output}/${name}/${params.readQCdir}", mode: 'copy', pattern: "multiqc_report.html"
    label 'multiqc'  
  input:
    set val(name), file(fastqc)
  output:
    set val(name), file("multiqc_report.html")
  script:
    """
    multiqc -i ${name} .
    """
  }

/* Comments:
*/