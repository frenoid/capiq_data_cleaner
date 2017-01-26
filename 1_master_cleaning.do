#delimit ;
clear all;
set mem 600m;
set more off;

* set base_dir to the location of cleaning scripts, global since subsequent scripts use it;
* set gic_codes_short to a list of shortened_gic_code_names;
global base_dir_g "C:\docs\gpn\capital iq\custsupp_universe";
local gic_codes_short "agricultural_and_farm_machinery";

global codes_processed = 0;

foreach gic_code_short of local gic_codes_short {;
	cd "$base_dir_g";
	
	* Use a global vairable to pass the shortened GIC code to other do-files;
	global gic_code_s = "`gic_code_short'";
	do "$base_dir_g/2_capiq_cleaning_automated.do";
	do "$base_dir_g/3_capiq_create_master_list.do";
	global codes_processed = $codes_processed + 1;
};

di "$codes_processed GIC codes were successfully processed.";
di "`gic_codes_short'";

