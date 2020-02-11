#!/usr/bin/env python3

import argparse
import glob
import re
import sys
from os.path import join

from Bio import SeqIO

import pandas as pd


def parse_virus_finder(file_name):
    """Extract high and low confidence contigs from virus finder results.
    """
    VF_result_df = pd.read_csv(file_name, sep="\t")

    # VF_high_ids
    VF_high_ids = list(VF_result_df[(VF_result_df["pvalue"] < 0.05) & (
        VF_result_df["score"] >= 0.90)]["name"].values)
    if len(VF_high_ids) < 1:
        print("No contigs with p < 0.05 and score >= 0.90 were reported by VirFinder")
    else:
        print(str(len(VF_high_ids)) + ' found VF high ids')

    # VF_low_ids
    VF_low_ids = list(
        VF_result_df[(VF_result_df["pvalue"] < 0.05) & (VF_result_df["score"] >= 0.70) & (VF_result_df["score"] < 0.9)][
            "name"].values)
    if len(VF_low_ids) < 1:
        print(
            "No contigs with p < 0.05 and 0.70 <= score < 0.90 were reported by VirFinder")
    else:
        print(str(len(VF_low_ids)) + ' found VF low ids')

    return set(VF_high_ids), set(VF_low_ids)


def parse_virus_sorter(folder_name):
    """Extract high, low and prophages confidence contigs from virus sorter results.
    """
    VirSorted_defined, VirSorted_prophages = [{}, {}]

    VirSorter_123 = glob.glob(join(folder_name, '*cat-{1,2,3}.fasta'))
    VirSorter_prophages = glob.glob(
        join(folder_name, '*cat-{4,5}.fasta'))

    print('VirSorter not prophages ' + str(len(VirSorter_123)) + ' files')
    print('VirSorter_prophages ' + str(len(VirSorter_prophages)))

    for file in VirSorter_123:
        category = int(file.split('cat-')[1][0])
        with open(file, 'r') as file_fasta:  # TODO read each second line
            for line in file_fasta:
                if line[0] == '>':
                    name = line.strip().split('VIRSorter_')[1]
                    if 'circular' in name:
                        name_modified = name.split('-circular')[0]
                        VirSorted_defined[name_modified] = str(
                            category * 10)  # for circular: <category>0
                    else:
                        name_modified = name.split('-cat_')[0]
                        VirSorted_defined[name_modified] = str(
                            category)  # for non circular: <category>

    for file in VirSorter_prophages:
        category = int(file.split('cat-')[1][0])
        with open(file, 'r') as file_fasta:  # TODO read each second line
            for line in file_fasta:
                if line[0] == '>':
                    line = line.strip().split('VIRSorter_')[1]
                    line = line.split('_gene_')
                    name = re.sub(r"[.,:; ]", "_", line[0])
                    suffix = '_gene_'.join(['']+line[1:])
                    VirSorted_prophages[name] = suffix

    return VirSorted_prophages, VirSorted_defined


