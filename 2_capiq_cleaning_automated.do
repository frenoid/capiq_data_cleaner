#delimit ;
clear all;
set memory 600m;
set more off;

* This file is controlled by 1_master_cleaning.do;

* Generate file-paths;
local base_dir "$base_dir_g";
local gic_code_short "$gic_code_s";
local raw_dir "`base_dir'/raw_data/`gic_code_short'";
local cleaned_dir "`base_dir'/cleaned_data/`gic_code_short'";
local firm_list "`base_dir'/dta/`gic_code_short'.dta";

cap mkdir "`cleaned_dir'";

local logfile 2_capiq_cleaning_automated.log;
cap log close;
cap erase "`raw_dir'/`logfile'";
log using "`raw_dir'/`logfile'", replace;

* Total exported file counters;
scalar customers_prior_count = 0;
scalar customers_recent_count = 0;
scalar suppliers_prior_count = 0;
scalar suppliers_recent_count = 0;

scalar corporate_tree_count = 0;

scalar files_processed = 0;
scalar files_not_processed = 0;

* Create the master list of reporting firms for later use;
use "`firm_list'", clear;

* Produce list of foldernames;
gen folder_name = "";
gen folder_name2 = "";
gen status = "Not downloaded";
local total_firms = _N;

forvalues obs_no = 1/`total_firms' {;

	scalar firmname = companyname[`obs_no'];
	disp "Firm `obs_no' Old firmname: " firmname;

	* Remove quotes and assorted symbols;
	scalar firmname = usubinstr(firmname, `"""', "", 100);
	scalar firmname = usubinstr(firmname, "~", "", 100);
	scalar firmname = usubinstr(firmname, ",", "", 100);
	scalar firmname = usubinstr(firmname, ".", "", 100);
	scalar firmname = usubinstr(firmname, "®", "", 100);
	scalar firmname = usubinstr(firmname, "|", "", 100);
	scalar firmname = usubinstr(firmname, "°", "", 100);
	scalar firmname = usubinstr(firmname, "“", "", 100);
	scalar firmname = usubinstr(firmname, "”", "", 100);
	scalar firmname = usubinstr(firmname, "³", "", 100);
	scalar firmname = usubinstr(firmname, "?", "", 100);
	scalar firmname = usubinstr(firmname, "¹", "", 100);
	scalar firmname = usubinstr(firmname, "²", "", 100);
	scalar firmname = usubinstr(firmname, "¡", "", 100);
	scalar firmname = usubinstr(firmname, "™", "", 100);
	
	* Replace whitespace, parenthesis and colons etc with underscore;
	scalar firmname = usubinstr(firmname, " ", "_", 100);
	scalar firmname = usubinstr(firmname, " ", "_", 100);
	scalar firmname = usubinstr(firmname, "­", "_", 100);
	scalar firmname = usubinstr(firmname, "*", "_", 100);
	scalar firmname = usubinstr(firmname, ":", "_", 100);
	scalar firmname = usubinstr(firmname, "(", "_", 100);
	scalar firmname = usubinstr(firmname, ")", "_", 100);
	scalar firmname = usubinstr(firmname, ">", "_", 100);
	scalar firmname = usubinstr(firmname, "\", "_", 100);
	scalar firmname = usubinstr(firmname, "/", "_", 100);
	scalar firmname = usubinstr(firmname, "-", "_", 100);
	scalar firmname = usubinstr(firmname, "–", "_", 100);
	scalar firmname = usubinstr(firmname, "·", "_", 100);
	scalar firmname = usubinstr(firmname, "’", "_", 100);
	scalar firmname = usubinstr(firmname, "«", "_", 100);
	scalar firmname = usubinstr(firmname, "»", "_", 100);
	* Removing diacritics;
	scalar firmname = usubinstr(firmname, "Æ", "AE", 100);
	scalar firmname = usubinstr(firmname, "æ", "ae", 100);
	scalar firmname = usubinstr(firmname, "Å", "A", 100);
	scalar firmname = usubinstr(firmname, "Á", "A", 100);
	scalar firmname = usubinstr(firmname, "À", "A", 100);
	scalar firmname = usubinstr(firmname, "Â", "A", 100);
	scalar firmname = usubinstr(firmname, "Ä", "A", 100);
	scalar firmname = usubinstr(firmname, "Ã", "A", 100);
	scalar firmname = usubinstr(firmname, "ä", "a", 100);
	scalar firmname = usubinstr(firmname, "å", "a", 100);
	scalar firmname = usubinstr(firmname, "á", "a", 100);
	scalar firmname = usubinstr(firmname, "à", "a", 100);
	scalar firmname = usubinstr(firmname, "ã", "a", 100);
	scalar firmname = usubinstr(firmname, "â", "a", 100);
	scalar firmname = usubinstr(firmname, "ä", "a", 100);
	scalar firmname = usubinstr(firmname, "Ð", "D", 100);
	scalar firmname = usubinstr(firmname, "É", "E", 100);
	scalar firmname = usubinstr(firmname, "È", "E", 100);
	scalar firmname = usubinstr(firmname, "Ê", "E", 100);
	scalar firmname = usubinstr(firmname, "Ë", "E", 100);
	scalar firmname = usubinstr(firmname, "Ẽ", "E", 100);
	scalar firmname = usubinstr(firmname, "é", "e", 100);
	scalar firmname = usubinstr(firmname, "è", "e", 100);
	scalar firmname = usubinstr(firmname, "ë", "e", 100);
	scalar firmname = usubinstr(firmname, "ê", "e", 100);
	scalar firmname = usubinstr(firmname, "ẽ", "e", 100);
	scalar firmname = usubinstr(firmname, "Ï", "I", 100);
	scalar firmname = usubinstr(firmname, "Í", "I", 100);
	scalar firmname = usubinstr(firmname, "î", "i", 100);
	scalar firmname = usubinstr(firmname, "í", "i", 100);
	scalar firmname = usubinstr(firmname, "ì", "i", 100);
	scalar firmname = usubinstr(firmname, "Î", "I", 100);
	scalar firmname = usubinstr(firmname, "ï", "i", 100);
	scalar firmname = usubinstr(firmname, "Ó", "O", 100);
	scalar firmname = usubinstr(firmname, "Ò", "O", 100);
	scalar firmname = usubinstr(firmname, "Ô", "O", 100);
	scalar firmname = usubinstr(firmname, "Õ", "O", 100);
	scalar firmname = usubinstr(firmname, "Ö", "O", 100);
	scalar firmname = usubinstr(firmname, "Ø", "O", 100);
	scalar firmname = usubinstr(firmname, "ó", "o", 100);
	scalar firmname = usubinstr(firmname, "ò", "o", 100);
	scalar firmname = usubinstr(firmname, "ô", "o", 100);
	scalar firmname = usubinstr(firmname, "ö", "o", 100);
	scalar firmname = usubinstr(firmname, "ø", "o", 100);
	scalar firmname = usubinstr(firmname, "õ", "o", 100);
	scalar firmname = usubinstr(firmname, "Û", "U", 100);
	scalar firmname = usubinstr(firmname, "Ù", "U", 100);
	scalar firmname = usubinstr(firmname, "Ü", "U", 100);
	scalar firmname = usubinstr(firmname, "Ú", "U", 100);
	scalar firmname = usubinstr(firmname, "ü", "u", 100);
	scalar firmname = usubinstr(firmname, "û", "u", 100);
	scalar firmname = usubinstr(firmname, "ú", "u", 100);
	scalar firmname = usubinstr(firmname, "ù", "u", 100);
	scalar firmname = usubinstr(firmname, "µ", "u", 100);
	scalar firmname = usubinstr(firmname, "š", "s", 100);
	scalar firmname = usubinstr(firmname, "š", "s", 100);
	scalar firmname = usubinstr(firmname, "§", "s", 100);
	scalar firmname = usubinstr(firmname, "Ç", "C", 100);
	scalar firmname = usubinstr(firmname, "ç", "c", 100);
	scalar firmname = usubinstr(firmname, "Ñ", "N", 100);
	scalar firmname = usubinstr(firmname, "ñ", "n", 100);
	scalar firmname = usubinstr(firmname, "ß", "ss", 100);
	scalar firmname = usubinstr(firmname, "Þ", "th", 100);
	scalar firmname = usubinstr(firmname, "ð", "th", 100);
	scalar firmname = usubinstr(firmname, "ý", "y", 100);
	scalar firmname = usubinstr(firmname, "ÿ", "y", 100);
	scalar firmname = usubinstr(firmname, "Ý", "Y", 100);
	scalar firmname = usubinstr(firmname, "Ž", "z", 100);
	scalar firmname = usubinstr(firmname, "ž", "z", 100); 
	* Remove repeated underscores;
	scalar firmname = usubinstr(firmname, "__", "_", 100);
	scalar firmname = usubinstr(firmname, "___", "_", 100);
	scalar firmname = usubinstr(firmname, "____", "_", 100);
	scalar firmname = usubinstr(firmname, "_____", "_", 100);
	scalar firmname = usubinstr(firmname, "______", "_", 100);
	scalar firmname = usubinstr(firmname, "_______", "_", 100);
	* Truncate to 50 char;
	scalar firmname = usubstr(firmname,1,50);
	qui replace folder_name2 = firmname if _n == `obs_no';
	disp "Firm `obs_no' New firmname: " firmname;
	* Remove terminating underscore;
	if(usubstr(firmname, -1, 1) == "_") {;
		scalar firmname = usubstr(firmname,1,(ustrlen(firmname)-1));
	};
	qui replace folder_name = firmname if _n == `obs_no';
	disp "Firm `obs_no' New firmname2: " firmname;
};

