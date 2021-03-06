cls
clear

/*
Formatted to 2015 variables:
	YEAR SETTYPE PATWT
	DIAG1 DIAG13D DIAG2 DIAG23D DIAG3 DIAG33D DIAG4 DIAG43D DIAG5 DIAG53D
	SEX AGE AGER RACER RACERETH RACEUN PAYTYPER REGIONOFF MSA OWNSR SPECR SPECCAT
	s_MED1-s_MED30
	ETOHAB ALZHD ARTHRTIS ASTHMA ASTH_SEV ASTH_CON AUTISM CANCER CASTAGE
	CEBVD CAD CHF CKD COPD CRF DEPRN DIABETES DIABTYP1 DIABTYP2 DIABTYP0
	ESRD HIV HPE HTN HYPLIPID IHD OBESITY OSA OSTPRSIS SUBSTAB
	NOCHRON TOTCHRON
*/

local source_case "/Volumes/GoogleDrive/My Drive/20181219_NAMCS_AtopicDermatitis/Datasets/0.2_Datasets_ADerm_ID"

*output folder where analysis Figures and Tables output will be stored
local output_dat "/Volumes/GoogleDrive/My Drive/20181219_NAMCS_AtopicDermatitis/Datasets/1.0_ADerm_Analysis"

*output folder where analysis Figures and Tables output will be stored
local output_fig "/Volumes/GoogleDrive/My Drive/20181219_NAMCS_AtopicDermatitis/Figures & Tables"

*change to output directory for all analysis
cd "`source_case'"

*load merged, clean dataset
use "namcs_2015to1995_ICD9_691.dta"


/*
Data processing
	- collapsing variables to appropriately sized categories
	- identifying outcome variables
	- saving datasets for further analysis
/

*sort on case status (cases, then controls), then by year (2015 to 1995)
gsort -CACO -YEAR

*make case id, useful for further analyses
gen ptid = _n

*indicator variable to see whether diagnosed with Diaper or napkin rash (691.0), or Other atopic dermatitis and related conditions (691.8)
gen adermcat = .
	*identify all cases
		replace adermcat = -1 if CACO == 1
	*Diaper or napkin rash (691.0)
		replace adermcat = 0 if	DIAG1 == "6910-" | DIAG2 == "6910-" | DIAG3 == "6910-" | DIAG4 == "6910-" | DIAG5 == "6910-"
	*Other atopic dermatitis and related conditions (691.8)
		replace adermcat = 8 if	DIAG1 == "6918-" | DIAG2 == "6918-" | DIAG3 == "6918-" | DIAG4 == "6918-" | DIAG5 == "6918-"
	*format
	label define adermcatf	-1 "Case that does not fit into any specific category"			///
							 0 "(691.0) Diaper or napkin rash"								///
							 8 "(691.8) Other atopic dermatitis and related conditions"
label value adermcat adermcatf

*look at how data is distributed among the subcategories of atopic derm
tab adermcat

*change to output directory for saving plots and other figures
cd "`output_fig'"

/*
*histograms showing the distributions of atopic derm by sub-disease categories

	hist AGE if CACO == 1, freq title("Any Atopic dermatitis and related conditions (691)") subtitle("n = 1,308 (100%)") ylabel(0(100)400) xlabel(0(3)18) name("AnyADerm_age", replace) 
	graph export "hist_age_AnyADerm.png", replace
	
	hist AGE if adermcat == 0, freq title("Diaper or napkin rash (691.0)") subtitle("n = 436 (33.3%)") ylabel(0(100)400) xlabel(0(3)18) name("DiaperRash_age", replace) 
	graph export "hist_age_DiaperRash.png", replace
	
	hist AGE if adermcat == 8, freq title("Other atopic dermatitis and related conditions (691.8)") subtitle("n = 872 (66.7%)") ylabel(0(100)400) xlabel(0(3)18) name("ADerm_age", replace) 
	graph export "hist_age_ADerm.png", replace
*/

*after discussion w/AB, only include Other atopic dermatitis and related conditions (691.8)

	*save variable of all 691 diagnoses (just in case)
	gen CACO_691 = CACO

	*Recode the CACO variable to only inlcude 691.8
	replace CACO = 0 if adermcat != 8

*check to ensure only 691.8 is coded as a case
tab CACO adermcat 
tab CACO


*Reformat Table 1 variables as they were in Horii 2007, 
*	while obeying Cochran's Rule (5 observations per category)


**SEX, DERIVED**

	*sex (male)
	gen sex = .
	replace sex = 0 if SEX == 1
	replace sex = 1 if SEX == 2
	label define sexf 0 "Female" 1 "Male"
	label value sex sexf
	label variable sex "Sex"
	tab sex CACO
	

