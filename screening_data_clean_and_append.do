#delimit ;
set more off;
set mem 600m;
local num "3";
local dir "C:\docs\gpn\capital iq\info_extraction\mass_`num'";

cd "`dir'";

local logfile "mass_`num'_append.log";
log close _all;
cap erase `logfile';
log using `logfile';

scalar folders_processed = 0;
scalar files_processed = 0;

* Ensure that the clean directory exists;
cap mkdir "`dir'/clean_data";
if(_rc != 0) {;
	disp "``dir'/clean_data' already exists";
};

* Create the template file from the first file in Advertising;
* Template file has the same variables but has no observations;
import excel using "`dir'/raw_data/Advertising/Advertising_1_of_4.xls", clear cellrange(A8) case(preserve) allstring;
cap drop IndustryClassifications;
drop if _n > 0;
save "`dir'/mass_`num'_template.dta", replace;

* Iterating over each GIC code;
* Each folder contains files for one GIC code;
cd "`dir'/raw_data";
local raw_folders : dir . dirs "*";
foreach raw_folder of local raw_folders {;
	local gic_code = "GIC - `raw_folder'";
	disp "Processing `gic_code'";
	
	* Copy the template file over and rename to prep for appending;
	copy "`dir'/mass_`num'_template.dta" "`dir'/clean_data/`gic_code'.dta", replace;
	disp "`gic_code'.dta created";
	
	* Iterating over .xls files for each GIC code; 
	cd "`dir'/raw_data/`raw_folder'";
	local raw_files : dir . files "*.xls";
	disp "Importing .xls files for `raw_folder'";
	local file_no = 0;
	foreach raw_file of local raw_files {;
		local ++file_no;
		disp "Getting file `file_no' `raw_file'";
		import excel using "`raw_file'", clear cellrange(A8) firstrow case(preserve) allstring;
		
		* Remove non-primary firms according to GIC classification;
		* Then drop IndustryClassifications itself'
		cap drop if strpos(IndustryClassifications, "Primary")== 0;
		cap drop IndustryClassifications;
		
		* Append them to the template file, then save it;
		append using "`dir'/clean_data/`gic_code'.dta";
		save "`dir'/clean_data/`gic_code'.dta", replace;
		scalar files_processed = files_processed + 1;
	};
	
	* Remove variables which are completely blank;
	foreach vari of varlist * {;
		if("`vari" == "CompanyName") {;
			continue;
		};
		
		* Missing values in Capital IQ are marked as "-";
		* Columns with empty values are "";
		local content = `vari'[1];
		if(`"`content'"' == "") {;
			drop `vari';
			disp "`vari' was dropped";
		};
	};
	
	* Sort by company name, A - Z;
	* Produce a .dta copy and a .xlsx copy;
	sort CompanyName;
	compress;
	save "`dir'/clean_data/`gic_code'.dta", replace;
	export excel using "`dir'/clean_data/`gic_code'.xlsx", firstrow(varlabels) replace;
	scalar folders_processed = folders_processed + 1;
};

scalar list;
log close;
