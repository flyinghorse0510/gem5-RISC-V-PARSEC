# 1 Setup
```bash
./configure
```

# 2 Usage
```bash
# Change BENCHMARKS, SIMSIZES, BENCHMARKS_OUT in env.sh accordingly
source env.sh
./get-inputs
build
```

Copy benchmark outputs to disk image, see [Benchmark Guide](https://github.com/ppeetteerrs/gem5-RISC-V-FS-Linux/blob/main/Benchmark%20Guide.md).

Inside the disk image, navigate to the benchmark's directory and run `./run.sh <N>` where `<N>` is the number of threads to run on. By default, m5 stats within the ROI will be dumped to `<gem5_logs>/stats.txt` each time a benchmark is run.

**Note**: If you are using WSL, you might need to modify `env.sh` to manually set `xxPARSECDIRxx` to your parsec directory.

**Note**: Currently, `./bin/benchmarks.py` sets the output directory to `/tmp`. If desired, change it to a permanent location but remember to configure bootargs to be read-write, such as `--command-line="console=ttyS0 root=/dev/vda rw"`, when running gem5 RISC-V FS. There are also some benchmarks that directly writes to the input file (e.g. freqmine). In that case, either boot with a read-write filesystem as mentioned or move the input file to `/tmp` and modify `run.sh` accordingly.

# 3 Benchmark Status
| benchmark     | compilation | run | error                         |
| ------------- | ----------- | --- | ----------------------------- |
| blackscholes  | ✅           | ✅   |                                            |
| bodytrack     | ✅           | ✅   |                                            |
| canneal       | ✅           | ✅   |                                            |
| dedup         | ✅           | ✅   |                                            |
| facesim       | ✅           | ❌   | segmentation fault                         |
| ferret        | ✅           | ❌   | error in findBasicVariables                |
| fluidanimate  | ✅           | ✅   |                                            |
| freqmine      | ✅           | ✅   |                                            |
| raytrace      | ❌           | ❌   | known to fail (relies on Mesa)             |
| streamcluster | ✅           | ✅   |                                            |
| swaptions     | ✅           | ✅   |                                            |
| vips          | ❌           | ❌   | known to fail (cross-compile glib missing) |
| x264          | ✅           | ❌   | segmentation fault                         |

# 4 Changes Made
## 4.1 Build Configurations
By default, `./bin/build` uses ``gcc-hooks.bldconf` to dump m5 stats. To use `gcc.bldconf`, just remove the `-c gcc-hooks` option.

- `gcc.bldconf`: Set up binary home directory and compilation and linker flags.
- `gcc-hooks.bldconf`: Add m5 library to compiler and linker flags (include m5 header and m5 pseudo-instructions static library).
- `env.sh`: Set up host and target information (editing it will mess up paths and compilation, do it with caution)

## 4.2 Helper Scripts
- `./bin/build`: One command build script
- `./bin/gen.py`: Copy data and benchmark scripts and generate run commands
- `./bin/benchmarks.py`: Benchmark information

## 4.3 Other Changes
- PARSEC hooks are linked to m5 instructions in `pkgs/libs/hooks/src/hooks.c`
- RISC-V atomic instructions are added to canneal via `pkgs/kernels/canneal/src/atomic/atomic.h` and `pkgs/kernels/canneal/src/atomic/riscv/atomic.h`.