**AGE CATEGORIZED, DERIVED**

	*look at age variables (AGE, AGER) in original NAMCS categories
	
	*look at histogram of age
	sum AGE, detail	
	*histogram AGE, frequency name(histogram_AGE, replace)
	sum AGE if CACO == 1, detail	
	*histogram AGE if pemphcatcol == 1, frequency name(hist_6945_AGE, replace)
		
	*Age categorized
	gen agecat = .
	replace agecat = 4 if AGE < 18
	replace agecat = 3 if AGE < 11
	replace agecat = 2 if AGE < 6
	replace agecat = 1 if AGE < 2
	replace agecat = 0 if AGE < 1
	label define agecatf	0 "0"		///
							1 "1"		///
							2 "2-5"		///
							3 "6-10"	///
							4 "11-18"
	label value agecat agecatf
	label variable agecat "Age Categorized"
	
	tab agecat
	tab agecat CACO
*	hist agecat
*	hist AGE
*	scatter AGE agecat
	
	
**RACE, DERIVED**
	
	*look at race variables (RACERF, RACERETHF, RACEUNF) in original NAMCS categories
	tab RACER
	tab RACERETH
	tab RACEUN
	
	/* look at formatting of NAMCS race variables
	
	RACER
	label define RACERF 1 "White"  
	label define RACERF 2 "Black" , add
	label define RACERF 3 "Other" , add

	RACERETH
	label define RACERETHF 1 "Non-Hispanic White"
	label define RACERETHF 2 "Non-Hispanic Black" , add
	label define RACERETHF 3 "Hispanic" , add
	label define RACERETHF 4 "Non-Hispanic Other" , add

	RACEUN
	label define RACEUNF 1 "White Only"  
	label define RACEUNF 2 "Black/African American Only" , add
	label define RACEUNF 3 "Asian Only" , add
	label define RACEUNF 4 "Native Hawaiian/Oth Pac Isl Only" , add
	label define RACEUNF 5 "American Indian/Alaska Native Only" , add
	label define RACEUNF 6 "More than one race reported" , add
	label define RACEUNF -9 "Blank" , add
	*/

	*look at RACER by RACERETH
	tab RACER RACERETH

	*Race
	gen race = -1
	*Black (non-Hispanic)
	replace race = 1 if RACEUN == 2 | RACER == 2 | RACERETH == 2
	*White (non-Hispanic)
	replace race = 4 if RACEUN == 1 | RACER == 1 | RACERETH == 1
	*Other
	replace race = 5 if RACER == 3 | RACERETH == 4 | RACEUN == 6
	*missing
	replace race = . if RACEUN == -9
	*Asian or Pacific Islander
	replace race = 2 if RACEUN == 3 | RACEUN == 4
	*American Indian/Alaska Native Only
	replace race = 3 if RACEUN == 5
	*Hispanic (Any hispanic is considered hispanic)
	replace race = 0 if	RACERETH == 3	
	label define racef	-1 "Did not fit any other category"		///
						 0 "Hispanic"							///
						 1 "Black"								///
						 2 "Asian or Pacific Islander"			///
						 3 "American Indian/Alaska Native Only"	///
						 4 "White"								///
						 5 "Other"
	label value race racef
	label variable race "Race"
	
		*make a graph of race distribution of cases
/*		graph bar (count) if CACO == 1,							///
			over(race, label(tick angle(15)))					///
			blabel(bar, format(%9.1f)) name(bar_race, replace)
*/			
		*look at race variable compared to original variables
		tab race
		tab race RACER
		
		*check to make sure there's no categories without a race grouping
		tab AGE if race == -1
	

**INSURANCE, DERIVED**	

	*look at the payment method (PAYTYPER) in original NAMCS categories
	tab PAYTYPER
	
	/* look at formatting of NAMCS PAYTYPER variable
	
	label define PAYTYPERF 1 "Private insurance"  
	label define PAYTYPERF 2 "Medicare" , add
	label define PAYTYPERF 3 "Medicaid, CHIP or other state-based program" , add
	label define PAYTYPERF 4 "Worker's compensation" , add
	label define PAYTYPERF 5 "Self-pay" , add
	label define PAYTYPERF 6 "No charge/Charity" , add
	label define PAYTYPERF 7 "Other" , add
	label define PAYTYPERF -8 "Unknown" , add
	label define PAYTYPERF -9 "All sources of payment are blank" , add	
	*/
	
	*Insurance
	gen insur = .
	*Government: Medicare, Medicaid
	replace insur = 0 if PAYTYPER == 2 | PAYTYPER == 3
	*Self-pay
	replace insur = 1 if PAYTYPER == 5
	*Other: No charge/Charity, Other, Unknown
	replace insur = 2 if PAYTYPER == 6 | PAYTYPER == 7 | PAYTYPER == -8
	*Commercial: Private Insurance, Worker's Compensation
	replace insur = 3 if PAYTYPER == 1 | PAYTYPER == 4
	*Missing
	replace insur = . if PAYTYPER == -9
		label define insurf  0 "Government" 1 "Self-pay" 2 "Other" 3 "Commercial"
		label value insur insurf
		label var insur "Payment method"
	tab insur


