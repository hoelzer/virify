process multiqc {
    publishDir "${params.output}/${name}/${params.readQCdir}", mode: 'copy', pattern: "multiqc/multiqc_report.html"
    label 'multiqc'  
  input:
    set val(name), file(r1html), file(r2html), file(r1zip), file(r2zip)
  output:
    set val(name), file("multiqc/multiqc_report.html")
  script:
    """
    multiqc -i ${name} -o multiqc .
    """
  }

/* Comments:
*/