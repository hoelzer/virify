process filter_bins {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "${name}.bin_rl_filter.tsv"
      label 'marine_phage_paper_scripts'

    input:
      tuple val(name), file(hdbscan_clusters) 

    output:
      tuple val(name), file("${name}.bin_rl_filter.tsv")

    script:
      """
      filter_bins.py -p ${name} ${hdbscan_clusters}
      """
}

/* COMMENTS
    # Optional arguments
    parser.add_argument("-p", "--prefix", help="Output file prefix [bin_filter]", type=str, default="bin_filter")
    parser.add_argument("--length_min", help="Left bound of the read length distribution to consider [20000]", type=int, default=20000)
    parser.add_argument("--length_max", help="Right bound of the read length distribution to consider [80000]", type=int, default=80000)
    parser.add_argument("-w", "--min_window_area", help="Min fraction of AUC for a slice area to be considered a peak (changing not recommended) [0.04]", type=float, default=0.04)
*/