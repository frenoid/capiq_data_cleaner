#delimit ;
clear all;
set memory 600m;
set more off;

*********** Change as required *******************;
* Set this to the cluster directory path;
local dir "C:\docs\gpn\capital iq\custsupp_universe\cleaned_data\consumer_electronics";
**************************************************;

cd "`dir'";
local logfile 4a_append_custsupp_relations.log;
cap log close;
cap erase `logfile';
log using `logfile', replace;

scalar folders_read = 0;
scalar folders_not_read = 0;
scalar files_read = 0;
scalar files_import_fail = 0;
scalar files_rename_fail = 0;


* Format of the master list of relations;
gen QueriedCompany = "";
la var QueriedCompany "Company that was queried from Capital IQ";
gen CompanyName = "";
gen ParentCompany = "";
gen UltimateCorporateParent = "";
gen MajorityInvestor = "";
gen Minorityinvestor = "";
gen Investorsunknownstake = "";
gen RelationshipType = "";
gen StakeType = "";
gen Owned = "";
gen Currency = "";
gen LTMTotalRevenuesMM = "";
gen LTMNetIncomeMM = "";
gen LFQTotalDebtMM = "";
gen PeriodEndDate = "";
gen Headquarters = "";
gen PrimaryIndustry = "";

save all_corptree_relations.dta, replace;

	cd "`dir'";
	* Iterate over each firm folder;
	local folders : dir . dirs "*";
	foreach folder of local folders {;
		cap cd "`dir'/`code_folder'/`folder'"; 
		* When the folder opening fails;
		if (_rc != 0) {;
			disp "Fail: Folder `dir'/`folder' could not be opened, next folder";
			scalar folders_not_read = folders_not_read + 1;
			continue;
		};

		* Where the folder was correctly opened;
		scalar folders_read = folders_read + 1;
		local firm_lists : dir . files "*.xls";
		foreach firm_list of local firm_lists {;

			cap import excel using "`dir'/`code_folder'/`folder'/`firm_list'", firstrow allstring clear;

			* If import unsuccessful, next file;
			if(_rc == 601) {;
				disp "Import fail: `firm_list' not found, next file";
				scalar files_import_fail = files_import_fail + 1;
				continue;
			}; else if (_rc != 0) {;
				disp "Import fail: other error, error code below";
				scalar files_import_fail = files_import_fail + 1;
					disp _rc;
				continue;
			};

			disp "`firm_list' was succesfully imported";

			* Testing if the Corporate Tree is correctly formatted;
			if(strpos("`firm_list'", "corporate_tree") != 0) {;
				local obs_count = _N;
				disp "Valid Corporate Tree file with `obs_count' observations" ;
			}; else {;
				disp "Invalid Corporate Tree file";
				scalar files_rename_fail = files_rename_fail + 1;
				continue;
			};

			* Append the data into the master list of relations;
			gen QueriedCompany = CompanyName[1], before(CompanyName);
			append using "`dir'/all_corptree_relations.dta";
			scalar files_read = files_read + 1;
			save "`dir'/all_corptree_relations.dta", replace;
		}; 
	}; 

use "`dir'/all_corptree_relations.dta", clear;
duplicates report;
save "`dir'/all_corptree_relations.dta", replace;

export excel using "`dir'/all_corptree_relations.xlsx", firstrow(variables) replace;

scalar list;

log close;
