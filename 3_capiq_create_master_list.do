#delimit ;
clear all;
set memory 600m;
set more off;

* This file is controlled by 1_master_cleaning.do;

* Generate file-paths;
local base_dir "$base_dir_g";
local gic_code_short "$gic_code_s";
local cleaned_dir "`base_dir'\cleaned_data/`gic_code_short'";

cd "`cleaned_dir'";
local logfile 3_capiq_create_master_list.log;
cap log close;
cap erase "`cleaned_dir'/`logfile'";
log using "`cleaned_dir'/`logfile'", replace;

use "`cleaned_dir'/with_folder_names", replace;

local total_firms = _N;
forval firm_no = 1/`total_firms' {;
	local firm_folder = folder_name[`firm_no'];
	local firm_folder2 = folder_name2[`firm_no'];
	cd "`cleaned_data'";
	
	cap cd "`cleaned_dir'/`firm_folder'";
	if (_rc == 0) {;
		disp "`firm_folder' exists";
		qui replace status = "Downloaded" if _n == `firm_no';
	}; else {;
		cap cd "`cleaned_dir'/`firm_folder2'";
		if (_rc == 0) {;
			disp "`firm_folder2 exits'";
			qui replace status = "Downloaded" if _n == `firm_no';
		}; else {;
			disp "`firm_folder' & `firm_folder2' not found";
		};
	};
	
};

tab status;

keep if status == "Downloaded";
cd "`cleaned_data'";
save "master_list", replace;

* Export the master_list into the cleaned_data folder;
drop exchangeticker primarysector primaryindustry folder_name2 status;
order companyname excelcompanyid folder_name industryclassifications siccodesprimary siccodesprimarycodeonly siccodes geographiclocations geographicregion headquarterscountry primaryaddress suppliers customers;
label variable excelcompanyid "Capital IQ ID";
label variable folder_name "Firm folder";
label variable industryclassifications "GIC Codes";

export excel using "`cleaned_dir'/master_$gic_code_s.xls", sheet("Master list") firstrow(varlabels) replace;
erase "`cleaned_dir'/with_folder_names.dta";

log close;
