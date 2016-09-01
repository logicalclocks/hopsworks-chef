#!/usr/bin/env python


if __name__ == '__main__':

    with open('./metadata.rb') as infile, open ('./params.txt') as meta, open('metadata.rb.new', 'w') as outfile:
        copy = True
        for line in infile:
            if line.strip() == "### BEGIN GENERATED CONTENT":
                copy = False
                outfile.write("### BEGIN GENERATED CONTENT\n\n")
                for l2 in meta:
                    outfile.write(l2)
            elif copy:
                outfile.write(line)
