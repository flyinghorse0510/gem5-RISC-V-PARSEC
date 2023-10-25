
parsec_param = {}
# each parsecm benchmark parameter has the following fields
# dir: directory where the benchmark source resides
# run_args: arguments to run (for different input size); %s should be replaced
# by thread num
# show_res: command to show the results (for different input size)

parsec_param['blackscholes'] = {
    'dir': 'pkgs/apps',
    'run_args': {
        'simdev'   : '%s in_16.txt  /tmp/out.txt',
        'simsmall' : '%s in_4K.txt  /tmp/out.txt',
        'simmedium': '%s in_16K.txt /tmp/out.txt',
        'simlarge' : '%s in_64K.txt /tmp/out.txt',
        'native'   : '%s in_10M.txt /tmp/out.txt',
    },
    'show_res': {
        'simdev'   : 'wc -l /tmp/out.txt; head /tmp/out.txt; tail /tmp/out.txt',
        'simsmall' : 'wc -l /tmp/out.txt; head /tmp/out.txt; tail /tmp/out.txt',
        'simmedium': 'wc -l /tmp/out.txt; head /tmp/out.txt; tail /tmp/out.txt',
        'simlarge' : 'wc -l /tmp/out.txt; head /tmp/out.txt; tail /tmp/out.txt',
        'native'   : 'wc -l /tmp/out.txt; head /tmp/out.txt; tail /tmp/out.txt',
    },
}

parsec_param['dedup'] = {
    'dir': 'pkgs/kernels',
    'run_args': {
        'simdev'   : '-t %s -i media.dat -o /tmp/out.txt',
        'simsmall' : '-t %s -i media.dat -o /tmp/out.txt',
        'simmedium': '-t %s -i media.dat -o /tmp/out.txt',
        'simlarge' : '-t %s -i media.dat -o /tmp/out.txt',
        'native'   : '-t %s -i media.dat -o /tmp/out.txt',
    },
    'show_res': {
        'simdev'   : '',
        'simsmall' : '',
        'simmedium': '',
        'simlarge' : '',
        'native'   : '',
    },
}

parsec_param['streamcluster'] = {
    'dir': 'pkgs/kernels',
    'run_args': {
        'simdev'   : '3  10 3   16      16     10   none /tmp/out.txt %s',
        'simsmall' : '10 20 32  4096    4096   1000 none /tmp/out.txt %s',
        'simmedium': '10 20 64  8192    8192   1000 none /tmp/out.txt %s',
        'simlarge' : '10 20 128 16384   16384  1000 none /tmp/out.txt %s',
        'native'   : '10 20 128 1000000 200000 5000 none /tmp/out.txt %s',
    },
    'show_res': {
        'simdev'   : 'wc -l /tmp/out.txt; cat /tmp/out.txt',
        'simsmall' : 'wc -l /tmp/out.txt; cat /tmp/out.txt',
        'simmedium': 'wc -l /tmp/out.txt; cat /tmp/out.txt',
        'simlarge' : 'wc -l /tmp/out.txt; cat /tmp/out.txt',
        'native'   : 'wc -l /tmp/out.txt; cat /tmp/out.txt',
    },
}

parsec_param['fluidanimate'] = {
    'dir': 'pkgs/apps',
    'run_args': {
        'simdev'   : '%s 3   in_15K.fluid  /tmp/out.fluid',
        'simsmall' : '%s 5   in_35K.fluid  /tmp/out.fluid',
        'simmedium': '%s 5   in_100K.fluid /tmp/out.fluid',
        'simlarge' : '%s 5   in_300K.fluid /tmp/out.fluid',
        'native'   : '%s 500 in_500K.fluid /tmp/out.fluid',
    },
    'show_res': {
        'simdev'   : 'du -sh /tmp/out.fluid',
        'simsmall' : 'du -sh /tmp/out.fluid',
        'simmedium': 'du -sh /tmp/out.fluid',
        'simlarge' : 'du -sh /tmp/out.fluid',
        'native'   : 'du -sh /tmp/out.fluid',
    },
}

parsec_param['swaptions'] = {
    'dir': 'pkgs/apps',
    'run_args': {
        'simdev'   : '-ns 16  -sm 50      -nt %s', # change 3 to 16, enable 8 threads
        'simsmall' : '-ns 16  -sm 10000   -nt %s',
        'simmedium': '-ns 32  -sm 20000   -nt %s',
        'simlarge' : '-ns 64  -sm 40000   -nt %s',
        'native'   : '-ns 128 -sm 1000000 -nt %s',
    },
    'show_res': {
        'simdev'   : '',
        'simsmall' : '',
        'simmedium': '',
        'simlarge' : '',
        'native'   : '',
    },
}

parsec_param['freqmine'] = {
    'dir': 'pkgs/apps',
    'run_args': {
        'simdev'    : 'T10I4D100K_1k.dat  3' ,
        'simsmall'  : 'kosarak_250k.dat 220' ,
        'simmedium' : 'kosarak_500k.dat 410' ,
        'simlarge'  : 'kosarak_990k.dat 790' ,
        'native'    : 'webdocs_250k.dat 11000',
    },
    'show_res': {
        'simdev'   : '',
        'simsmall' : '',
        'simmedium': '',
        'simlarge' : '',
        'native'   : '',
    },
}

