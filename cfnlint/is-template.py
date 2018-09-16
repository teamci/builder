#!/usr/bin/env python

import cfnlint.decode
import sys

def main(fileNames):
    for path in fileNames:
        (data, _errors) = cfnlint.decode.decode(path, ignore_bad_template = True)
        if data and 'AWSTemplateFormatVersion' in data:
            print(path)


if __name__ == "__main__":
    main(sys.argv[1:])
