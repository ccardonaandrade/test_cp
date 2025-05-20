	*Stata 16.0

	* Analysis for Peru
	clear all
	set more off
	
		if "`c(username)'"=="ccardonaa" {
	global home = "C:\Users\ccard\Dropbox\AidColombia"
	}
	
	***********************
	cd "$home"
	insheet using "$home\data\projects.csv", comma
	keep project_id transactions_start_year transactions_end_year
	tempfile years
	save `years'

	* For now I need the location
	insheet using "$home\data\locations.csv", comma clear
	keep project_id latitude longitude
	* There are 28 projects without coordinates
	merge m:1 project_id using `years', keep(match) nogen
	egen cell=group(latitude longitude)
	sort cell
	bys cell: egen initial=min(transactions_start_year)
	bys cell: egen end=max(transactions_end_year)
	
	* Just need the locations
	keep latitude longitude initial end cell project_id
	
	merge m:1 cell using muni_codes_projects.dta
	