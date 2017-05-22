#delimit ;
clear all;
set memory 600m;
set more off;

*********** Change as required *******************;
* Set this to the cluster directory path, where raw corporate tree files are stored;
local dir "C:\Users\faslxkn\capiq_data_cleaner\raw_data";
local clean_dir "C:\Users\faslxkn\capiq_data_cleaner\cleaned_data";
local gic_codes "advertising trading_companies";
**************************************************;

cd "`dir'";

foreach gic_code of local gic_codes{;
	clear all;
	cd "`dir'/`gic_code'";
	local logfile 1a_append_corptree_relations.log;
	cap log close;
	cap erase `logfile';
	log using `logfile', replace;

	scalar files_read = 0;
	scalar files_import_fail = 0;
	scalar files_rename_fail = 0;

	* Create folder for cleaned data;
	cap mkdir "`clean_dir'/`gic_code'";
	if (_rc != 0) {;
		disp "Directory `gic_code' already exists in `clean_dir'";
	};


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


	save "`clean_dir'/`gic_code'/`gic_code'_append.dta", replace;

	cd "`dir'/`gic_code'";
	* Iterate over each .xls file;
	local raw_files : dir . files "*.xls";
	foreach raw_file of local raw_files {;
		disp "=========================================";
		disp "Processing `raw_file'";
		
		* Count the number of worksheets;
		qui import excel using "`dir'/`gic_code'/`raw_file'", describe;
		local sheet_count = r(N_worksheet);
		disp "`raw_file' has `sheet_count' sheets to export";
		
		* Iterate over each sheet in the rawfile;
		forval sheet_no=1/`sheet_count' {;
			disp "Importing worksheet `sheet_no'";
			qui import excel using "`dir'/`gic_code'/`raw_file'", describe;
			* Skip sheets with no data;
			local sheet_name = r(worksheet_`sheet_no');
			disp "Getting sheet `sheet_name'";
			if("`sheet_name'" == "No Data" | "`sheet_name'" == "tab") {;
				continue;
			};
			import excel using "`dir'/`gic_code'/`raw_file'", clear sheet("`sheet_name'") firstrow cellrange(A5) allstring;
			scalar firmname = CompanyName[1];

			qui drop if CompanyName == "";
			local obs_count = _N;
			disp "Importing `relation_type' file for " firmname " with `obs_count' observations";

			keep CompanyName ParentCompany UltimateCorporateParent MajorityInvestor MinorityInvestors Investorsunknownstake RelationshipType StakeType Owned Currency LTMTotalRevenuesMM LTMNetIncomeMM LFQTotalDebtMM PeriodEndDate Headquarters PrimaryIndustry;

			* Append the data into the master list of relations;
			gen QueriedCompany = CompanyName[1], before(CompanyName);
			append using "`clean_dir'/`gic_code'/`gic_code'_append.dta";
			scalar files_read = files_read + 1;
			save "`clean_dir'/`gic_code'/`gic_code'_append.dta", replace;
		};
	}; 

	use "`clean_dir'/`gic_code'/`gic_code'_append.dta", clear;
	duplicates report;
	save "`clean_dir'/`gic_code'/`gic_code'_append.dta", replace;

	export excel using "`clean_dir'/`gic_code'/`gic_code'_append.xlsx", firstrow(variables) replace;

	scalar list;

	log close;
};