def virus_parser(assembly_file, vf_output, vs_output):
    HC_viral_predictions, LC_viral_predictions, prophage_predictions = [
        [] for _ in range(3)]
    HC_viral_predictions_names, LC_viral_predictions_names, prophage_predictions_names = [
        '' for _ in range(3)]

    # VirFinder processing
    VF_high_ids_set, VF_low_ids_set = parse_virus_finder(vf_output)

    if len(glob.glob(join(vs_output, "*.fasta"))) > 0:
        # VirSorter reading
        VirSorted_prophages, VirSorted_defined = parse_virus_sorter(vs_output)

        # Assembly.fasta processing
        for record in SeqIO.parse(assembly_file, "fasta"):
            vs_id = re.sub(r"[.,:; ]", "_", record.id)
            if vs_id in VirSorted_defined:
                suff = '1_'
                if record.id in VF_high_ids_set:  # _11_H_
                    suff = '_1' + suff + 'H_'
                elif record.id in VF_low_ids_set:  # _11_L_
                    suff = '_1' + suff + 'L_'
                else:  # not defined by VirFinder
                    suff = '_0' + suff
                # [0/1]1_[H/L]?_[category]_[circular]?
                suff += VirSorted_defined[vs_id][0]
                if len(VirSorted_defined[vs_id]) > 1:  # circular
                    suff += '_circular'

                record.id += suff

                # category 1,2
                if VirSorted_defined[vs_id][0] == '1' or VirSorted_defined[vs_id][0] == '2':
                    HC_viral_predictions_names += record.description + '\n'
                    record.description = ''
                    HC_viral_predictions.append(record)

                elif VirSorted_defined[vs_id][0] == '3':  # category 3
                    # defined by VirFinder
                    if record.id in VF_high_ids_set.union(VF_low_ids_set):
                        LC_viral_predictions_names += record.description + '\n'
                        record.description = ''
                        LC_viral_predictions.append(record)

            elif vs_id not in VirSorted_prophages:  # not defined by VirSorter
                suff = '0_'
                if record.id in VF_high_ids_set:  # _10_H
                    suff = '_1' + suff + 'H'
                    record.id += suff
                    LC_viral_predictions_names += record.description + '\n'
                    record.description = ''
                    LC_viral_predictions.append(record)

            elif vs_id in VirSorted_prophages:  # Prophages
                record.id += VirSorted_prophages[vs_id]
                prophage_predictions_names += record.description + '\n'
                record.description = ''
                prophage_predictions.append(record)

    print(len(HC_viral_predictions), len(
        LC_viral_predictions), len(prophage_predictions))

    return [HC_viral_predictions, LC_viral_predictions, prophage_predictions,
            HC_viral_predictions_names, LC_viral_predictions_names, prophage_predictions_names]

if __name__ == "__main__":
    """Merge and convert VIRSorter and VIRFinder output contigs into:
    - high confidence viral contigs
    - low confidence viral contigs
    - putative prophages
    High confidence viral contigs are those that are in virsorter categories
     1 and 2; low confidence viral contigs are those for which VirFinder
     reported p < 0.05 and score >= 0.9, or those for which VirFinder reported 
     p < 0.05 and 0.7<=score<0.9, and that VirSorter reported as category 3. 
     Putative prophages are prophages reported by Virsorter in categories 4
      and 5 (which correspond to VirSorter confidence categories 1 and 2).
    """
    parser = argparse.ArgumentParser(
        description="Write fasta files with predicted _viral contigs sorted in categories and putative prophages")
    parser.add_argument("-a", "--assemb", dest="assemb",
                        help="Metagenomic assembly fasta file", required=True)
    parser.add_argument("-f", "--vfout", dest="finder", help="Absolute or relative path to VirFinder output file",
                        required=True)
    parser.add_argument("-s", "--vsdir", dest="sorter",
                        help="Absolute or relative path to directory containing VirSorter output", required=True)
    parser.add_argument("-o", "--outdir", dest="outdir",
                        help="Absolute or relative path of directory where output _viral prediction files should be stored (default: cwd)",
                        default=".")
    args = parser.parse_args()

    viral_predictions = virus_parser(args.assemb, args.finder, args.sorter)

    if sum([len(x) for x in viral_predictions]) > 0:
        if len(viral_predictions[0]) > 0:
            SeqIO.write(viral_predictions[0], join(
                args.outdir, "high_confidence_putative_viral_contigs.fna"), "fasta")
            with open(join(args.outdir, "high_confidence_putative_names.txt"), 'w') as high_names:
                high_names.write(viral_predictions[3])
        if len(viral_predictions[1]) > 0:
            SeqIO.write(viral_predictions[1], join(
                args.outdir, "low_confidence_putative_viral_contigs.fna"), "fasta")
            with open(join(args.outdir, "low_confidence_putative_names.txt"), 'w') as low_names:
                low_names.write(viral_predictions[4])
        if len(viral_predictions[2]) > 0:
            SeqIO.write(viral_predictions[2], join(
                args.outdir, "putative_prophages.fna"), "fasta")
            with open(join(args.outdir, "putative_prophages_names.txt"), 'w') as proph_names:
                proph_names.write(viral_predictions[5])
    else:
        print("Overall, no putative _viral contigs or prophages were detected in the analysed metagenomic assembly", file=sys.stderr)
        exit(1)