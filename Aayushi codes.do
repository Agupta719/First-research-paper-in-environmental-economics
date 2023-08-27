clear
set more off

capture log close

cd "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/Stata/

set type double

log using "Aayushi codes.log", replace

ssc install ivreg2
ssc install asdoc

                             **************************************************
                             ****************Cleaning & Merging****************
                             **************************************************
							 
**************************************************
********************HDI index*********************
**************************************************

*import HDI index dataset
import delimited "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/HDI Index/HDR21-22_Composite_indices_complete_time_series.csv", clear 

keep iso3 country hdicode region hdi_201*
drop region
rename iso3 countryCode

*transpose of Total variable
gen hdi = "hdi"
encode hdi, gen (HDI)
// label list Class
drop hdi
reshape long hdi_, i(country HDI) j(Year)
reshape wide hdi_, i(country Year) j(HDI)
rename hdi_1 HDI

*correct country names to merge datasets
replace country = "Korea" if country == "Korea (Republic of)"

save HDI, replace

**************************************************
*******************PM2.5 dataset******************
**************************************************
ssc install nrow

*import PM 2.5 dataset
import excel "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/PM 2.5 data/data.xlsx", sheet("Export") firstrow clear
drop in 3

*checking if all categories have 5 years
local i = 1
foreach var of varlist * {
	if `var' != Indicator{
		   di `i' " " `var'[1]
		   local i=`i'+1
	}
	if `i' == 6{
		local i= 1
	}
}

*For Total variable
nrow
rename _* Total_*
keep Period Total_*
drop in 1

*transpose of Total variable
gen total = "Total_PM25"
encode total, gen (total_pm25)
// label list Class
drop total
reshape long Total_, i(Period total_pm25) j(Year)
reshape wide Total_, i(Period Year) j(total_pm25)
rename Total_ Total_PM25
rename Period country

*correct country names to merge datasets
replace country = "Korea" if country == "Republic of Korea"
replace country = "United States" if country == "United States of America"
replace country = "United Kingdom" if country == ///
"United Kingdom of Great Britain and Northern Ireland"
replace country = "Turkey" if country == "Türkiye"

save PM25, replace

*merging the two datasets
merge 1:1 country Year using HDI