**REGION, DERIVED**	

	*look at region (REGIONOFF) in original NAMCS categories
	tab REGIONOFF
	
	/* look at formatting of NAMCS REGIONOFF variable

	label define REGIONF 1 "Northeast"  
	label define REGIONF 2 "Midwest" , add
	label define REGIONF 3 "South" , add
	label define REGIONF 4 "West" , add
	*/
	
	*REGIONOFF is okay; there are sufficient observations in each regional category.
	*	need to rename and relabel to make clean graph
	gen region = .
	replace region = REGIONOFF
	label define regf 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
	label value region regf
	label var region "Region where majority of physician's sampled visits occurred"
	tab region
	
**SETTING (MSA), DERIVED**

	*look at setting (MSA) in original NAMCS categories
	tab MSA

	/* look at formatting of NAMCS MSA variable
	
	label define MSAF 1 "MSA (Metropolitan Statistical Area)"
	label define MSAF 2 "Non-MSA" , add
	*/
	
	*MSA is okay; there are sufficient observations in each setting category.
	*	need to rename and relabel to make clean graph
	gen setting = .
	*Urban
	replace setting = 0 if MSA == 1
	*Nonurban
	replace setting = 1 if MSA == 2
		label define setf 0 "Urban" 1 "Nonurban"
		label value setting setf
		label var setting "Metropolitan Statistical Area - Status of physician location"
	tab setting
	
**PRACTICE (OWNSR), DERIVED**

	*look at practice (OWNSR) in original NAMCS categories
	tab OWNSR

	/* look at formatting of NAMCS OWNSR variable	

	label define OWNSRF 1 "Physician or physician group"  
	label define OWNSRF 2 "Medical/academic health center; Community health center; other hospital" , add
	label define OWNSRF 3 "Insurance company, health plan, or HMO; other health corporation; other" , add
	label define OWNSRF -6 "Refused to answer" , add
	label define OWNSRF -8 "Unknown" , add
	label define OWNSRF -9 "Blank" , add
	*/

	*practice
	gen practice = .
	*Physician Office: Physician or physician group
	replace practice = 0 if OWNSR == 1
	*Hospital: Medical/academic health center; Community health center; other hospital
	replace practice = 1 if OWNSR == 2
	*Health Corporation: Insurance company, health plan, or HMO; other health corporation; other
	replace practice = 2 if OWNSR == 3
	*Unknown or Missing
	replace practice = . if OWNSR == -9 | OWNSR == -6 | OWNSR == -8
		label define pracf 0 "Physician or physician group" 1 "Hospital or Community Health Center" 2 "Health Corporation"
		label value practice pracf
		label var practice "Who owns the practice?"
	bysort CACO: tab practice
		

**PROVIDER (SPECR), DERIVED**

	*look at provider (SPECR) in original NAMCS categories
	bysort CACO: tab SPECR

	/* look at formatting of NAMCS OWNSR variable	
	
	label define SPECRF 01 "General/family practice"  
	label define SPECRF 03 "Internal medicine" , add
	label define SPECRF 04 "Pediatrics" , add
	label define SPECRF 05 "General surgery" , add
	label define SPECRF 06 "Obstetrics and gynecology" , add
	label define SPECRF 07 "Orthopedic surgery" , add
	label define SPECRF 08 "Cardiovascular diseases" , add
	label define SPECRF 09 "Dermatology" , add
	label define SPECRF 10 "Urology" , add
	label define SPECRF 11 "Psychiatry" , add
	label define SPECRF 12 "Neurology" , add
	label define SPECRF 13 "Ophthalmology" , add
	label define SPECRF 14 "Otolaryngology" , add
	label define SPECRF 15 "Other specialties" , add
	*/
	

	*specDerm - look at dermatologists vs primary care vs all other specialists
	gen specDerm = .
	*Dermatology: Dermatology
	replace specDerm = 0 if SPECR == 9
	*Primary Care: General/family practice, Internal medicine, Pediatrics
	replace specDerm = 1 if inlist(SPECR, 1, 3, 4)
	*Other Specialist: Ophthalmology, Otolaryngology, Other specialties
	replace specDerm = 2 if inlist(SPECR, 5, 6, 7, 8, 10, 11, 12, 13, 14 ,15)
		label define specDermf	0 "Dermatology"		///
								1 "Primary Care"	///
								2 "Other Specialists"				
		label value specDerm specDermf
		label var specDerm "Physician specialty - 3 Groups"
	bysort CACO: tab SPECR specDerm
	
	*spec2 - make a dichotomous specalty variable: primary care vs specialist
	gen spec2 = .
	*primary care
	replace spec2 = 0 if specDerm == 1
	*specialist
	replace spec2 = 1 if inlist(specDerm,0,2) 
	label define spec2f 0 "Primary care" 1 "Specialist"
	label value spec2 spec2f
	label var spec2 "Was provider primary care or specialist?"
	bysort CACO: tab SPECR spec2
	
