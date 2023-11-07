#!/usr/bin/python

import os
import shutil
import subprocess
import argparse
from benchmarks import parsec_param

# dirs for benchmarks
root_dir = os.environ['xxPARSECDIRxx']

# dir to build linux
out_dir = os.path.abspath(os.environ['BENCHMARKS_OUT'])

# parsec
for bench in os.environ['BENCHMARKS'].split():
    param = parsec_param[bench]
    for size in os.environ['SIMSIZES'].split():
        print('')
        print('=========================================')
        print('Generating parsec benchmark {} size {} ...'.format(bench, size))
        print('=========================================')
        print('')

        test_dir = os.path.join(out_dir, bench, size)

        # clean up test dir
        if os.path.isdir(test_dir):
            shutil.rmtree(test_dir)
        os.makedirs(test_dir)

        # copy binary
        binary = os.path.join(root_dir, param['dir'], bench,
                              'inst', '-linux.gcc', 'bin', bench)
        print("copy to {}".format(test_dir))
        shutil.copy(binary, test_dir)

        # copy inputs
        input_tar = os.path.join(root_dir, param['dir'], bench,
                                 'inputs', 'input_' + size + '.tar')
        if os.path.isfile(input_tar):
            subprocess.check_call(['tar', '-xf', input_tar, '-C', test_dir])

        # write run.sh: $1 to run.sh is thread num
        run_sh = os.path.join(test_dir, 'run.sh')
        if os.path.isfile(run_sh):
            raise Exception('run.sh already exists!')
        with open(run_sh, 'w') as fp:
            fp.write('#!/bin/bash\n')
            fp.write('if [ $# -ne 1 ]; then\n')
            fp.write('  echo "Usage: ./run.sh THREAD_NUM"\n')
            fp.write('  exit\n')
            fp.write('fi\n')
            # for facesim, create output dir
            if bench == 'facesim':
                fp.write('mkdir -p /tmp/Storytelling/output\n')
            # for freqmine thread num is in OMP_NUM_THREADS
            if bench == 'freqmine':
                fp.write('export OMP_NUM_THREADS=$1\n')
                run_args = param['run_args'][size]
            # for vips thread num is in IM_CONCURRENCY
            elif bench == 'vips':
                fp.write('export IM_CONCURRENCY=$1\n')
                run_args = param['run_args'][size]
            else:
                run_args = param['run_args'][size] % '$1'
            fp.write('time ./{} {}\n'.format(bench, run_args))
        os.chmod(run_sh, int('0777', 8))

        # write show.sh (show result)
        show_sh = os.path.join(test_dir, 'show.sh')
        if os.path.isfile(show_sh):
            raise Exception('show.sh already exists!')
        with open(show_sh, 'w') as fp:
            fp.write('#!/bin/bash\n')
            fp.write(param['show_res'][size] + '\n')
        os.chmod(show_sh, int('0777', 8))
