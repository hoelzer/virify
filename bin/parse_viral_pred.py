#!/usr/bin/env python3

import argparse
import glob
import re
import sys
from os.path import join

from Bio import SeqIO

import pandas as pd


def parse_pprmeta(file_name):
    """Extract phage hits from PPR-Meta.
    """
    result_df = pd.read_csv(file_name, sep=",")

    lc_ids = set(result_df[
        (result_df["Possible_source"] == "phage")
    ]["Header"].values)

    print(f"PPR-Meta found {len(lc_ids)} low confidence contigs.")

    return lc_ids


def parse_virus_finder(file_name):
    """Extract high and low confidence contigs from virus finder results.
    """
    result_df = pd.read_csv(file_name, sep="\t")

    hc_ids = set(
        result_df[(result_df["pvalue"] < 0.05) &
                  (result_df["score"] >= 0.90)]["name"].values)

    print(f"Virus Finder found {len(hc_ids)} high confidence contigs.")

    lc_ids = set(result_df[
        (result_df["pvalue"] < 0.05) &
        (result_df["score"] >= 0.70) &
        (result_df["score"] < 0.9)
    ]["name"].values)

    print(f"Virus Finder found {len(lc_ids)} low confidence contigs.")

    return hc_ids, lc_ids


def _clean_vsorter_name(name):
    """ Correct name as virsoter contig names.
    VirSorter changes dots by _. For prophages it adds a _gene_1_gene_12-0-9235 string.
    For example:
    - NODE_1_length_79063_cov_13.902377 to NODE_1_length_79063_cov_13_902377
    Prophages:
    - VIRSorter_NODE_306_length_14315_cov_22_151052_gene_1_gene_12-0-9235-cat_5
    """
    name = name.replace("VIRSorter_", "")
    # restore the dots, this is specific to EBI
    vs_name_re = re.compile(r"(.*cov_\d+)(\_)(\d.+)")
    name = re.sub(vs_name_re, r"\1.\3", name)
    # the next regex considers prophages too
    suffix_re = re.compile(
        r"(?:_gene_\d+_gene_\d+-\d+-\d+)?(?:-circular)?-cat_\d+$")
    name = re.sub(suffix_re, "", name)
    return name


def parse_virus_sorter(folder_name):
    """Extract high, low and prophages confidence contigs from virus sorter results.
    High confidence are contigs in the categories 1 and 2
    Low confidence are contigs in the category 3
    Putative prophages are in categories 4 and 5
    (which correspond to VirSorter confidence categories 1 and 2)
    """
    high_confidence = set()
    low_confidence = set()
    prophages = set()

    files = glob.glob(join(folder_name, '*cat-[1,2,3,4,5,6].fasta'))

    for file in files:
        with open(file, 'r') as fasta:
            line = fasta.readline()
            while line:
                if not line.startswith('>'):
                    line = fasta.readline()
                    continue
                line = line.strip().replace('>', '')
                category = line[-1:]
                name = _clean_vsorter_name(line)
                if category in ["1", "2"]:
                    high_confidence.add(name)
                elif category == "3":
                    low_confidence.add(name)
                elif category in ["4", "5"]:
                    prophages.add(name)
                elif category == "6":
                    pass
                else:
                    print(f"Contig has an invalid category : {category}")
                line = fasta.readline()

    print(f"Virus Sorter found {len(high_confidence)} high confidence contigs.")
    print(f"Virus Sorter found {len(low_confidence)} low confidence contigs.")
    print(f"Virus Sorter found {len(prophages)} putative prophages contigs.")

    return high_confidence, low_confidence, prophages


def virus_parser(assembly_file, vf_output, vs_output, pm_output):
    """Parse VirSorter, VirFinder and PPR-Meta outputs and merge the results.
    Expected outputs:
    - set of contig with high confidence viruses
    - set of contig with low confidence viruses
    - set of contig with prophages
    - dict[config] [virfinder cat (high, low), virsorter cat (high, low, pro)]
    High confidence viral contigs are those that are in virsorter categories
     1 and 2; low confidence viral contigs are those for which VirFinder
     reported p < 0.05 and score >= 0.9, or those for which VirFinder reported
     p < 0.05 and 0.7<=score<0.9, and that VirSorter reported as category 3 or 
     PPR-Meta reported as phage.
     Putative prophages are prophages reported by Virsorter in categories 4
      and 5 (which correspond to VirSorter confidence categories 1 and 2).
    """
    hc_predictions_contigs = []
    lc_predictions_contigs = []
    prophage_predictions_contigs = []

    # TODO: table with virfinder, virsorter assign
    # merge_table = {}

    pprmeta_lc = parse_pprmeta(pm_output)
    finder_lc, finder_lowestc = parse_virus_finder(vf_output)
    sorter_hc, sorter_lc, sorter_prophages = parse_virus_sorter(vs_output)

    for record in SeqIO.parse(assembly_file, "fasta"):
        # HC
        if record.id in sorter_hc:
            hc_predictions_contigs.append(record)
        # LC
        elif record.id in finder_lc:
            lc_predictions_contigs.append(record)
        elif record.id in sorter_lc and record.id in finder_lowestc:
            lc_predictions_contigs.append(record)
        elif record.id in pprmeta_lc and record.id in finder_lowestc:
            lc_predictions_contigs.append(record)
        # Pro
        elif record.id in sorter_prophages:
            prophage_predictions_contigs.append(record)

    return hc_predictions_contigs, lc_predictions_contigs, prophage_predictions_contigs


if __name__ == "__main__":
    """Merge and convert VIRSorter and VIRFinder output contigs into:
    - high confidence viral contigs
    - low confidence viral contigs
    - putative prophages
    """
    parser = argparse.ArgumentParser(
        description="Write fasta files with predicted _viral contigs sorted in "
                    "categories and putative prophages")
    parser.add_argument("-a", "--assemb", dest="assemb",
                        help="Metagenomic assembly fasta file", required=True)
    parser.add_argument("-f", "--vfout", dest="finder", help="Absolute or "
                        "relative path to VirFinder output file",
                        required=True)
    parser.add_argument("-s", "--vsdir", dest="sorter",
                        help="Absolute or relative path to directory containing"
                        " VirSorter output", required=True)
    parser.add_argument("-p", "--pmout", dest="pprmeta",
                        help="Absolute or relative path to PPR-Meta output file"
                        " PPR-Meta output", required=True)
    parser.add_argument("-o", "--outdir", dest="outdir",
                        help="Absolute or relative path of directory where output"
                        " _viral prediction files should be stored (default: cwd)",
                        default=".")
    args = parser.parse_args()

    hc_contigs, lc_contigs, prophage_contigs = virus_parser(
        args.assemb, args.finder, args.sorter, args.pprmeta)

    at_least_one = False
    if len(hc_contigs):
        SeqIO.write(hc_contigs, join(
            args.outdir, "high_confidence_putative_viral_contigs.fna"), "fasta")
        at_least_one = True
    if len(lc_contigs):
        SeqIO.write(lc_contigs, join(
            args.outdir, "low_confidence_putative_viral_contigs.fna"), "fasta")
        at_least_one = True
    if len(prophage_contigs):
        SeqIO.write(prophage_contigs, join(
            args.outdir, "putative_prophages.fna"), "fasta")
        at_least_one = True

    if not at_least_one:
        print("Overall, no putative _viral contigs or prophages were detected"
              " in the analysed metagenomic assembly", file=sys.stderr)
        exit(1)