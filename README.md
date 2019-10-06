# VIRify

A nextflow implementation of the EBI VIRify pipeline for the detection of viruses from metagenomic samples.

## Basic execution

````
nextflow run main.nf --illumina 'example_data/SRR8811962*.R{1,2}.fastq.gz'
````

See 

````
netflow run main.nf --help
````

for more parameter options. 


## Example test data

To be able to test the execution of the workflow with small example read data sets we obtained Illumina and Nanopore data from a marine plankton metagenome study ([Beaulaurier et al. (2019)][1]). Data was [downloaded][2] and a small sequence subset was selected:

### Illumina

````
wget -O - ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR881/002/SRR8811962/SRR8811962_1.fastq.gz | gunzip -c > SRR8811962_1.fastq.tmp; head -800000 SRR8811962_1.fastq.tmp | gzip > example_data/SRR8811962.R1.fastq.gz
wget -O - ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR881/002/SRR8811962/SRR8811962_2.fastq.gz | gunzip -c > SRR8811962_2.fastq.tmp; head -800000 SRR8811962_2.fastq.tmp | gzip > example_data/SRR8811962.R2.fastq.gz
````

### Nanopore 

````
wget -O - ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR881/000/SRR8811960/SRR8811960_1.fastq.gz | gunzip -c SRR8811960_1.fastq.tmp; head -20000 SRR8811960_1.fastq.tmp | gzip > example_data/SRR8811960.fastq.gz
````




[1]: https://www.biorxiv.org/content/10.1101/619684v1
[2]: https://www.ebi.ac.uk/ena/browser/view/PRJNA529454