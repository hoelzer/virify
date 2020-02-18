#!/usr/bin/env ruby

require 'bio'

contigs = ARGV[0]
virfinder = File.open(ARGV[1],'r')
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
end

# HC
Dir.glob("#{virsorter_dir}/VIRSorter_cat-[1,2].fasta").each do |fasta|
	Bio::FastaFormat.open(fasta).each do |entry|
		id = entry.definition.chomp.sub('VIRSorter_','').split('-')[0]
		seq = entry.seq.chomp
		HC_viral_predictions[id] = seq
	end
end
puts "read in #{HC_viral_predictions.size} high confidence viral predictions."
puts HC_viral_predictions.keys

# LC
# VirFinder reported p < 0.05 and score >= 0.9
# or those for which VirFinder reported p < 0.05 and 0.7<=score<0.9, and that VirSorter reported as category 3
virsorter_cat3 = []
Dir.glob("#{virsorter_dir}/VIRSorter_cat-3.fasta").each do |fasta|
	Bio::FastaFormat.open(fasta).each do |entry|
		id = entry.definition.chomp.sub('VIRSorter_','').split('-')[0]
		virsorter_cat3.push(id)
	end
end
virfinder.each do |line|
	unless line.start_with?('name')
		s = line.split("\t")
		score = s[2].to_f
		pvalue = s[3].to_f
		contig = s[0]
		if score >= 0.9 && pvalue < 0.05 && !HC_viral_predictions.include?(contig)
			LC_viral_predictions[contig] = all_contigs[contig]
		end
		if score >= 0.7 && score < 0.9 && pvalue < 0.05 && virsorter_cat3.include?(contig) && !HC_viral_predictions.include?(contig)
			LC_viral_predictions[contig] = all_contigs[contig]
		end
	end
end
virfinder.close
puts "read in #{LC_viral_predictions.size} low confidence viral predictions."
puts LC_viral_predictions.keys

# Prophages
Dir.glob("#{virsorter_dir}/VIRSorter_prophages_cat-[4,5].fasta").each do |fasta|
	Bio::FastaFormat.open(fasta).each do |entry|
		id = entry.definition.chomp.sub('VIRSorter_','').split('_')[0].sub('-circular','')
		start = entry.definition.chomp.split('-')[1]
		stop = entry.definition.chomp.split('-')[2]
		id += " #{start}-#{stop}"
		seq = entry.seq.chomp
		prophage_predictions[id] = seq
	end
end
puts "read in #{prophage_predictions.size} prophage predictions."
puts prophage_predictions.keys

# write out
HC_viral_predictions_file = File.open('high_confidence_putative_viral_contigs.fna','w')
LC_viral_predictions_file = File.open('low_confidence_putative_viral_contigs.fna','w')
prophage_predictions_file = File.open('putative_prophages.fna','w')

HC_viral_predictions.each do |id, seq|
	HC_viral_predictions_file << ">#{id}\n#{seq}\n"
end
HC_viral_predictions_file.close

LC_viral_predictions.each do |id, seq|
	LC_viral_predictions_file << ">#{id}\n#{seq}\n"
end
LC_viral_predictions_file.close

prophage_predictions.each do |id, seq|
	prophage_predictions_file << ">#{id}\n#{seq}\n"
end
prophage_predictions_file.close