parsec_param['facesim'] = {
    'dir': 'pkgs/apps',
    'run_args': {
        # all input sizes are the same except for native
        'simdev'    : '-timing -threads %s',
        'simsmall'  : '-timing -threads %s',
        'simmedium' : '-timing -threads %s',
        'simlarge'  : '-timing -threads %s',
        'native'    : '-timing -threads %s -lastframe 100',
    },
    'show_res': {
        'simdev'   : 'ls /tmp/Storytelling/output',
        'simsmall' : 'ls /tmp/Storytelling/output',
        'simmedium': 'ls /tmp/Storytelling/output',
        'simlarge' : 'ls /tmp/Storytelling/output',
        'native'   : 'ls /tmp/Storytelling/output',
    },
}

parsec_param['ferret'] = {
    'dir': 'pkgs/apps',
    'run_args': {
        'simdev'    : 'corel lsh queries 5   5 %s /tmp/out.txt',
        'simsmall'  : 'corel lsh queries 10 20 %s /tmp/out.txt',
        'simmedium' : 'corel lsh queries 10 20 %s /tmp/out.txt',
        'simlarge'  : 'corel lsh queries 10 20 %s /tmp/out.txt',
        'native'    : 'corel lsh queries 50 20 %s /tmp/out.txt',
    },
    'show_res': {
        'simdev'   : 'cat /tmp/out.txt',
        'simsmall' : 'cat /tmp/out.txt',
        'simmedium': 'cat /tmp/out.txt',
        'simlarge' : 'cat /tmp/out.txt',
        'native'   : 'wc -l /tmp/out.txt; head /tmp/out.txt; tail /tmp/out.txt',
    },
}

parsec_param['canneal'] = {
    'dir': 'pkgs/kernels',
    'run_args': {
        'simdev'   : '%s 100   300  100.nets    2',
        'simsmall' : '%s 10000 2000 100000.nets 32',
        'simmedium': '%s 15000 2000 200000.nets 64',
        'simlarge' : '%s 15000 2000 400000.nets 128',
    },
    'show_res': {
        'simdev'   : '',
        'simsmall' : '',
        'simmedium': '',
        'simlarge' : '',
    },
}

parsec_param['bodytrack'] = {
    'dir': 'pkgs/apps',
    'run_args': {
        # we use posix thread model (input arg = 2)
        'simdev'    : 'sequenceB_1 4 1 100  3 2 %s',
        'simsmall'  : 'sequenceB_1 4 1 1000 5 2 %s',
        'simmedium' : 'sequenceB_2 4 2 2000 5 2 %s',
        'simlarge'  : 'sequenceB_4 4 4 4000 5 2 %s',
    },
    'show_res': {
        'simdev'   : '',
        'simsmall' : '',
        'simmedium': '',
        'simlarge' : '',
    },
}

parsec_param['raytrace'] = {
    'dir': 'pkgs/apps',
    'run_args': {
        'simdev': 'bunny.obj -automove -nthreads %s -frames 1 -res 16 16',
        'simsmall': 'happy_buddha.obj -automove -nthreads %s -frames 3 -res 480 270',
        'simmedium': 'happy_buddha.obj -automove -nthreads %s -frames 3 -res 960 540',
        'simlarge': 'happy_buddha.obj -automove -nthreads %s -frames 3 -res 1920 1080',
        'native': 'thai_statue.obj -automove -nthreads %s -frames 200 -res 1920 1080',
    },
    'show_res': {
        'simdev'   : '',
        'simsmall' : '',
        'simmedium': '',
        'simlarge' : '',
        'native'   : '',
    }
}

parsec_param['vips'] = {
    'dir': 'pkgs/apps',
    'run_args': {
        'simdev'   : 'im_benchmark barbados_256x288.v /tmp/output.v',
        'simsmall' : 'im_benchmark pomegranate_1600x1200.v /tmp/output.v',
        'simmedium': 'im_benchmark vulture_2336x2336.v /tmp/output.v',
        'simlarge' : 'im_benchmark bigben_2662x5500.v /tmp/output.v',
        'native'   : 'im_benchmark orion_18000x18000.v /tmp/output.v',
    },
    'show_res': {
        'simdev'   : 'ls /tmp/output.v',
        'simsmall' : 'ls /tmp/output.v',
        'simmedium': 'ls /tmp/output.v',
        'simlarge' : 'ls /tmp/output.v',
        'native'   : 'ls /tmp/output.v',
    }
}

parsec_param['x264'] = {
    'dir': 'pkgs/apps',
    'run_args': {
        'simdev'   : '--quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads %s -o /tmp/eledream.264 eledream_64x36_3.y4m',
        'simsmall' : '--quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads %s -o /tmp/eledream.264 eledream_640x360_8.y4m',
        'simmedium': '--quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads %s -o /tmp/eledream.264 eledream_640x360_32.y4m',
        'simlarge' : '--quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads %s -o /tmp/eledream.264 eledream_640x360_128.y4m',
        'native'   : '--quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads %s -o /tmp/eledream.264 eledream_1920x1080_512.y4m',
    },
    'show_res': {
        'simdev'   : 'ls /tmp/eledream.264',
        'simsmall' : 'ls /tmp/eledream.264',
        'simmedium': 'ls /tmp/eledream.264',
        'simlarge' : 'ls /tmp/eledream.264',
        'native'   : 'ls /tmp/eledream.264',
    }

}