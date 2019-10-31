process umap {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.umap.tsv"
      label 'marine_phage_paper_scripts'

    input:
      tuple val(name), file(kmer_freqs) 

    output:
      tuple val(name), file("${name}.umap.tsv")

    script:
      """
      run_umap.py -p ${name} ${kmer_freqs}
      """
}

/*COMMENTS
    # Optional arguments
    parser.add_argument("-p", "--prefix", help="Output file prefix (<prefix>.umap.tsv) [output]", type=str, default="output")
    parser.add_argument("-l", "--min_length", help="Minimum read length to include in the 2D map [15000]", type=int, default=15000)
    parser.add_argument("-d", "--min_dist", help="Minimum distance apart that points are allowed to be in the 2D map [0.1]", type=float, default=0.1)
    parser.add_argument("-n", "--n_neighbors", help="Number of neighbors to look at when learning the manifold structure [15]", type=int, default=15)
*/