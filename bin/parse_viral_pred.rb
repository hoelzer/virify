#!/usr/bin/env ruby

require 'bio'

contigs = ARGV[0]
virfinder = ARGV[1]
virsorter_dir = ARGV[2]

HC_viral_predictions = {}
LC_viral_predictions = {}
prophage_predictions = {}
	
# Contigs
all_contigs = {}
Bio::FastaFormat.open(contigs).each do |entry|
	id = entry.definition.chomp
	seq = entry.seq.chomp
	all_contigs[id] = seq
	puts id
end


# VirSorter
Dir.glob("#{virsorter_dir}/VIRSorter_cat-[1,2].fasta").each do |fasta|
	Bio::FastaFormat.open(fasta).each do |entry|
		id = entry.definition.chomp.gsub('_','.').sub('VIRSorter.','').split('-cat.')[0]
		seq = entry.seq.chomp
		HC_viral_predictions[id] = seq
	end
end
puts "read in #{HC_viral_predictions.size} high confidence ciral predictions."