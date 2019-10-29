process kaijuGetDB {
  label 'kaiju'    
  if (params.cloudProcess) { 
    publishDir "${params.cloudDatabase}/kaiju/", mode: 'copy', pattern: "nr_euk" //pattern: "viruses"
  }
  else { 
    storeDir "nextflow-autodownload-databases/kaiju/" 
  }  

  output:
    file("nr_euk")
    //file("viruses")

  script:
    """
    #this is the full database
    if [ 42 == 42 ]; then
    wget http://kaiju.binf.ku.dk/database/kaiju_db_nr_euk_2019-06-25.tgz 
    tar -xvzf kaiju_db_nr_euk_2019-06-25.tgz
    rm kaiju_db_nr_euk_2019-06-25.tgz
    mkdir nr_euk
    mv names.dmp nodes.dmp viruses nr_euk
    fi

    # for testing purpose download a smaller one
    if [ 42 == 0 ]; then
    mkdir viruses
    cd viruses
    wget http://kaiju.binf.ku.dk/database/kaiju_db_viruses_2019-06-25.tgz
    tar -xvzf kaiju_db_viruses_2019-06-25.tgz
    rm kaiju_db_viruses_2019-06-25.tgz
    fi
    """
}