*save dataset with reformatted variables
order ptid CACO YEAR SETTYPE PATWT adermcat
sort ptid

cd "`output_dat'"

*all observations
save "namcs_2015to1995_6918_anal.dta", replace

*cases only
keep if CACO == 1
save "namcs_2015to1995_6918_anal_CasesOnly.dta", replace

/
End of Data processing
*/

*reload the entire dataset with formatted variables for further analysis
cd "`output_dat'"
use "namcs_2015to1995_6918_anal.dta


**RELABEL VARIABLES so they fit on the plots cleanly

	*redefine race so it fits in the plots
	gen racegph = race
	label define racegphf	 0 "Hispanic"			///
							 1 "Black"				///
							 2 "Asian"				///
							 3 "Native American"	///
							 4 "White"				///
							 5 "Other"
	label val racegph racegphf
	label var racegph "Race"

*sociodemographic variables
local sociodem  	sex agecat race insur region setting practice specDerm spec2
*sociodemographic variables - relabeled so graphs produced cleanly
local sociodem_gph  sex agecat racegph insur region setting practice specDerm spec2


/*Sheet 1: Case Category - all atopic derm (691) by specific disease categories
tab adermcat


*Sheet 2: Summary Stats - 691.8

*cases

	*all cases
	sum PATWT if CACO == 1
	
	*cases by SD variables
	foreach dvar in `sociodem' {
		*look at counts in each category of SD variables
		bysort `dvar':	sum PATWT if CACO == 1
	}

*controls

	*all controls
	sum PATWT if CACO != 1

	*controls by SD variables
	foreach dvar in `sociodem' {
		*look at counts in each category of SD variables
		bysort `dvar':	sum PATWT if CACO != 1
	}


*Sheet 3: Table 1 - SD - 691.8
**Total Estimated Patient Visits from 1995 to 2015**

*cases

	*all cases
	total PATWT if CACO == 1
	
	*cases by SD variables
	foreach dvar in `sociodem' {
		*look at PATWT summed in each category of SD variables
		total PATWT if CACO == 1, over(`dvar')
	}

*controls

	*all controls
	total PATWT if CACO == 0	

	*controls by SD variables
	foreach dvar in `sociodem' {
		*look at PATWT summed in each category of SD variables
		total PATWT if CACO != 1, over(`dvar')
	}

/*
Make bar graphs showing frequency counts and estimates for each sociodemographic variable for cases and controls

	- 2 plots: number of observations per estimate (by sd variable) for cases and controls
		this is important because estimates are unreliable if < 30 observations per estimate

	- 2 plots: estimates by sd variable for cases and controls
		cannot figure out how to show 95% confidence intervals; use excel or R
		
	Note: should produce 4 plots for each SD variable

*/

*change directory to folder where graphs will be saved
cd "`output_fig'"

