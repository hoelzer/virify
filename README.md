![](https://img.shields.io/badge/nextflow-19.10.0-brightgreen)
![](https://img.shields.io/badge/uses-docker-blue.svg)
![](https://img.shields.io/badge/uses-conda-yellow.svg)

Email: hoelzer.martin@gmail.com

# VIRify

A nextflow implementation of the [EBI VIRify pipeline](https://github.com/EBI-Metagenomics/emg-viral-pipeline) for the detection of viruses from metagenomic assemblies.
This implementation is heavily based on scripts and work by [Guillermo Rangel-Pineros](https://github.com/guille0387).

## Basic execution

````
nextflow run virify.nf --fasta 'example_data/miseq.fasta'
````

See 

````
netflow run virify.nf --help
````

for more parameter options. 


## DAG chart

![DAG chart](figures/chart.png)