*removing special characteristics and destring Total_PM25
replace country = regexr(country, "\((.)+\)", "")
foreach var in Total_PM25 {
	replace `var' = regexr(`var', "\[(.)+\]", "")
	gen PM25 = real(`var')
}
drop if PM25 == . & HDI == .
drop Total_PM25

drop if _m !=3
drop _m
order PM25, after(HDI)
order Year, last

label var HDI "Human Development Index"
label var PM25 "Annual mean value of PM 2.5"

*replace country names after merging
replace country = "Bolivia" if country == "Bolivia "
replace country = "Iran" if country == "Iran "
replace country = "Syria" if country == ///
"Syrian Arab Republic"
replace country = "Venezuela" if country == "Venezuela "

save HDI_PM25, replace

**************************************************
********************FIFA dataset******************
**************************************************

*import fifa dataset
import delimited "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/FIFA/fifa_ranking-2022-10-06.csv", clear 

drop confederation previous_points rank_change total_points

sort country_full rank_date

//destring date variable and keep only year above 2010
generate date =  date(rank_date, "YMD")
format date %td
gen month=month(date)
gen Year=year(date)
keep if month == 12
drop rank_date month date
drop if Year <2010

rename country_full country
rename country_abrv countryCode
rename rank fifa_rank

//Note: using england as a substitution for UK
replace country = "United Kingdom" if country == "England"
replace country = "China" if country == "China PR"
replace country = "Czechia" if country == "Czech Republic"
replace country = "Iran" if country == "IR Iran"
replace country = "Korea" if country == "Korea Republic"
replace country = "United States" if country == "USA"
replace country = "Viet nam" if country == "Vietnam"

merge 1:1 country Year using HDI_PM25
sort country Year
// drop if _m !=3
drop _m

order fifa_rank, after(countryCode)

save HDI_PM25_fifa, replace


**************************************************
********************PISA dataset******************
**************************************************
//
// *import PISA scores
// import excel "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/PISA score.xlsx", sheet("Report 1- Table") cellrange(B10:T128) firstrow clear
//
// ds
// drop D-Q S T
// rename R pisa
// rename C country
// drop in 1/2
// drop if country == ""
//
// *destring year variables by generating new year variables
// foreach item in B{
// //  di `item'
// 	gen Year = real(`item')
//	
// }
//
// drop B
// gen id = _n
// replace Year = 2018 if id < 38
// replace Year = 2015 if id >= 38 & id < 75
// replace Year = 2012 if id >= 75
// drop id
//
// *destring PISA variables by generating new year variables
// foreach item in pisa{
// //  di `item'
// 	gen PISA = real(`item')
//	
// }
// drop pisa
//
// *correct country names to merge datasets
// replace country = "Czechia" if country == "Czech Republic"
// replace country = "Slovakia" if country == "Slovak Republic"
//
// save PISA, replace
//
// *merging the PISA and HDI_PM25 datasets
// merge 1:1 country Year using HDI_PM25
// sort country
//
// drop if _m != 3
// drop _m
//
// *correct country names to merge the following datasets
// // replace country = "Bolivia" if country == "Bolivia "
// // replace country = "Iran" if country == "Iran "
// // replace country = "Micronesia" if country == "Micronesia "
// // replace country = "Lao PDR" if country = "Lao People's Democratic Republic"
// // replace country = "Venezuela" if country == "Venezuela "
// // replace country = "Vietnam" if country == "Viet Nam"
//
//
// save PISA_HDI_PM25, replace

**************************************************
****************Pop_growth dataset****************
**************************************************

// *import Pop_growth rate 
// import excel "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/Pop_growth rate/P_Data_Extract_From_World_Development_Indicators.xlsx", sheet("Data") firstrow clear
//
// drop SeriesCode YR1990
// rename CountryName country
//
// *destring year variables by generating new year variables
// foreach item of varlist YR2010-YR2021{
// //  di `item'
// 	gen Year = real(`item')
// 	rename Year Year`item'
// 	drop `item'
// }
//
// *transposing dataset
// encode SeriesName, gen (Class)
// // label list Class
// drop SeriesName
// drop if country == ""
//
// reshape long YearYR, i(country Class) j(Year)
// reshape wide YearYR, i(country Year) j(Class) 
//
// rename YearYR3 Pop_growth
//
// *correct country names to merge datasets
// // replace country = "Bahamas" if country == "Bahamas, The"
// // replace country = "Congo" if country == "Congo, Dem. Rep."
// // replace country = "Egypt" if country == "Egypt, Arab Rep."
// // replace country = "Gambia" if country == "Gambia, The"
// // replace country = "Iran" if country == "Iran, Islamic Rep."
// replace country = "Korea" if country == "Korea, Rep."
// // replace country = "Kyrgyzstan" if country == "Kyrgyz Republic"
// // replace country = "Micronesia" if country == "Micronesia, Fed. Sts."
// // replace country = "Saint Vincent and the Grenadines" if country == "St. Kitts and Nevis"
// replace country = "Slovakia" if country == "Slovak Republic"
// replace country = "Turkey" if country == "Turkiye"
// // replace country = "Venezuela" if country == "Venezuela, RB"
// // replace country = "Yemen" if country == "Yemen, Rep."
//
// save Pop_growth, replace
//
// *merging the Pop_growth and PISA_HDI_PM25 datasets
// merge 1:1 country Year using PISA_HDI_PM25
// sort country
//
// drop if _m != 3
// drop _m
//
// save Pop_PISA_HDI_PM25, replace

**************************************************
*****************Industrial prod******************
**************************************************

*import industrial production dataset
import delimited "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/Industrial production/P_Data_Extract_From_World_Development_Indicators/9bb29545-7f04-4731-833e-3f846831dbd2_Data.csv", clear 

*destring year variables by generating new year variables
local mcode 2010
foreach item of varlist v5-v16{
    di `item'[1]
	gen Year = real(`item')
	rename Year YR_`mcode'
	local mcode = `mcode' + 1
	drop `item'
}

drop v2
rename v3 country
rename v4 countryCode
// rename _* YR_*

*transposing dataset
encode v1, gen (indusProd)
// label list Class
drop v1
drop if country == ""

reshape long YR_, i(country indusProd) j(Year)
reshape wide YR_, i(country Year) j(indusProd) 
drop YR_4
rename YR_2 indusProd

*merging the datasets
merge 1:1 country Year using HDI_PM25_fifa
sort country Year
drop _m

save HDI_PM25_fifa_indus, replace

**************************************************
*******************PM2.5 dataset******************
**************************************************
// ssc install nrow
//
// *import PM 2.5 dataset
// import excel "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/PM 2.5 data/data.xlsx", sheet("Export") firstrow clear
// drop in 3
//
// *checking if all categories have 5 years
// local i = 1
// foreach var of varlist * {
// 	if `var' != Indicator{
// 		   di `i' " " `var'[1]
// 		   local i=`i'+1
// 	}
// 	if `i' == 6{
// 		local i= 1
// 	}
// }
//
// *For Total variable
// nrow
// rename _* Total_*
// keep Period Total_*
// drop in 1
//
// *transpose of Total variable
// gen total = "Total_PM25"
// encode total, gen (total_pm25)
// // label list Class
// drop total
// reshape long Total_, i(Period total_pm25) j(Year)
// reshape wide Total_, i(Period Year) j(total_pm25)
// rename Total_ Total_PM25
// rename Period country
//
// *correct country names to merge datasets
// replace country = "Korea" if country == "Republic of Korea"
// replace country = "United States" if country == "United States of America"
// replace country = "United Kingdom" if country == ///
// "United Kingdom of Great Britain and Northern Ireland"
// replace country = "Turkey" if country == "Türkiye"
//
// *removing special characteristics and destring Total_PM25
// replace country = regexr(country, "\((.)+\)", "")
// foreach var in Total_PM25 {
// 	replace `var' = regexr(`var', "\[(.)+\]", "")
// 	gen PM25 = real(`var')
// }
//
// save PM25, replace
//
// *merging the two datasets
// merge 1:1 country Year using Indus_Pop_PISA_HDI
//
// drop if Year != 2012 & Year != 2013 & Year != 2015 & Year != 2016 & Year != 2018 & Year != 2019
// drop if country == "" 
// drop in 37/42
// sort country

*creating lagged variable

*********

// drop if PM25 == . & HDI == .
// drop Total_PM25
//
// drop if _m !=3
// drop _m
// order PM25, after(HDI)
// order Year, last
//
// label var HDI "Human Development Index"
// label var PM25 "Annual mean value of PM 2.5"

// save Indus_Pop_PISA_HDI_PM25, replace

**************************************************
********************Employment dataset******************
**************************************************

// *import employment
// import delimited "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/Employment/DP_LIVE_05122022052333309.csv", clear 
//
// drop subject indicator frequency flagcodes measure
// rename value emp
// rename location CountryCode
// rename time Year
//
//
// *merging the datasets
// merge 1:1 countryCode Year using HDI_PM25_fifa_indus
// tab country if _m == 2
// sort country
//
// drop if _m == 1
// drop _m
// order country

**************************************************
********************Migration dataset******************
**************************************************

// *import migration
// import delimited "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/Migration/DP_LIVE_05122022052146679.csv", clear 
//
// drop subject indicator frequency flagcodes measure
// rename value mig
// rename location CountryCode
// rename time Year
//
//
// *merging the Indus_prod and Pop_PISA_HDI_PM25 datasets
// merge 1:1 CountryCode Year using Indus_Pop_PISA_HDI_PM25
// tab country if _m == 2
// sort country
//
// drop if _m == 1
// drop _m
// order country

**************************************************
********************Health exp.******************
**************************************************

*import Health
import delimited "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/Health Exp/P_Data_Extract_From_World_Development_Indicators/d8e4e8a0-dcd9-47d6-92ac-9dd0d466d023_Data.csv", clear 

*destring year variables by generating new year variables
local mcode 2010
foreach item of varlist v5-v16{
    di `item'[1]
	gen Year = real(`item')
	rename Year YR_`mcode'
	local mcode = `mcode' + 1
	drop `item'
}

drop v2
rename v3 country
rename v4 countryCode
// rename _* YR_*

*transposing dataset
encode v1, gen (Health)
// label list Class
drop v1
drop if country == ""

reshape long YR_, i(country Health) j(Year)
reshape wide YR_, i(country Year) j(Health) 
drop YR_4
rename YR_1 healthExp

*merging the datasets
merge 1:1 country Year using HDI_PM25_fifa_indus
sort country Year
drop _m

save HDI_PM25_fifa_indus_health, replace


**************************************************
********************FDI  dataset******************
**************************************************
//
// *import migration
// import delimited "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/FDI/DP_LIVE_05122022082009759.csv", clear 
//
// // *transpose
// // encode subject, gen (Code)
// // gen value1 = value if Code == 1
// // rename value value2
// // drop in value2 if Code == 2
// // // label list Code
// // // drop total
// // reshape long time, i(location Code) j(Year)
// // reshape wide time, i(location Year) j(Code)
// // rename Total_ Total_PM25
// // rename Period country
//
// drop if subject == "OUTWARD"
// drop subject indicator frequency flagcodes measure
// rename value fdi
// rename location CountryCode
// rename time Year
//
//
// *merging the Indus_prod and Pop_PISA_HDI_PM25 datasets
// merge 1:1 CountryCode Year using Indus_Pop_PISA_HDI_PM25
// tab country if _m == 2
// sort country
//
// drop if _m == 1
// drop _m
// order country

**************************************************
********************energy dataset******************
**************************************************

*import migration
import delimited "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/Renewable energy/P_Data_Extract_From_World_Development_Indicators/2dd01515-dec6-4a2c-92bb-130c78e2daa9_Data.csv", clear 

drop v5

*destring year variables by generating new year variables
local mcode 2010
foreach item of varlist v6-v17{
    di `item'[1]
	gen Year = real(`item')
	rename Year YR_`mcode'
	local mcode = `mcode' + 1
	drop `item'
}

drop v2
rename v3 country
rename v4 countryCode
// rename _* YR_*
drop in 1

*transposing dataset
encode v1, gen (Energy)
// label list Class
drop v1
drop if country == ""

reshape long YR_, i(country Energy) j(Year)
reshape wide YR_, i(country Year) j(Energy) 
// drop YR_4
rename YR_3 energy

*merging the datasets
merge 1:1 country Year using HDI_PM25_fifa_indus_health
sort country Year
drop _m

save HDI_PM25_fifa_indus_health_energy, replace

**************************************************
********************Income dataset******************
**************************************************

// *import income
// import delimited "/Users/aashi/Desktop/Environmental Economics/Research Project/Data/Income/DP_LIVE_04122022055516355.csv", clear 
//
// drop subject indicator frequency flagcodes measure
// rename value income
// rename location CountryCode
// rename time Year
//
//
// *merging the Indus_prod and Pop_PISA_HDI_PM25 datasets
// merge 1:1 CountryCode Year using Indus_Pop_PISA_HDI_PM25
// tab country if _m == 2
// sort country
//
// drop if _m == 1
// drop _m
// order country
//
// *for checking if PISA is a good IV
// corr PISA income
// reg PISA income
// reg income PISA
//
*generating HDI2 variable
// gen HDI2 = HDI*HDI
//
// save final, replace
                             **************************************************
                             *****************Summary & Graphs*****************
                             **************************************************
							 
*summary statistics
asdoc summarize

*forming histograms
// histogram PM25, normal normopts(lcolor(red) lpattern(vshortdash)) kdensity xtitle(Particulate Matter 2.5) xtitle(, size(small)) xscale(line) by(, title(Histogram of PM 2.5 for Countries, size(medium))) by(, legend(on position(4) at(20))) by(, clegend(on)) by(, plegend(on position(3) at(25))) scheme(s1colr) name(G1, replace) by(Year, total)
//
// histogram HDI, normal normopts(lcolor(red) lpattern(vshortdash)) kdensity xtitle(HDI) xtitle(, size(small)) xscale(line) by(, title(Histogram of HDI for Countries, size(medium))) by(, legend(on position(4) at(20))) by(, clegend(on)) by(, plegend(on position(3) at(25))) scheme(s1colr) name(G2, replace) by(Year, total)

// histogram HDI2, normal normopts(lcolor(red) lpattern(vshortdash)) kdensity xtitle(HDI squared) xtitle(, size(small)) xscale(line) by(, title(Histogram of HDI squared for Countries, size(medium))) by(, legend(on position(4) at(20))) by(, clegend(on)) by(, plegend(on position(3) at(25))) scheme(s1colr) name(G3, replace) by(Year, total)

//
// histogram Indus_prod, normal normopts(lcolor(red) lpattern(vshortdash)) kdensity xtitle(Industrial production) xtitle(, size(small)) xscale(line) by(, title(Histogram of Indus_prod for Countries, size(medium))) by(, legend(on position(4) at(20))) by(, clegend(on)) by(, plegend(on position(3) at(25))) scheme(s1colr) name(G4, replace) by(Year, total)

// histogram Pop_growth, normal normopts(lcolor(red) lpattern(vshortdash)) kdensity xtitle(Population growth (%)) xtitle(, size(small)) xscale(line) by(, title(Histogram of Population growth for Countries, size(medium))) by(, legend(on position(4) at(20))) by(, clegend(on)) by(, plegend(on position(3) at(25))) scheme(s1colr) name(G5, replace) by(Year, total)

*build scatterplots
twoway (scatter PM25 HDI, mcolor(lavender) msize(vsmall) msymbol(circle)) (lfit PM25 HDI, lcolor(blue)), ytitle(PM 2.5) title(Scatterplot of HDI and Particulate Matter 2.5) name(S1, replace)
twoway (scatter PM25 HDI, mcolor(lavender) msize(vsmall) msymbol(circle)) (lfit PM25 HDI, lcolor(blue)) (lfit PM25_hat HDI, lcolor(red)), ytitle(PM2.5) title(Scatterplot of HDI and PM2.5) subtitle((After considering the fixed effects)) name(Scatter_fixed, replace)
                             **************************************************
                             *****************Regression Analysis**************
                             **************************************************
*correlation matrix
asdoc corr PM25 HDI healthExp PISA

encode country, gen(Country_code)
*pooled method using OLS
reg PM25 HDI HDI2 Indus_prod Pop_growth, r
outreg2 using panel.doc, replace ctitle(Model 1) adjr2
 
*entity fixed effects
xtset Country_code Year
xtreg PM25 healthExp, fe vce(cluster Country_code)
outreg2 using panel.doc, append ctitle(Model 2) addtext(Country_code Fixed Effects, Yes) adjr2

*time fixed effects
reg PM25 HDI healthExp i.Year
outreg2 using panel.doc, append ctitle(Model 3) addtext(Country_code Fixed Effects, No, Time Fixed Effects, Yes) keep(PM25 HDI HDI2 Indus_prod) adjr2

*State & time fixed effects
xtreg PM25 HDI i.Year, fe vce(cluster Country_code)
outreg2 using panel1.doc, replace ctitle(Panel data) addtext(Country_code Fixed Effects, Yes, Time Fixed Effects, Yes) keep(PM25 HDI healthExp) adjr2
predict PM25_hat

*using IV
xtreg HDI PISA
predict HDI_hat
gen HDI_hat2 = HDI_hat*HDI_hat
xtivreg PM25 healthExp (HDI=PISA HDI_hat2) i.Year, fe vce(cluster Country_code)
savefirst
est store _ivreg2_PM25
est restore _ivreg2_HDI
outreg2 using IVfile.doc, replace ctitle(First stage)
est restore _ivreg2_PM25
outreg2 using IVfile.doc, append ctitle(Second stage) adjr2


log close
