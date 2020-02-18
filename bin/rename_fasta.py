#!/usr/bin/env python3

import argparse
import csv
import sys


def _clean_seq_name(seq):
    if not seq:
        return seq
    return seq.replace(">", "").replace("\n", "")


def rename(args):
    """Rename a multi-fasta fasta entries with <name>.<counter> and store the
    mapping between new and old files in tsv (args.map)
    """
    print("Renaming " + args.input)
    with open(args.input, "r") as fasta_in:
        with open(args.output, "w") as fasta_out, open(args.map, "w") as map_tsv:
            count = 1
            tsv_map = csv.writer(map_tsv)
            tsv_map.writerow(["original", "renamed"])
            for line in fasta_in:
                if line.startswith(">"):
                    fasta_out.write(f">{args.prefix}{count}\n")
                    tsv_map.writerow([_clean_seq_name(line), f"{args.prefix}{count}"])
                    count += 1
                else:
                    fasta_out.write(line)
    print(f"Wrote {count} sequences to {args.output}.")


def restore(args):
    """Restore a multi-fasta fasta using the mapping file.
    """
    print("Restoring " + args.input)

    mapping = {}
    with open(args.map, "r") as map_tsv:
        for m in csv.DictReader(map_tsv):
            mapping[m["renamed"]] = m["original"]

    with open(args.input, "r") as fasta_in:
        with open(args.output, "w") as fasta_out:
            for line in fasta_in:
                if line.startswith(">"):
                    mod = _clean_seq_name(line)
                    original = mapping.get(mod, None)
                    if not original:
                        print(
                            f"Missing sequence in mapping: {line}", file=sys.stderr)
                        original = mod
                    fasta_out.write(f">{original}\n")
                else:
                    fasta_out.write(line)


def main():
    """Multi fasta rename and restore."""
    parser = argparse.ArgumentParser(
        description="Rename multi fastas and restore the names tools.")
    parser.add_argument(
        "-i", "--input", help="indicate input FASTA file", required=True)
    parser.add_argument(
        "-m", "--map", help="Map current names with the renames", type=str,
        default="fasta_map.tsv")
    parser.add_argument(
        "-o", "--output", help="indicate output FASTA file", required=True)
    subparser = parser.add_subparsers()

    rename_parser = subparser.add_parser("rename")
    rename_parser.add_argument(
        "--prefix", help="string pre fasta count, i.e. default is seq such as seq1, seq2...",
        type=str, default="seq")
    rename_parser.set_defaults(func=rename)

    restore_parser = subparser.add_parser("restore")
    restore_parser.set_defaults(func=restore)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()