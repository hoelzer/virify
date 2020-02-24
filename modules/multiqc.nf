process multiqc {
    publishDir "${params.output}/${name}/${params.assemblydir}", mode: 'copy', pattern: "multiqc_report.html"
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