*look at variable frequencies in pemphigoid (694.5) only
foreach dvar in `sociodem_gph' {
	
	**Cases

		*shows the number of observations per category for cases
		graph bar (count) if CACO == 1, over(`dvar', label(ticks angle(0) labsize(small)))	///
			blabel(bar, format(%9.0f))																///
			title("Frequency of Pemphigoid cases from 1995 to 2015")								///
			subtitle("≥ 30 for reliable estimates")													///
			ytitle("Number of Observations (count)")												///
			name(cnt_`dvar'_case, replace)
		*save graph
		graph export "cnt_`dvar'_case.png", replace

		*shows estimates by sociodemographic variables for cases
		graph hbar (sum) PATWT if CACO == 1, over(`dvar', label(labsize(vsmall) angle(90) ticks alternate))		///
			blabel(bar, format(%9.0fc))																			///
			title("Estimated patient visits, 1995-2015") 														///
			subtitle("Pemphigoid cases")																		///
			ylabel(0(5e6)25e6, format(%9.0fc) angle(15)) ymticks(0(5e6)25e6)									///
			ytitle("Estimated patient visits")																	///
			name(est_`dvar'_case, replace)
		*save graph
		graph export "est_`dvar'_case.png", replace

	**Controls
	
		*shows the number of observations per category for controls
		graph bar (count) if CACO != 1, over(`dvar', label(ticks angle(0) labsize(small)))		///
			blabel(bar, format(%9.0f))															///
			title("Frequency of controls from 1995 to 2015")									///
			subtitle("≥ 30 for reliable estimates")												///
			ytitle("Number of Observations (count)")											///
			name(cnt_`dvar'_ctrl, replace)
		*save graph
		graph export "cnt_`dvar'_ctrl.png", replace
	
		*shows estimates by sociodemographic variables for controls
		graph hbar (sum) PATWT if CACO != 1, over(`dvar', label(labsize(vsmall) angle(90) ticks alternate))		///
			blabel(bar, format(%9.0fc))																			///
			title("Estimated patient visits, 1995-2015") 														///
			subtitle("Controls")																				///
			ylabel(0(5e8)3.5e9, angle(15)) ymticks(0(5e8)3.5e9)													///
			ytitle("Estimated patient visits")																	///
			name(est_`dvar'_ctrl, replace)
		*save graph
		graph export "est_`dvar'_ctrl.png", replace

}

*/


*Sheet 4: Figure 1 - Visits Year
**Total estimated patient visits per year from 1995 to 2015**
*See Figure 1 (Davis 2015)

*data to be used to make a line plot in excel

*all Atopic dermatitis (691)

	*check n to ensure looking at correct group
	tab CACO_691 if CACO_691 == 1
	
	*check number of observations per year...make sure ≥ 30 to be reliable
	bysort YEAR:	sum PATWT if CACO_691 == 1

	*estimates and 95% CL per year
	total PATWT if CACO_691 == 1, over(YEAR)

*(691.8) Other atopic dermatitis and related conditions

	*check n to ensure looking at correct group
	tab CACO if CACO == 1

	*check number of observations per year...make sure ≥ 30 to be reliable
	bysort YEAR:	sum PATWT if CACO == 1

	*estimates and 95% CL per year
	total PATWT if CACO == 1, over(YEAR)

*(691.0) Diaper or napkin rash

	*check n to ensure looking at correct group
	tab CACO if adermcat == 0

	*check number of observations per year...make sure ≥ 30 to be reliable
	bysort YEAR:	sum PATWT if adermcat == 0

	*estimates and 95% CL per year
	total PATWT if adermcat == 0, over(YEAR)

	
/*
AB 20190122 

	"Horii also compared the number of visits per year and found the increase to be significant (used odds ratio)"

	See "Sheet 8" below for discussion on logistic regression in Two-Stage Cluster Sampling	
*/

svyset CPSUM [pweight=PATWT], strata(CSTRATM) singleunit(centered)
svy: logistic CACO sex AGE YEAR


/*
AB 20190122 

	"Horii compared demographics against the year groupings to see if any one demographic 
	was significantly associated with the increase in number of visits"
*/

	* categorize YEAR into 5 year blocks
	
		gen year5Cat = .
		replace year5Cat = 4 if YEAR <= 2015
		replace year5Cat = 3 if YEAR <= 2010
		replace year5Cat = 2 if YEAR <= 2005
		replace year5Cat = 1 if YEAR <= 2000
			label define year5Catf	4 "2011-2015"		///
									3 "2006-2010"		///
									2 "2001-2004"		///
									1 "1995-2000"
			label value year5Cat year5Catf
			label variable year5Cat "Year Categorized"

	*run regression assessing interaction with year5Cat

		*ixn of YEAR (as continuous measure) with age and sex, respectively
		svy: logistic CACO sex c.YEAR c.AGE c.YEAR#c.AGE
		svy: logistic CACO sex c.YEAR c.AGE c.YEAR#sex

		*ixn with agecat
		svy: logistic CACO sex i.agecat i.year5Cat i.year5Cat#i.agecat
		
		*ixn with sex
		svy: logistic CACO sex AGE i.year5Cat i.year5Cat#sex

		*assess all sociodemographics, while adjusting for sex and age
		local sociodem  	race insur region setting practice specDerm
		foreach var in `sociodem' {
			svy: logistic CACO sex AGE i.year5Cat i.`var' i.year5Cat#i.`var'
		}
		
/*
DG 20190123

	This above is all very nice, but is starting to feel like a fishing expedition.
	Start over and do a proper analysis for logistic regression:
		- Univariate
		- Multivariate with all significant univariate variables
		– Assess confounding of all significant main effects variables
		- Assess interactions
	Look at notes from 511b for details	on methods
*/
		

/*Sheet 6: Meds Table
**Most common meds prescribed from 1995 to 2015**

/* 
reshape medications prescribed data from wide to long 
Wide to Long:	https://stats.idre.ucla.edu/stata/modules/reshaping-data-wide-to-long/
Long to Wide:	https://stats.idre.ucla.edu/stata/modules/reshaping-data-long-to-wide/
*/

*load analytical wide dataset
cd "`output_dat'"
use "namcs_2015to1995_6918_anal_CasesOnly.dta", clear
total  PATWT

*generate indicator variable for (691.8) Other atopic dermatitis and related conditions 	

	*ANY:	691.8 in any of the 5 diagnosis positions
	gen diag_6918_Any5 = . 
	replace diag_6918_Any5 = 1 if DIAG1 == "6918-" | DIAG2 == "6918-" | DIAG3 == "6918-" | DIAG4 == "6918-" | DIAG5 == "6918-"
	*check to see how many have any
	tab diag_6918_Any5

	*ONLY:	691.8 in first diagnosis position only
	gen diag_6918_Only1 = .
	replace diag_6918_Only1 = 1 if DIAG1 == "6918-" & DIAG2 == "" & DIAG3 == "" & DIAG4 == "" & DIAG5 == ""
	*check to see how many have only 1
	tab diag_6918_Only1

	*save dataset with these indicator variables (will use in comorbidities)
	save "namcs_2015to1995_6918_anal_CasesOnly_AnyOnly.dta", replace
	
*reshape to long data to get all medication names
reshape long s_MED, i(ptid) j(medid) 

*encode s_MED to factor (c_MED)
*	https://www.stata.com/support/faqs/data-management/encoding-string-variable/
encode s_MED, gen(c_MED)
*drop string MEDS
drop s_MED

*move variables ptid, medid, and c_MED to beginning of dataset for easy viewing
order ptid medid c_MED

*look at most common meds by frequency of occurrence in data (unweighted)
tab c_MED, sort


**make variable showing number of times drug appears in dataset
	
	*uniqueMED indicator variable if first time drug name (c_MED) appears in data set
	by c_MED, sort: gen uniqueMED = _n == 1
	*count number of unique meds among cases
	count if uniqueMED
	
	*countMED is number of times drug appears in data set
	sort c_MED
	by c_MED: gen countMED = _N
	
	*order for easy viewing
	order ptid medid c_MED countMED

*this lists summary stats for drugs that appear 20 times or more in NAMCS
*	use this as a list of drug names to consider

	*ANY: diagnosis in any position
	tab c_MED if countMED >= 20 & diag_6918_Any5 == 1
	
	*ONLY: diagnosis in first position, with no other diagnoses
	tab c_MED if countMED >= 20 & diag_6918_Only1 == 1

	*use this to get variable codes of the drugs in the above list
	*label list c_MED

	*save long dataset before returning to wide
	save "namcs_2015to1995_6918_anal_LongMeds.dta", replace
	
*return data to wide format

	*drop any unique variables before returning to long dataset (will cause errors otherwise)
	drop uniqueMED countMED
	
	*reshape to long data to get indicator variables for all possible meds
	reshape wide c_MED, i(ptid) j(medid) 


/*	ANY 691.8 in any diagnosis position: 
	ALBUTEROL (12)			AMOXICILLIN (23)		ATARAX (32)						BENADRYL (49)
	CETAPHIL (77)			DESONIDE (116)			DTAP (133)						ELIDEL (141)
	ELIDEL CREAM (142)		ELOCON (144)			EPIPEN (149)					EUCERIN (156)
	HYDROCORTISONE (188)	HYDROXYZINE (191)		INFLUENZA VIRUS VACC (200)		PROTOPIC (318)
	SINGULAIR (348)			TRIAMCINOLONE (381)		TRIAMCINOLONE ACETONIDE (382)	TYLENOL (390)
	WESTCORT (409)			ZYRTEC (416)
*/
	*local macro containing all of the above drugs
	local medANY	12	23	32	49	77	116	133	141	142	144	149	156	188	191	200	318	348	381	382	390	409	416

	*this is the denominator for total number of visits for patients diagnosed with atopic derm (691.8)
	total PATWT if CACO == 1 & diag_6918_Any5 == 1

	foreach med in `medANY' {

	*get visit estimate for the top drugs
	total  PATWT if diag_6918_Any5 == 1 &																			///
				  inlist(`med', c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
								c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
								c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	di "	med `med'"
	}


/*	ONLY 691.8 in First Position:

All drugs in the above ANY list, except DTAP (133)
*/
local medONLY	12	23	32	49	77	116		141	142	144	149	156	188	191	200	318	348	381	382	390	409	416

*this is the denominator for total number of visits for patients diagnosed with atopic derm (691.8)
total PATWT if CACO == 1 & diag_6918_Only1 == 1

foreach med in `medONLY' {

*get visit estimate for the top drugs
total  PATWT if diag_6918_Only1 == 1 &																			///
			  inlist(`med', c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
							c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
							c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
di "	med `med'"
}


