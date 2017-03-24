#delimit ;
clear all;
set memory 600m;
set more off;

*********** Change as required *******************;
* Set this to the GIC Code directory path;
local dir "C:\docs\gpn\capital iq\custsupp_universe\cleaned_data\GIC - Consumer Electronics (Primary)";
* Set this to location of GIC code master firm listings;
local master_dir "C:\docs\gpn\capital iq\custsupp_universe\dta";
**************************************************;

cd "`dir'";
local logfile 5a_merge_custsupp_ciqid.log;
cap log close;
cap erase `logfile';
log using `logfile', replace;

use "`dir'/all_relations.dta", clear;

cd "`master_dir'";

local master_files : dir . files "*.dta";

* Merge IDs for Firm;
rename Firm companyname;
foreach master_file of local master_files {;
	disp "Merging with `master_file'";
	
	merge m:m companyname using "`master_dir'/`master_file'", keepusing(excelcompanyid) update;
	drop if _m == 2;
	qui count if (excelcompanyid != "");
	disp r(N) " IDs are present";
	drop _m;
	
};
rename companyname Firm;
rename excelcompanyid FirmId;

* Merge IDs for CounterParty;
rename CounterParty companyname;
foreach master_file of local master_files {;
	disp "Merging with `master_file'";
	
	merge m:m companyname using "`master_dir'/`master_file'", keepusing(excelcompanyid) update;
	drop if _m == 2;
	qui count if (excelcompanyid != "");
	disp r(N) " IDs are present";
	drop _m;
	
};
rename companyname CounterParty;
rename excelcompanyid CounterPartyId;

order Firm FirmId ExchangeTickerSymbol CounterParty CounterPartyId Entity RelationshipType PrimaryIndustry Source BusinessDescription FileSource;
save "`dir'/all_relations_with_ciqid.dta", replace;

log close
