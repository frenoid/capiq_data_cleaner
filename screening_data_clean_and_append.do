#delimit ;
set more off;
set mem 600m;
local num "4";
local dir "C:\Users\faslxkn\capiq_crawler\mass_`num'";
local final_dir "C:\Users\faslxkn\Documents\Capital IQ\mass\mass_`num'";

cd "`dir'";

local logfile "mass_`num'_append.log";
log close _all;
cap erase `logfile';
log using `logfile';

scalar folders_processed = 0;
scalar files_processed = 0;

* Ensure that the clean directory exists;
cap mkdir "C:\Users\faslxkn\Documents\Capital IQ\mass\mass_`num'/clean_data";

* Create the template file form the first file in Advertising;
import excel using "`dir'/raw_data/Advertising/Advertising_1_of_4.xls", clear cellrange(A8) case(preserve) allstring;
cap drop IndustryClassifications;
drop if _n > 0;
save "`dir'/mass_`num'_template.dta", replace;

* Cleaning and appending the raw data;
cd "`dir'/raw_data";
local raw_folders : dir . dirs "*";
foreach raw_folder of local raw_folders {;
	local gic_code = "GIC - `raw_folder'";
	disp "Processing `gic_code'";
	
	copy "`dir'/mass_`num'_template.dta" "`final_dir'/clean_data/`gic_code'.dta", replace;
	disp "`gic_code'.dta created";
	
	cd "`dir'/raw_data/`raw_folder'";
	local raw_files : dir . files "*.xls";
	disp "Importing .xls files for `raw_folder'";
	local file_no = 0;
	foreach raw_file of local raw_files {;
		local ++file_no;
		disp "Getting file `file_no' `raw_file'";
		import excel using "`raw_file'", clear cellrange(A8) firstrow case(preserve) allstring;
		
		* Remove non-primary firms according to GIC classification;
		cap drop if strpos(IndustryClassifications, "Primary")== 0;
		cap drop IndustryClassifications;
		
		append using "`final_dir'/clean_data/`gic_code'.dta";
		save "`final_dir'/clean_data/`gic_code'.dta", replace;
		scalar files_processed = files_processed + 1;
	};
	scalar folders_processed = folders_processed + 1;
	
	* Remove variables which are completely blank;
	foreach vari of varlist * {;
		if("`vari" == "CompanyName") {;
			continue;
		};
		
		local content = `vari'[1];
		if(`"`content'"' == "") {;
			drop `vari';
			disp "`vari' was dropped";
		};
	};
	sort CompanyName;
	compress;
	save "`final_dir'/clean_data/`gic_code'.dta", replace;
	export excel using "`final_dir'/clean_data/`gic_code'.xlsx", firstrow(varlabels) replace;
};



scalar list;
log close;
