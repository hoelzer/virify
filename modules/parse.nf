process parse {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.parsed.fna"
      label 'parse'

    input:
      tuple val(name), file(fasta)
      file(virfinder) 
      file(virsorter)
    
    output:
      tuple val(name), file("${name}.parsed.fna")
    
    shell:
    """
    parse_viral_pred.py -a ${fasta} -f ${virfinder} -s ${virsorter}
    """
}

/*
  usage: parse_viral_pred.py [-h] -a ASSEMB -f FINDER -s SORTER [-o OUTDIR]

  description: script generates three output_files: High_confidence.fasta, Low_confidence.fasta, Prophages.fasta

  optional arguments:
  -h, --help            show this help message and exit
  -a ASSEMB, --assemb ASSEMB
                        Metagenomic assembly fasta file
  -f FINDER, --vfout FINDER
                        Absolute or relative path to VirFinder output file
  -s SORTER, --vsdir SORTER
                        Absolute or relative path to directory containing
                        VirSorter output
  -o OUTDIR, --outdir OUTDIR
                        Absolute or relative path of directory where output
                        viral prediction files should be stored (default: cwd)
*/
