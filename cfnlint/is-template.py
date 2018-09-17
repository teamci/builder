#!/usr/bin/env python

import cfnlint.decode
import sys, yaml

def main(fileNames):
    for path in fileNames:
        try:
            (data, _errors) = cfnlint.decode.decode(path, ignore_bad_template = True)
            if data and 'AWSTemplateFormatVersion' in data:
                print(path)
        except yaml.composer.ComposerError:
            pass


if __name__ == "__main__":
    main(sys.argv[1:])
