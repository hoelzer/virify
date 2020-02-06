process length_filtering {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}_filt*.fasta"
      label 'filter'

    input:
      tuple val(name), file(fasta) 
    
    output:
      tuple val(name), file("${name}_filt*.fasta")
    
    shell:
    """    
      filter_contigs_len.py -f ${fasta} -l 0.5 -o ./ 
    """
}

/*
  usage: filter_contigs_len.py [-h] -f input_file -l length_thres -o output_dir -i sample_id

  Extract sequences at least X kb long.

  positional arguments:
    fasta              Path to fasta file to filter

  optional arguments:
    -h, --help         show this help message and exit
    -l LENGTH          Length threshold in kb of selected sequences (default: 5kb)
    -o OUTDIR          Relative or absolute path to directory where you want to store output (default: cwd)
    -i IDENT           Dataset identifier or accession number. Should only be introduced if you want to add it to each sequence header, along with a sequential number
*/
