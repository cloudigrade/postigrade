#!/usr/bin/env python3
"""
Read JSON file and dump contents to source-able shell script.

Useful for extracting Clowder's $ACG_CONFIG file (usually '/cdapp/cdappconfig.json').
"""
import argparse
import json
import sys

from flatten_dict import flatten


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("-p", "--prefix", type=str, help="optional prefix for each variable's name")
    parser.add_argument("-e", "--export", action='store_true', help="export the env vars")
    parser.add_argument("inputfile", nargs="?", type=argparse.FileType("r"), help="JSON file input, or '-' to read stdin")
    args = parser.parse_args()

    if not args.inputfile:
        sys.exit("Please provide an input file, or use '-' to read stdin.")

    json_data = json.load(args.inputfile)
    flat_data = flatten(json_data, reducer='underscore', enumerate_types=(list,))

    for key, value in flat_data.items():
        value = value.replace("'", "'\"'\"'") if isinstance(value, str) else value
        key = f"{args.prefix if args.prefix else ''}{key}"
        print(f"{'export ' if args.export else ''}{key.upper()}='{value}'")

if __name__ == "__main__":
    main()
