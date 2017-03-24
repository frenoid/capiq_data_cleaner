#delimit ;
clear all;
set memory 600m;
set more off;

*********** Change as required *******************;
* Set this to the cluster directory path;
local dir "C:\docs\gpn\capital iq\custsupp_universe\cleaned_data\GIC - Consumer Electronics (Primary)";
* Options: "recent", "prior" or "all";
local report_time "all";
* Options: "customers", "suppliers" or "all";
local relation_type "all";
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
gen Firm = "";
label variable Firm "Full name of the firm";
gen ExchangeTickerSymbol = "";
gen CounterParty = "";
label variable CounterParty "Supplier or customer to the firm";
gen Entity = "";
label variable Entity "What kind of firm is the CounterParty";
gen RelationshipType = "";
label variable RelationshipType "How the Firm is related to the CounterParty";
gen PrimaryIndustry = "";
gen Source = "";
gen BusinessDescription = "";
gen FileSource = "";
save all_relations.dta, replace;

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

			* Variables are renamed differently depending if it's a supplier list or customer list;
			if(strpos("`firm_list'", "suppliers") != 0) {;
				disp "This is a supplier list";
				gen FileSource = "`firm_list'";
				cap rename SupplierName Firm;
				cap rename CustomerName CounterParty;
				if (_rc != 0) {;
					disp "Fail: Error in the rename process";
					scalar files_rename_fail = files_rename_fail + 1;
					continue;
				};
			}; else if(strpos("`firm_list'", "customers") != 0) {;
				disp "This is a customer list";
				gen FileSource = "`firm_list'";
				cap rename CustomerName Firm;
				cap rename SupplierName CounterParty;
				if (_rc != 0) {;
					disp "Fail: Error in the rename process";
					scalar files_rename_fail = files_rename_fail + 1;
					continue;
				};
			}; else {;
				disp "This is neither a customer nor a supplier list";
				scalar files_rename_fail = files_rename_fail + 1;
				continue;
			};

			* Append the data into the master list of relations;
			append using "`dir'/all_relations.dta";
			scalar files_read = files_read + 1;
			save "`dir'/all_relations.dta", replace;
		}; 
	}; 

use "`dir'/all_relations.dta", clear;
replace FileSource = "prior_customer" if FileSource == "prior_customers.xls";
replace FileSource = "prior_supplier" if FileSource == "prior_suppliers.xls";
replace FileSource = "recent_customer" if FileSource == "recent_customers.xls";
replace FileSource = "recent_supplier" if FileSource == "recent_suppliers.xls";
save "`dir'/all_relations.dta", replace;

duplicates drop Firm ExchangeTickerSymbol CounterParty Entity RelationshipType PrimaryIndustry Source BusinessDescription, force;

* Export only selected relations according to options chosen by testing the File Name source;

* Check for report time;
if ("`report_time'" == "prior") {;
	keep if strpos(FileSource, "prior") != 0;
}; else if ("`report_time'" == "recent") {;
	keep if strpos(FileSource, "recent") != 0;
};

* Check for relation type;
if ("`relation_type'" == "customers") {;
	keep if strpos(FileSource, "customers") != 0;
}; else if ("`relation_type'" == "suppliers") {;
	keep if strpos(FileSource, "suppliers") != 0;
};

order Firm ExchangeTickerSymbol CounterParty Entity RelationshipType PrimaryIndustry Source BusinessDescription FileSource;
export excel using "`dir'/appended_relations.xlsx", firstrow(variables) replace;

scalar list;

log close;
