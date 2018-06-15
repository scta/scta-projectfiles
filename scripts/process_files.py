#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Script wrapping processing of files with Saxon.
"""

import argparse
import os
import subprocess
from time import time

__version__ = '0.0.1'

def parse_arguments():
    parser = argparse.ArgumentParser(
        prog='process_files',
        usage='%(prog)s [options] PATH',
        description='Run saxon with specified XSL on directory or file.')
    parser.add_argument('path', metavar='PATH', type=str, nargs=1,
                        help='Directory or file to be processed.')
    parser.add_argument(
        '-o', '--output', dest='output', action='store', default='.',
        help=('Output directory. (default: "%(default)s")')
    )
    parser.add_argument(
        '--xsl', dest='xsl', action='store', required=True,
        help=('The XSL script used for conversion. (default: "%(default)s")')
    )
    parser.add_argument('-v', '--version', action='version',
                        version='%(prog)s {}'.format(__version__),
                        help='Show version and exit.')

    return vars(parser.parse_args())



def process_file(filename, output, xsl):
    print('Start processing %s' % filename)
    proc = subprocess.Popen(
        ['saxon',
         '-s:%s' % filename,
         '-xsl:%s' % xsl,
         '-o:%s/%s' % (output, filename)])
    return proc

def main():
    args = parse_arguments()

    input_path = args['path'][0]
    output = args['output']
    xsl = args['xsl']

    if output == input_path:
        answer = raw_input(
            'Both the output and input paths are "%s". This means that the '
            'results will overwrite the input files. \n'
            'Are your sure your want to do this? (y/n)?' % output)
        if not answer.lower() == 'y':
            print('You can set the output path with the --output parameter.')
            print('Quitting.')
            exit(0)


    start = time()
    print('Collecting files...')

    filelist = []
    if os.path.isdir(input_path):
        for filename in os.listdir(input_path):
            if filename.endswith('.xml'):
                filelist.append(filename)
    elif (os.path.isfile(input_path)
          and os.path.splitext(input_path)[1] == '.xml'):
        filelist.append(input_path)


    print('Start processing files...')
    procs = []
    for filename in filelist:
        proc = process_file(filename, output, xsl)
        procs.append(proc)

    for proc in procs:
        proc.communicate()

    print('All processes finished in %.3f seconds' % (time() - start))
    print('Files are located in "%s"' % output)


if __name__ == '__main__':
    main()
