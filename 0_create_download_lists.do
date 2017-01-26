#delimit ;
clear all;
set mem 600m;
set more off;

* Change these 3 lines;
local dir "C:\docs\gpn\capital iq\custsupp_universe";
local selenium_dir "C:\Selenium\capitaliq\firm_lists";
local gic_codes "computer_and_electronics_retail home_improvement_retail specialty_stores automotive_retail home_furnishing_retail";

cd "`dir'";
local logfile 0_create_download_lists.log;
cap log close;
cap erase `logfile';
log using `logfile', replace;

scalar download_lists_exported = 0;

* Import the first file;
foreach gic_code of local gic_codes {;
	import excel using "`dir'/firm_lists/gic_pri_`gic_code'.xls", cellrange(A8) firstrow case(lower) clear;
	foreach myvar of varlist * {;
		replace `myvar' = "" if `myvar' == "-";
	};
	save "`dir'/dta/`gic_code'", replace;
};


* Append subsequent files, if they exist;
foreach gic_code of local gic_codes {;
	* Iterate over file to 100;
	forval num=1/100 {;
		disp "Importing gic_pri_`gic_code'_`num'.xls";
		cap import excel using "`dir'/firm_lists/gic_pri_`gic_code'_`num'.xls", cellrange(A8) firstrow case(lower) clear;
		* Move to next gic code if subsequent files do not exist;
		if(_rc == 601) {;
			disp "gic_pri_`gic_code'_`num'.xls does not exist. Next GIC code";
			continue, break;
		};
		foreach myvar of varlist * {;
			replace `myvar' = "" if `myvar' == "-";
		};
		append using "`dir'/dta/`gic_code'";
		duplicates drop excelcompanyid, force;
		compress;
		save "`dir'/dta/`gic_code'", replace;
	};
};

* Export the download lists for use in capiq_report.py;
* Make a copy in the selenium directory for later downloading;
foreach gic_code of local gic_codes {;

	use "`dir'/dta/`gic_code'", clear;
	gen has_info = "N";
	replace has_info = "Y" if customers != "" | suppliers != "";
	
	keep companyname excelcompanyid industryclassifications has_info;
	gen batch_no = .;
	gen customers_done = "";
	gen suppliers_done = "";
	sort excelcompanyid;
	gen num = _n, before(companyname);
	replace batch_no = ceil(num/150);
	
	export excel using "`dir'/download_lists/`gic_code'.xlsx", sheet("Download list") firstrow(variables) replace;
	copy "`dir'/download_lists/`gic_code'.xlsx" "`selenium_dir'/`gic_code'.xlsx";
	scalar download_lists_exported = download_lists_exported + 1;
};
scalar list;

log close;