save "`cleaned_dir'/with_folder_names", replace;


* Clean the raw files;
cd "`raw_dir'";
local raw_files : dir . files "*.xls";

* Iterating through all .xls files in the folder;
foreach raw_file of local raw_files {;
	disp "=========================================";
	disp "Processing `raw_file'";
	qui cd "`raw_dir'";
	import excel using "`raw_file'", describe;
	local sheet_count = r(N_worksheet);
	disp "There are `sheet_count' sheets to export";

	* Iterate over each sheet in the rawfile;
	forvalues sheet=1/`sheet_count' {;

		* Skip sheets with no data;
		local sheetname = r(worksheet_`sheet');
		if("`sheetname'" == "No Data" | "`sheetname'" == "tab") {;
			continue;
		};

		* Import the sheet, first check what type of relations it contains;
		qui cd "`raw_dir'";
		import excel using "`raw_file'", clear sheet("`sheetname'");


		* Decide if this is a customer or supplier sheet;
		if(strpos(A[4],"Customers") != 0) {;
			local relation_type = "customer";
		}; else if(strpos(A[4],"Suppliers") != 0) {;
			local relation_type = "supplier";
		}; else if(strpos(A[4],"Corporate Tree") !=0) {;
			local relation_type = "corporate_tree";
		}; else {;
			disp "Relation type unknown";
			scalar files_not_processed = files_not_processed + 1;
			continue;
		};

		* Remove characters after and including > in excel cell A2;
		scalar firmname = usubstr(A[2],1,ustrpos(A[2], ">"));

		* Remove commas and stops and quotes;
		scalar firmname = usubinstr(firmname, `"""', "", 100);
		scalar firmname = usubinstr(firmname, "~", "", 100);
		scalar firmname = usubinstr(firmname, ",", "", 100);
		scalar firmname = usubinstr(firmname, ".", "", 100);
		scalar firmname = usubinstr(firmname, "®", "", 100);
		scalar firmname = usubinstr(firmname, "|", "", 100);
		scalar firmname = usubinstr(firmname, "°", "", 100);
		scalar firmname = usubinstr(firmname, "“", "", 100);
		scalar firmname = usubinstr(firmname, "”", "", 100);
		scalar firmname = usubinstr(firmname, "³", "", 100);
		scalar firmname = usubinstr(firmname, "?", "", 100);
		scalar firmname = usubinstr(firmname, "¹", "", 100);
		scalar firmname = usubinstr(firmname, "²", "", 100);
		scalar firmname = usubinstr(firmname, "¡", "", 100);
		scalar firmname = usubinstr(firmname, "™", "", 100);

		* Replace whitespace, parenthesis and colons etc with underscore;
		scalar firmname = usubinstr(firmname, " ", "_", 100);
		scalar firmname = usubinstr(firmname, " ", "_", 100);
		scalar firmname = usubinstr(firmname, "*", "_", 100);
		scalar firmname = usubinstr(firmname, ":", "_", 100);
		scalar firmname = usubinstr(firmname, "(", "_", 100);
		scalar firmname = usubinstr(firmname, ")", "_", 100);
		scalar firmname = usubinstr(firmname, ">", "_", 100);
		scalar firmname = usubinstr(firmname, "\", "_", 100);
		scalar firmname = usubinstr(firmname, "/", "_", 100);
		scalar firmname = usubinstr(firmname, "-", "_", 100);
		scalar firmname = usubinstr(firmname, "–", "_", 100);
		scalar firmname = usubinstr(firmname, "·", "_", 100);
		scalar firmname = usubinstr(firmname, "’", "_", 100);
		scalar firmname = usubinstr(firmname, "«", "_", 100);
		scalar firmname = usubinstr(firmname, "»", "_", 100);
		* Removing diacritics;
		scalar firmname = usubinstr(firmname, "Æ", "AE", 100);
		scalar firmname = usubinstr(firmname, "æ", "ae", 100);
		scalar firmname = usubinstr(firmname, "Å", "A", 100);
		scalar firmname = usubinstr(firmname, "Á", "A", 100);
		scalar firmname = usubinstr(firmname, "À", "A", 100);
		scalar firmname = usubinstr(firmname, "Â", "A", 100);
		scalar firmname = usubinstr(firmname, "Ä", "A", 100);
		scalar firmname = usubinstr(firmname, "Ã", "A", 100);
		scalar firmname = usubinstr(firmname, "ä", "a", 100);
		scalar firmname = usubinstr(firmname, "å", "a", 100);
		scalar firmname = usubinstr(firmname, "á", "a", 100);
		scalar firmname = usubinstr(firmname, "à", "a", 100);
		scalar firmname = usubinstr(firmname, "ã", "a", 100);
		scalar firmname = usubinstr(firmname, "â", "a", 100);
		scalar firmname = usubinstr(firmname, "ä", "a", 100);
		scalar firmname = usubinstr(firmname, "Ð", "D", 100);
		scalar firmname = usubinstr(firmname, "É", "E", 100);
		scalar firmname = usubinstr(firmname, "È", "E", 100);
		scalar firmname = usubinstr(firmname, "Ê", "E", 100);
		scalar firmname = usubinstr(firmname, "Ë", "E", 100);
		scalar firmname = usubinstr(firmname, "Ẽ", "E", 100);
		scalar firmname = usubinstr(firmname, "é", "e", 100);
		scalar firmname = usubinstr(firmname, "è", "e", 100);
		scalar firmname = usubinstr(firmname, "ë", "e", 100);
		scalar firmname = usubinstr(firmname, "ê", "e", 100);
		scalar firmname = usubinstr(firmname, "ẽ", "e", 100);
		scalar firmname = usubinstr(firmname, "Ï", "I", 100);
		scalar firmname = usubinstr(firmname, "Í", "I", 100);
		scalar firmname = usubinstr(firmname, "î", "i", 100);
		scalar firmname = usubinstr(firmname, "í", "i", 100);
		scalar firmname = usubinstr(firmname, "ì", "i", 100);
		scalar firmname = usubinstr(firmname, "Î", "I", 100);
		scalar firmname = usubinstr(firmname, "ï", "i", 100);
		scalar firmname = usubinstr(firmname, "Ó", "O", 100);
		scalar firmname = usubinstr(firmname, "Ò", "O", 100);
		scalar firmname = usubinstr(firmname, "Ô", "O", 100);
		scalar firmname = usubinstr(firmname, "Õ", "O", 100);
		scalar firmname = usubinstr(firmname, "Ö", "O", 100);
		scalar firmname = usubinstr(firmname, "Ø", "O", 100);
		scalar firmname = usubinstr(firmname, "ó", "o", 100);
		scalar firmname = usubinstr(firmname, "ò", "o", 100);
		scalar firmname = usubinstr(firmname, "ô", "o", 100);
		scalar firmname = usubinstr(firmname, "ö", "o", 100);
		scalar firmname = usubinstr(firmname, "ø", "o", 100);
		scalar firmname = usubinstr(firmname, "õ", "o", 100);
		scalar firmname = usubinstr(firmname, "Û", "U", 100);
		scalar firmname = usubinstr(firmname, "Ù", "U", 100);
		scalar firmname = usubinstr(firmname, "Ü", "U", 100);
		scalar firmname = usubinstr(firmname, "Ú", "U", 100);
		scalar firmname = usubinstr(firmname, "ü", "u", 100);
		scalar firmname = usubinstr(firmname, "û", "u", 100);
		scalar firmname = usubinstr(firmname, "ú", "u", 100);
		scalar firmname = usubinstr(firmname, "ù", "u", 100);
		scalar firmname = usubinstr(firmname, "µ", "u", 100);
		scalar firmname = usubinstr(firmname, "š", "s", 100);
		scalar firmname = usubinstr(firmname, "§", "s", 100);
		scalar firmname = usubinstr(firmname, "Ç", "C", 100);
		scalar firmname = usubinstr(firmname, "ç", "c", 100);
		scalar firmname = usubinstr(firmname, "Ñ", "N", 100);
		scalar firmname = usubinstr(firmname, "ñ", "n", 100);
		scalar firmname = usubinstr(firmname, "ß", "ss", 100);
		scalar firmname = usubinstr(firmname, "Þ", "th", 100);
		scalar firmname = usubinstr(firmname, "ð", "th", 100);
		scalar firmname = usubinstr(firmname, "ý", "y", 100);
		scalar firmname = usubinstr(firmname, "ÿ", "y", 100);
		scalar firmname = usubinstr(firmname, "Ý", "Y", 100);
		scalar firmname = usubinstr(firmname, "Ž", "z", 100);
		scalar firmname = usubinstr(firmname, "ž", "z", 100); 
		* Remove repeated underscores;
		scalar firmname = usubinstr(firmname, "__", "_", 100);
		scalar firmname = usubinstr(firmname, "___", "_", 100);
		scalar firmname = usubinstr(firmname, "____", "_", 100);
		scalar firmname = usubinstr(firmname, "_____", "_", 100);
		scalar firmname = usubinstr(firmname, "______", "_", 100);
		scalar firmname = usubinstr(firmname, "_______", "_", 100);
		* Truncate to 50 char;
		scalar firmname = usubstr(firmname,1,50);
		* Remove terminating underscore;
		if(usubstr(firmname, -1, 1) == "_") {;
			scalar firmname = usubstr(firmname,1,(ustrlen(firmname)-1));
		};


		* Create a directory using firmname or do nothing;
		local firm_name = firmname;

		qui cd "`cleaned_dir'";
		cap mkdir "`firm_name'";
		if (_rc == 198) {;
			disp "Folder " firmname " already exists";
		};
		if (_rc == 0) {;
			disp "Folder " firmname " was created";
		};

		qui cd "`raw_dir'";

		*** Code branches depending on what relations are in each worksheet; 
		* Dealing with a customer relation file;
		if("`relation_type'" == "customer") {;
			import excel using "`raw_file'", clear sheet("`sheetname'") firstrow cellrange(A6);


			* Get number of observations;
			qui drop if CustomerName  == "";
			local obscount = _N;
			disp "Importing" firmname " with `obscount' observations";

			drop I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX;
			drop if CustomerName == "*denotes proprietary relationship";


			* Separating prior and recent relations, then exporting them;
			forvalues rownum=1/`obscount' {;
				if CustomerName[`rownum']=="Prior and Not Recently Disclosed Customers" {;

					disp "Prior customers begins at row `rownum'";
					preserve;
					qui keep if _n<`rownum';
					if(_N > 0) {;
						disp "Exporting Recent customers for `firmname'";
						export excel using "`cleaned_dir'/`firm_name'/recent_customers.xls", replace firstrow(varlabels);
						cd ..;
						scalar customers_recent_count = customers_recent_count + 1;
					};
					restore;
					qui keep if _n> `rownum'+1;
					if(_N > 0) {;
						disp "Exporting Prior customers for `firmname'";
						export excel using "`cleaned_dir'/`firm_name'/prior_customers.xls", replace firstrow(varlabels);
						cd ..;
						scalar customers_prior_count = customers_prior_count + 1;
					};

					* Go to next sheet once separation is complete;
					continue, break;
				};	
			};

			* Dealing with a supplier relation file;
		}; else if("`relation_type'" == "supplier") {;
			import excel using "`raw_file'", clear sheet("`sheetname'") firstrow cellrange(A6);

			* Get number of observations;
			qui drop if SupplierName == "";
			local obscount = _N;
			disp "Importing `firmname' with `obscount' observations";

			drop I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX;
			drop if SupplierName == "*denotes proprietary relationship";

			* Separating prior and recent suppliers, then exporting them;
			forvalues rownum=1/`obscount' {;

				* Find the line that separates prior from recent relations;
				if SupplierName[`rownum']=="Prior and Not Recently Disclosed Suppliers" {;

					disp "Prior suppliers begin at row `rownum'";
					preserve;
					qui keep if _n < `rownum';

					if(_N > 0) {;
						disp "Exporting Recent suppliers for `firmname'";
						export excel using "`cleaned_dir'/`firm_name'/recent_suppliers.xls", replace firstrow(varlabels);
						cd ..;
						scalar suppliers_recent_count = suppliers_recent_count + 1;
					};
					restore;
					qui keep if _n> `rownum'+1;
					if(_N > 0) {;
						disp "Exporting Prior suppliers for `firmname'";
						export excel using "`cleaned_dir'/`firm_name'/prior_suppliers.xls", replace firstrow(varlabels);
						cd ..;
						scalar suppliers_prior_count = suppliers_prior_count + 1;
					};

					* Go to next sheet once separation is complete;
					continue, break;
				};
			};
		}; else if("`relation_type'" == "corporate_tree") {;
		import excel using "`raw_file'", clear sheet("`sheetname'") firstrow cellrange(A5);

		qui drop if CompanyName == "";
		local obs_count = _N;
		disp "Importing `relation_type' file for " firmname " with `obs_count' observations";

		keep CompanyName ParentCompany UltimateCorporateParent MajorityInvestor MinorityInvestors Investorsunknownstake RelationshipType StakeType Owned Currency LTMTotalRevenuesMM LTMNetIncomeMM LFQTotalDebtMM PeriodEndDate Headquarters PrimaryIndustry;

		export excel using "`cleaned_dir'/`firm_name'/corporate_tree.xls", replace firstrow(varlabels);
		cd ..;
		scalar corporate_tree_count = corporate_tree_count + 1;

		};
	};

	scalar files_processed = files_processed + 1;
	disp "+++++++++++++++++++++++++++++++++++++++++";
};
scalar list;

log close;
