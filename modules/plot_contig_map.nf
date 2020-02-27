process plot_contig_map {
      publishDir "${params.output}/${name}/${params.plotdir}/", mode: 'copy', pattern: "${set_name}_mapping_results"
      publishDir "${params.output}/${name}/${params.plotdir}/${set_name}_mapping_results/", mode: 'copy', pattern: "*.tsv"
      label 'plot_contig_map'

    input:
      tuple val(name), val(set_name), file(tab)
    
    output:
      tuple val(name), file("${set_name}_mapping_results"), file("*.tsv")
    
    shell:
    """
	# get only contig IDs that have at least one annotation hit 
	IDS=\$(awk 'BEGIN{FS="\\t"};{if(\$6!="No hit"){print \$1}}' ${tab} | sort | uniq | grep -v Contig)
	head -1 ${tab} > plot.tsv
	for ID in \$IDS; do
		awk -v id="\$ID" '{if(id==\$1){print \$0}}' ${tab} >> plot.tsv
	done
    plot_contigs_pdf.R -o ${set_name}_mapping_results -t plot.tsv
    """
}

/* OUTPUT LOOKS LIKE
Contig	CDS_ID	Start	End	Direction	Best_hit	Abs_Evalue_exp	Label
pos.phage.0	pos.phage.0_1	265	537	1	No hit	NA
pos.phage.0	pos.phage.0_63	24589	25578	-1	ViPhOG17126.faa	11	Batrachovirus
pos.phage.0	pos.phage.0_64	25578	25991	-1	No hit	NA
pos.phage.0	pos.phage.0_81	33714	34214	-1	ViPhOG602.faa	30	Myoviridae
pos.phage.0	pos.phage.0_82	34227	34370	-1	No hit	NA
*/

/*
#!/usr/bin/env Rscript

#load libraries
library(optparse)
library(ggplot2)
library(gggenes)
library(RColorBrewer)

#prepare arguments
option_list <- list(
	make_option(c("-t", "--table"), type = "character", default = NULL,
		help = "Annotation table containing ViPhOG hmmer results for viral contig file",
		metavar = "table"),
	make_option(c("-o", "--outdir"), type = "character", default = ".",
		help = "Output directory (default: cwd)", metavar = "outdir"))

opt_parser <- OptionParser(option_list = option_list);
opt <- parse_args(opt_parser);

if (is.null(opt\$table)) {
	print_help(opt_parser)
	stop("Provide table containing ViPhOG hmmer results for viral contig file")/Users/kates/Desktop/CWL_viral_pipeline/CWL/prodigal
}

#prepare input file
path <- normalizePath(opt\$table)
annotation_table <- read.delim(path, stringsAsFactors = FALSE)

#Create column indicating significance of hmmer hits
colour_func <- function(x) {
	if (is.na(x)) {
		"No hit"
	} else if (x < 10) {
		"Low confidence"
	} else {
		"High confidence"
	}
}
annotation_table\$Colour <- factor(lapply(annotation_table\$Abs_Evalue_exp, colour_func), levels = c("No hit", "Low confidence", "High confidence"))

#Create column for label position
annotation_table\$Position <- annotation_table\$Start + (annotation_table\$End - annotation_table\$Start)/2

#Create vector of colours for different levels of significance of annotations
myColors <- c("#808080", "#EAEA1E", "#08B808")
names(myColors) <- levels(annotation_table\$Colour)

dir.create(opt\$outdir, showWarnings = FALSE)

#Generate maps for each viral contig identified
for (item in unique(annotation_table\$Contig)) {
	sample_data <- subset(annotation_table, Contig == item)
	pdf(file.path(normalizePath(opt\$outdir), paste(item, ".pdf", sep = "")), width = 25, height = 10)
	print(ggplot(sample_data, aes(xmin = Start, xmax = End, y = Contig, fill = Colour, forward = Direction))
	+ geom_gene_arrow(arrowhead_height = unit(3, "mm"), arrowhead_width = unit(1, "mm"))
	+ geom_text(aes(x = Position, label = Label), angle = 90, colour = "black", size = 3, hjust = -0.2)
	+ scale_fill_manual(name = "Confidence", values = myColors)
	+ theme_genes())
	dev.off()
}

*/