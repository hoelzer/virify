#!/usr/bin/env ruby

contigs = File.open(ARGV[0],'r')
filter = ARGV[2].to_i
n = 30

contigs_h = {}
contigs.each do |line|
    s = line.split("\t")
    id = s[0]
    length = s[2].to_f
    if length > filter 
        contigs_h[id] = length    
    end
end
puts "selected #{contigs_h.size} contigs larger #{filter} nt"

# now check the ratio between shortest and longest contig
# based on the awk script before they are sorted
shortest_contig  = contigs_h.values[0]
puts shortest_contig
longest_contig = contigs_h.values[contigs_h.values.length-1]
puts longest_contig
ratio = shortest_contig / longest_contig
while (ratio < 0.015) 
    longest_contig_id = contigs_h.keys[contigs_h.values.length-1]
    contigs_h.delete(longest_contig_id)
    shortest_contig  = contigs_h.values[0]
    longest_contig = contigs_h.values[contigs_h.values.length-1]
    ratio = shortest_contig / longest_contig    
end
contigs.close

# write new contig map out, split if many entries
i = 0
chunk = true
chunk_n = 0
contigs_out = false
contig_ids_chunked = {}
contigs_h.each do |id, length|
    if i == n
        chunk = true
        chunk_n += 1
        i = 0
        contigs_out.close
    end
    if chunk
        contig_ids_chunked[chunk_n] = []
        contigs_out = File.open(ARGV[0].sub('.contigs',".filtered-#{chunk_n}.contigs"),'w')
        chunk = false
    end
    contig_ids_chunked[chunk_n].push(id)
    contigs_out << "#{id}\t1\t#{length.to_i}\n"
    i += 1
end

# now filter the annotations and only select those that match remaining contigs
# select now for each chunked file the correct annotations
contig_ids = contigs_h.keys
contig_ids_chunked.each do |chunk_id, chunk_contig_id_a|
    anno_out = File.open(ARGV[1].sub('.anno',".filtered-#{chunk_id}.anno"),'w')
    anno = File.open(ARGV[1],'r')
    anno.each do |line|
        id = line.split("\t")[1]
        if chunk_contig_id_a.include?(id)
            anno_out << line
        end
    end
    anno_out.close
end
