if ($1 == -help) then
	echo "COMMAND FORMAT:"
	echo "  csh getData.csh <Benchmark Name> <Test/File name>"
	echo "  Example command: csh getData 401.bzip2 case1"
else
	echo "-------------------------------------------------------"
	echo ""
	echo "### Search Parameters: ### "
	echo "     Benchmark = $1"
	echo "Test/File Name = $2"
	echo ""
        echo "### Test Statistics: ###"
	cat stat_files/$1/$2_stats.txt | grep overall_miss_rate::total
	cat stat_files/$1/$2_stats.txt | grep overall_misses::total
	cat stat_files/$1/$2_stats.txt | grep sim_insts
	echo ""
	echo "-------------------------------------------------------"
endif
