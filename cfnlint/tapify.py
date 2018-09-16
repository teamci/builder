#!/usr/bin/env python

import yaml, json, sys

def annotation_level(level):
    levels = {
        'Error': 'failure',
        'Warning': 'warning'
    }

    return levels.get(level, 'notice')

def main():
    report = json.load(sys.stdin)

    print('--- TAP')
    print('1..{}'.format(len(report)))

    for i, data in enumerate(report):
        path = data.get('Filename')
        message = data.get('Message')

        print('not ok {} - {}'.format(i + 1, path))
        encoded = yaml.dump({
            'path': path,
            'start_line': data.get('Location').get('Start').get('LineNumber'),
            'end_line': data.get('Location').get('End').get('LineNumber'),
            'annotation_level': annotation_level(data.get('Level')),
            'message': message,
            'title': 'cfn-lint: {}'.format(data.get('Rule').get('Id'))
        }, explicit_start = True, explicit_end = True, default_flow_style = False)

        for line in encoded.splitlines():
            print('  {}'.format(line))

    print('--- TAP')

if __name__ == "__main__":
    main()
