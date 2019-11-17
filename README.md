# VIRify

A nextflow implementation of the EBI VIRify pipeline for the detection of viruses from assemblies.

## Basic execution

````
nextflow run main.nf --fasta 'example_data/miseq.fasta'
````

See 

````
netflow run main.nf --help
````

for more parameter options. 


## DAG chart

![DAG chart](figures/chart.png)



[1]: https://www.biorxiv.org/content/10.1101/619684v1
[2]: https://www.ebi.ac.uk/ena/browser/view/PRJNA529454