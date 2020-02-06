process rvdbGetDB {
  label 'basics'    
  if (params.cloudProcess) { 
    publishDir "${params.cloudDatabase}/", mode: 'copy', pattern: "rvdb" 
  }
  else { 
    storeDir "nextflow-autodownload-databases/" 
  }  

  output:
    file("rvdb")

  script:
    """
    wget -nH ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/viral-pipeline/databases/rvdb_v17.0.tar.gz && tar -zxvf rvdb_v17.0.tar.gz
    rm rvdb_v17.0.tar.gz
    """
}
