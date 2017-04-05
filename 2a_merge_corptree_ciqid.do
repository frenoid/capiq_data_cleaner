#delimit ;
clear all;
set memory 600m;
set more off;

*********** Change as required *******************;
* Set this to the GIC Code directory path;
local dir "C:\docs\gpn\capital iq\custsupp_universe\cleaned_data\consumer_electronics";
* Set this to the master GIC code dir;
local master_dir "C:\docs\gpn\capital iq\custsupp_universe\dta";
* Set this to the GIC code master firm listings;
local master_list "C:\docs\gpn\capital iq\custsupp_universe\dta\consumer_electronics.dta";
**************************************************;

cd "`dir'";
local logfile 5a_merge_corptree_ciqid.log;
cap log close;
cap erase `logfile';
log using `logfile', replace;

use "`dir'/all_corptree_relations.dta";
local firm_names "QueriedCompany";

cd "`master_dir'";
local master_files : dir . files "*.dta";
* Merge CIQ IDs by matching the following firm name variables;
foreach firm_name of local firm_names {;
	disp "Merging IDs to `firm_name'";
	rename `firm_name' companyname;
	
	foreach master_file of local master_files {;
	    disp "Merging with `master_file'";
		merge m:m companyname using "`master_dir'/`master_file'", keepusing(excelcompanyid) update;
		drop if _m == 2;
		qui count if (excelcompanyid != "");
		disp r(N) " `firm_name' IDs are matched";
		drop _m;
	};
	
	rename companyname `firm_name';
	local firm_name_id = "`firm_name'" + "Id";
	rename excelcompanyid `firm_name_id';
};

duplicates drop;
order QueriedCompany QueriedCompanyId CompanyName ParentCompany UltimateCorporateParent MajorityInvestor MinorityInvestors Investorsunknownstake RelationshipType StakeType Owned Currency LTMTotalRevenuesMM LTMNetIncomeMM LFQTotalDebtMM PeriodEndDate Headquarters PrimaryIndustry Minorityinvestor;

foreach vari of varlist * {;
	replace `vari' = "" if `vari' == "-";
};


save "`dir'/all_corptree_relations_with_ciqid.dta", replace;

* Study the merge rates;
use "`dir'/all_corptree_relations_with_ciqid.dta", clear;
preserve;



foreach firm_name of local firm_names {;
	local firm_name_id "`firm_name'Id";
	qui count if `firm_name_id' != "";
	
	* Merge rates for all relations;
	local total_no = _N;
	disp "Merge results for `firm_name'";
	disp "[Merged number / Total] (% Merged)";
	disp "[" r(N) " / `total_no'] (" r(N)/`total_no'*100 ")"; 
	
	* Merge rates for distinct entries;
	duplicates drop QueriedCompany, force;
	local total_no = _N;
	qui count if `firm_name_id' != "";
	disp "Merge results for `firm_name'";
	disp "[Merged number / Total] (% Merged)";
	disp "[" r(N) " / `total_no'] (" r(N)/`total_no'*100 ")"; 
};
restore;
log close
