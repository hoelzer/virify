process spades {
    label 'spades'  
    publishDir "${params.output}/${name}/${params.dir}", mode: 'copy', pattern: "${name}.fasta"
  input:
    tuple val(name), file(reads)
  output:
    tuple val(name), file("${name}.fasta")
  shell:
    '''
    metaspades.py -1 !{reads[0]} -2 !{reads[1]} -t !{task.cpus} -m !{params.memory} -o assembly
    cp assembly/contigs.fasta !{name}.fasta
    '''
  }

/* Comments:
filter with awk command is not working, I think due to new lines that are present? 
awk '/^>/ { getline seq } length(seq) >1000 { print $0 "\\n" seq }' assembly/contigs.fasta > !{name}.filtered.fasta 
use SED or BIOAWK!
*/