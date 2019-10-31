process hdbscan {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.hdbscan.tsv"
      label 'marine_phage_paper_scripts'

    input:
      tuple val(name), file(umap_clusters) 

    output:
      tuple val(name), file("${name}.hdbscan.tsv")

    script:
      """
      run_hdbscan.py -p ${name} ${umap_clusters}
      """
}

/* COMMENTS
   # Optional arguments
    parser.add_argument("-p", "--prefix", help="Output file prefix (<prefix>.hdbscan.tsv) [output]", type=str, default="output")
    parser.add_argument("-c", "--min_cluster", help="Minimum number of reads to call a bin [30]", type=int, default=30)
*/