/* 	Recategorize drugs that had multiple names after speaking with dermatologists:
	
	– Prescription drugs:
		Amoxicillin (23)	Hydroxyzine (32, 191)	Desonide (116)	Pimecrolimus (141, 142)
		Mometasone furoate (144)	Tacrolimus (318)	Triamcinalone (381, 382)
	
	– Over the counter drugs:
		Cetaphil (77)	Eucerin (156)	Hydrocortisone (188, 409)	Certirizine (416)

*/

* prescription drug indicator variables

	gen				drugRx1 = .
	replace 		drugRx1 = 1 if inlist(23, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugRx1f	1 "Amoxicillin"
	label value 	drugRx1 drugRx1f
	label variable drugRx1 "Amoxicillin"

	gen				drugRx2 = .
	replace 		drugRx2 = 1 if inlist(32, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	replace 		drugRx2 = 1 if inlist(191, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugRx2f	1 "Hydroxyzine"
	label value 	drugRx2 drugRx2f
	label variable drugRx2 "Hydroxyzine"


	gen				drugRx3 = .
	replace 		drugRx3 = 1 if inlist(116, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugRx3f	1 "Desonide"
	label value 	drugRx3 drugRx3f
	label variable drugRx3 "Desonide"


	gen				drugRx4 = .
	replace 		drugRx4 = 1 if inlist(141, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	replace 		drugRx4 = 1 if inlist(142, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugRx4f	1 "Pimecrolimus"
	label value 	drugRx4 drugRx4f
	label variable drugRx4 "Pimecrolimus"


	gen				drugRx5 = .
	replace 		drugRx5 = 1 if inlist(144, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugRx5f	1 "Mometasone furoate"
	label value 	drugRx5 drugRx5f
	label variable drugRx5 "Mometasone furoate"


	gen				drugRx6 = .
	replace 		drugRx6 = 1 if inlist(318, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugRx6f	1 "Tacrolimus"
	label value 	drugRx6 drugRx6f
	label variable drugRx6 "Tacrolimus"


	gen				drugRx7 = .
	replace 		drugRx7 = 1 if inlist(381, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	replace 		drugRx7 = 1 if inlist(382, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugRx7f	1 "Triamcinolone"
	label value 	drugRx7 drugRx7f
	label variable drugRx7 "Triamcinolone"

*macro of all prescription drug variables
local drugPres drugRx1 drugRx2 drugRx3 drugRx4 drugRx5 drugRx6 drugRx7

foreach drug in `drugPres' {

	* Rx drugs for ANY atopic dermatitis
	tab `drug' if diag_6918_Any5 == 1
	total  PATWT if diag_6918_Any5 == 1 & `drug' == 1

	* Rx drugs for ONLY atopic dermatitis
	tab `drug' if diag_6918_Only1 == 1
	total  PATWT if diag_6918_Only1 == 1 & `drug' == 1

}


* over the counter drug indicator variables

	gen				drugOTC1 = .
	replace 		drugOTC1 = 1 if inlist(77, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugOTC1f	1 "Cetaphil"
	label value 	drugOTC1 drugOTC1f
	label variable 	drugOTC1 "Cetaphil"

	gen				drugOTC2 = .
	replace 		drugOTC2 = 1 if inlist(156, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugOTC2f	1 "Eucerin"
	label value 	drugOTC2 drugOTC2f
	label variable 	drugOTC2 "Eucerin"


	gen				drugOTC3 = .
	replace 		drugOTC3 = 1 if inlist(188, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	replace 		drugOTC3 = 1 if inlist(409, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugOTC3f	1 "Hydrocortisone"
	label value 	drugOTC3 drugOTC3f
	label variable 	drugOTC3 "Hydrocortisone"


	gen				drugOTC4 = .
	replace 		drugOTC4 = 1 if inlist(416, 	c_MED1,	c_MED2, c_MED3, c_MED4, c_MED5, c_MED6, c_MED7, c_MED8, c_MED9, c_MED10,	///
												c_MED11,c_MED12,c_MED13,c_MED14,c_MED15,c_MED16,c_MED17,c_MED18,c_MED19,c_MED20,	///
												c_MED20,c_MED21,c_MED23,c_MED24,c_MED25,c_MED26,c_MED27,c_MED28,c_MED29,c_MED30)
	label define 	drugOTC4f	1 "Cetirizine"
	label value 	drugOTC4 drugOTC4f
	label variable 	drugOTC4 "Cetirizine"


*macro of all prescription drug variables
local drugOver drugOTC1 drugOTC2 drugOTC3 drugOTC4

foreach drug in `drugOver' {

	* Rx drugs for ANY atopic dermatitis
	tab `drug' if diag_6918_Any5 == 1
	total  PATWT if diag_6918_Any5 == 1 & `drug' == 1

	* Rx drugs for ONLY atopic dermatitis
	tab `drug' if diag_6918_Only1 == 1
	total  PATWT if diag_6918_Only1 == 1 & `drug' == 1

}



*Sheet 7: Comorbidities Table
**Most common comorbidities from 1995 to 2015**

/* 
reshape diagnosis data from wide to long 
https://stats.idre.ucla.edu/stata/modules/reshaping-data-wide-to-long/
*/

*load original wide dataset
cd "`output_dat'"
use "namcs_2015to1995_6918_anal_CasesOnly_AnyOnly.dta", clear

*drop the 3-digit diagnosis codes because they're less specific and redundant
drop DIAG13D DIAG23D DIAG33D DIAG43D DIAG53D

*reshape to long data to get all diagnoses names
reshape long DIAG, i(ptid) j(dxid) 

*there are blank diagnosis codes as 00000 for years 2006 and before
tab YEAR if DIAG == "00000"
	*replace them as missing
	replace DIAG = "" if DIAG == "00000"

*encode DIAG to factor (c_DIAG)
*	https://www.stata.com/support/faqs/data-management/encoding-string-variable/
encode DIAG, gen(c_DIAG)
*drop string DIAG
drop DIAG

*move variables ptid, medid, and c_DIAG to beginning of dataset for easy viewing
order ptid dxid c_DIAG

*look at most common meds by frequency of occurrence in data (unweighted)
tab c_DIAG, sort

**make variable showing number of times diagnosis appears in dataset
	
	*uniqueDIAG indicator variable if first time diagnosis code (c_DIAG) appears in data set
	by c_DIAG, sort: gen uniqueDIAG = _n == 1
	*count number of unique diagnosis among cases
	count if uniqueDIAG
	
	*countDIAG is number of times diagnosis appears in data set
	sort c_DIAG
	by c_DIAG: gen countDIAG = _N
	
	*order for easy viewing
	order ptid dxid c_DIAG countDIAG

*this lists summary stats for diagnoses that appears 10 times or more in NAMCS
*	use this as a list of drug names to consider

	*This is the percentage of diagnoses that were for 691.8 only
	tab c_DIAG if diag_6918_Only1 == 1

	*ANY: diagnosis in any position
	tab c_DIAG if countDIAG >= 10 & diag_6918_Any5 == 1
	
	*use this to get variable codes of the drugs in the above list
	*label list c_DIAG

	*save long dataset before returning to wide
	save "namcs_2015to1995_6918_anal_LongDiag.dta", replace

*return data to wide format

	*drop any unique variables before returning to long dataset (will cause errors otherwise)
	drop uniqueDIAG countDIAG
	
	*reshape to long data to get indicator variables for all possible meds
	reshape wide c_DIAG, i(ptid) j(dxid) 

/*	ANY 691.8 in any diagnosis position: 
	0780- (8)		3829- (59)		4659- (69)		4720- (71)		4770- (74)		4779- (77)	
	49300 (83)		49390 (89)		684-- (112)		6918-  (120)	6929- (125)		6931- (126)	
	7061- (142)		7862- (184)		9957- (200)		V202- (219)		V6759 (226)
*/
	*local macro containing all of the above drugs
	local diagANY	8	59	69	71	74	77	83	89	112	120	125	126	142	184	200	219	226

	*this is the denominator for total number of visits for patients diagnosed with atopic derm (691.8)
	total PATWT if CACO == 1 & diag_6918_Any5 == 1
	
	*This is the percentage of diagnoses that were for 691.8 only
	total PATWT if diag_6918_Only1 == 1

	foreach diag in `diagANY' {

	*get visit estimate for the top drugs
	total  PATWT if diag_6918_Any5 == 1 &																			///
				  inlist(`diag', c_DIAG1,	c_DIAG2, c_DIAG3, c_DIAG4, c_DIAG5)
	di "	diag `diag'"
	}

	
	
*Sheet 8: Table 2 - SD ORs

/*
Notes for running logistics in NAMCS

	*what is 2-stage cluster sampling?
	https://stats.stackexchange.com/questions/202305/stratified-cluster-and-two-stage-cluster-sampling

	*preparation for survey sampled logistic regression
	*	https://stats.idre.ucla.edu/stata/faq/how-do-i-use-the-stata-survey-svy-commands/
	
	*redistribute singletons to other years using the "singleunit(centered)"
	*	https://stats.stackexchange.com/questions/120772/dealing-with-singleton-strata-in-survey-analysis

	svyset CPSUM [pweight=PATWT], strata(CSTRATM) singleunit(centered)

	*actually run the regression
	svy: logistic y x1 x2 x3

*/

*use wide analytical dataset for logistic regression analysis
cd "`output_dat'"
use "namcs_2015to1995_6918_anal.dta", clear

*	this macro is up above, just after the data processing step, right before "Sheet 1"

local sociodem		sex agecat race insur region setting practice specDerm


*preparation for survey sampled logistic regression
svyset CPSUM [pweight=PATWT], strata(CSTRATM) singleunit(centered)

foreach univar in `sociodem' {

	*look at CACO by sociodemographic variable
	tab CACO `univar'
	
}

*actually run the regression, with appropriate reference groups
svy: logistic CACO i.sex
svy: logistic CACO ib4.agecat
svy: logistic CACO ib4.race
svy: logistic CACO ib3.insur
svy: logistic CACO ib2.region
svy: logistic CACO ib1.setting
svy: logistic CACO ib1.practice
svy: logistic CACO ib1.specDerm

*look at all other sociodemographic variabels after adjusting for sex and age
svy: logistic CACO sex AGE ib4.race
svy: logistic CACO sex AGE ib3.insur
svy: logistic CACO sex AGE ib2.region
svy: logistic CACO sex AGE ib1.setting
svy: logistic CACO sex AGE ib1.practice
svy: logistic CACO sex AGE ib1.specDerm

*how to see where the errors are from
*	https://www.statalist.org/forums/forum/general-stata-discussion/general/1375170-survey-analysis-error-with-single-stratum
*svydes
