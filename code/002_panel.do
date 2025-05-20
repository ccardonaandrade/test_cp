	*Stata 16.0

	* Analysis for Peru
	clear all
	set more off
	
		if "`c(username)'"=="ccardonaa" {
	global home = "C:\Users\ccard\Dropbox\AidColombia"
	}
	
	***********************
	cd "$home"
	
		use muni_codes_projects, clear
	sort muni_code
	
	bys muni_code : egen first=min(initial)
	bys muni_code : egen last=max(end)
	drop initial end
	
	preserve
	keep muni_code first
	rename first year
	duplicates drop
		tempfile uno
	save `uno'
	restore
	
	
		preserve
	keep muni_code last
	rename last year
	duplicates drop
		tempfile dos
	save `dos'
	restore
	
	
	
	**** For the panel
	use muni_codes_projects, clear
	sort muni_code
	
	bys muni_code : egen first=min(initial)
	bys muni_code : egen last=max(end)
	drop initial end
	duplicates drop
	
	preserve
	keep first
	duplicates drop
	tempfile first
	save `first'
	restore
	
	preserve
	keep last
	duplicates drop
	rename last first
	append using `first'
	duplicates drop

	tempfile years
	save `years'
	restore
	
	keep muni_code
	duplicates drop
	cross using `years'
	rename first year
	
	merge 1:1 muni_code year using `uno', gen(match1)
	
	merge 1:1 muni_code year using `dos', gen(match2)
	
	gen treat=1 if match1==3
	replace treat=1 if match2==3
	replace treat=0 if year==2006 & treat==.
	replace treat=0 if year==2017 & treat==.
	replace treat=0 if treat[_n-1]==0 & treat==. & year>year[_n-1]
	replace treat=0 if treat[_n+1]==0 & treat==. & year<year[_n+1]
	replace treat=0 if treat[_n+1]==0 & treat==. & year<year[_n+1]
	replace treat=0 if treat[_n+1]==0 & treat==. & year<year[_n+1]
	replace treat=1 if treat[_n-1]==1 & treat==. & year>year[_n-1]

	keep muni_code year treat
	
	preserve
	keep muni_code
	duplicates drop
	tempfile muni
	save `muni'
	
	use gadm_with_muncodes, clear
	keep muni_code
	duplicates drop
	merge 1:1 muni_code using `muni'
	keep if _merge==1
	drop _merge
	cross using `years'
	rename first year
	tempfile rest
	save `rest'
	restore
	
	append using `rest'
	recode treat (.=0)
	save panel, replace
	
	

	
	