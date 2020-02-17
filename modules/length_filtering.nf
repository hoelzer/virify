process length_filtering {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}*_renamed.fasta"
      label 'python3'

    input:
      tuple val(name), file(fasta) 
    
    output:
      tuple val(name), file("${name}*_renamed.fasta")
    
    shell:
    """    
      LEN=500
      if [[ ${fasta} =~ \\.gz\$ ]]; then
      	 zcat ${fasta} > ${name}.fasta
      	 filter_contigs_len.py -f ${name}.fasta -l 0.5 -o ./
      else
      	 filter_contigs_len.py -f ${fasta} -l 0.5 -o ./
      fi
      awk '/^>/{print ">contig" ++i; next}{print}' < ${name}_filt\${LEN}bp.fasta > ${name}_filt\${LEN}bp_renamed.fasta 
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
