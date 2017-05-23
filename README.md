# capiq_data_cleaner
A set of STATA scripts which reshapes excel files from Capital IQ into a directory structure organized by company names and also native STATA formats.

Files
=====
1) 0_create_download_lists.do
Given raw_files from Capital IQ containing a firm's Name, CIQ ID and Primary Industry, this produces a .xls which can be used with
capiq_report.py to download relations data from Capital IQ

2) 1_master_cleaning.do
This file supervises the cleaning of buyer-supplier data downloaded from Capital IQ. It requires the user the specify the dir where raw
files are kept and a list of gic_folders. It controls 2 other files: 2_capiq_cleaning_automated.do and 3_capiq_create_master_list.do

3) 1a_append_corptree_relations.do
This file appends downloaded corporate tree relations downloaded from the Report Builder and exports them in .dta format and .xls format.
It requires the user to input the base dir where raw files are stored and the names of each gic folder

4) 2_capiq_cleaning_automated.do
This file reads in individual .xls files downloaded for buyer-supplier relations, creates a folder for each firm, and exports the data in
.xls files into these firm folders. The script is controlled by 1_master_cleaning.do

5) 2a_merge_corptree_ciqid.do
This file merges in CIQ IDs into the appended Corporate Tree data. It requires that a .dta file containing lists of firms and their CIQ IDs
be provided. 

6) 3_capiq_create_master_list.do
This file looks at the firms reporting buyer-supplier data by looking at what firm folders were creating, then it creates a master list of 
these firms by matching them back to the list used to compile CIQ IDs for downloads. The master list is exported in .xls format.

7) 4_append_custsupp_relations.do
This file appends together all buyer-supplier relations in a single GIC code. It is possible to specify whether you want only recent or prior
relations, and whether you want only customer or supplier data. The data is exported in .xls format

8) 5_merge_custsupp_ciqid.do
This file uses the GIC code master tables and merges in CIQ IDs into the customer and supplier listings. It requires the user to point to
a directory containing master of list of firms in each GIC code.

9) screening_data_clean_and_append.do
This file cleans the data extracted from the Company Screening function in Capital IQ. It requires the user to point to the dir containing
the rawfiles. It assumes all 157 GIC codes are present and exports the data for each GIC code in .dta and .xls format


