#!/bin/csh

setenv PATH /util/gcc/bin:$PATH
setenv LD_LIBRARY_PATH /util/gcc/lib64:$LD_LIBRARY_PATH

set GEM5_DIR="/util/gem5"
set GEM5="$GEM5_DIR/build/X86/gem5.opt"
set GEM5_SE="$GEM5_DIR/configs/example/se.py"

set ans
set TEST_PARAMS=""

foreach i ( $* )
    if ("$i" == "-h" || "$i" == "--help") then
        echo "-------------------------------------------------------"
        echo ""
        echo "COMMAND FORMAT:"
        echo "  gemTest.csh <benchmark name> <output name> <L1D Size> <L1I Size> <L2 Size> <L1D Assoc> <L1I Assoc> <L2 Assoc> <Block Size>"
        echo "  NOTE: Cache sizes MUST end with 'kB'\!\!\! For example: 4kB"
        echo "  Example Command: gemTest.csh 401.bzip2 case1 1kB 1kB 1kB 1 1 1 16"
        echo ""
        echo "SIZE RESTRICTIONS:"
        echo "  L1D Size: 1kB to 65536kB"
        echo "  L1I Size: 1kB to 65536kB"
        echo "  L2 Size: 1kB to 65536kB"
        echo "  L3 Size: 1kB to 65536kB"
        echo "  Block Size: Must be 16, 32, 64, or 128"
        echo ""
        echo "AVAILIBLE BENCHMARKS:"
        echo "  401.bzip2"
        echo "  429.mcf"
        echo "  456.hmmer"
        echo "  458.sjeng"
        echo "  470.lbm"
        echo ""
        echo "OPTIONS:"
        echo "  -h or --help: Prints this help message."
        echo ""
        echo "-------------------------------------------------------"
        exit
    endif
end

if ($# != 9) then
    echo "-------------------------------------------------------"
    echo ""
    echo "ERROR: Invalid number of parameters!"
    echo "Use 'gemTest.csh -h' to see the format for this script's parameters."
    echo ""
    echo "-------------------------------------------------------"
    exit
endif

if (-e stat_files/$1/$2_stats.txt) then
    echo -n "WARNING\! Do you want to OVERWRITE an existing file? [y/n]: "
    set ans = $<
    if ($ans != "y") then
	echo "Aborting operation!"
        exit
    endif
endif

set test_valid = "false"

if ($1 == "401.bzip2") then
    set TEST_PARAMS='/util/gem5/benchmark/401.bzip2/data/input.program 10'
    set test_valid = "true"
endif

if ($1 == "429.mcf") then
    set TEST_PARAMS='/util/gem5/benchmark/429.mcf/data/inp.in'
    set test_valid = "true"
endif

if ($1 == "456.hmmer") then
    set TEST_PARAMS='--fixed 0 --mean 325 --num 45000 --sd 200 --seed 0 /util/gem5/benchmark/456.hmmer/data/bombesin.hmm.new'
    set test_valid = "true"
endif

if ($1 == "458.sjeng") then
    set TEST_PARAMS='/util/gem5/benchmark/458.sjeng/data/test.txt'
    set test_valid = "true"
endif

if ($1 == "470.lbm") then
    set TEST_PARAMS='20 reference.dat 0 1 /util/gem5/benchmark/470.lbm/data/100_100_130_cf_a.of'
    set test_valid = "true"
endif

if ($test_valid == "true") then
    $GEM5 -d stat_files/$1 --stats-file=$2_stats.txt $GEM5_SE -c /util/gem5/benchmark/$1/src/benchmark -o "$TEST_PARAMS" -I 10000000 --l1d_size=$3 --l1i_size=$4 --l2_size=$5 --l1d_assoc=$6 --l1i_assoc=$7 --l2_assoc=$8 --cacheline_size=$9 --caches --l2cache
    if ($?) then
	echo "-------------------------------------------------------"
	echo ""
	echo "ERROR: Gem5 failed execution! See above error messages!"
	echo ""
	echo "-------------------------------------------------------"
	exit
    else
	echo "-------------------------------------------------------"
	echo ""
	echo "### Test Parameters: ### "
	echo "            Benchmark = $1"
	echo "          Output Name = $2"
	echo "   L1 Data Cache Size = $3"
	echo " L1 Instrn Cache Size = $4"
	echo "        L2 Cache Size = $5" 
	echo "  L1 Data Cache Assoc = $6"
	echo "L1 Instrn Cache Assoc = $7"
	echo "       L2 Cache Assoc = $8"
	echo "           Block Size = $9"
	echo ""
	echo "### Test Statistics: ###"
	cat stat_files/$1/$2_stats.txt | grep overall_miss_rate::total
	cat stat_files/$1/$2_stats.txt | grep overall_misses::total
	cat stat_files/$1/$2_stats.txt | grep sim_insts
	rm stat_files/$1/config.ini
	rm stat_files/$1/config.json
	echo ""
	echo "-------------------------------------------------------"
    endif
else
    echo "-------------------------------------------------------"
    echo ""
    echo "ERROR: Invalid benchmark!"
    echo "Use 'gemTest.csh -h' for a list of vaild benchmarks."
    echo ""
    echo "-------------------------------------------------------"
endif
