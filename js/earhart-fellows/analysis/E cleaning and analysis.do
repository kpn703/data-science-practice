///Stata 13 log file - Creating a new file instead of potentially messing up the original..
*log using "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\analysis\Earhart analysis.smcl" ///First time
*log using "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\analysis\E cleaning and analysis.smcl", append name(main)


***ALWAYS START BY STARTING THE LOG***
*log using "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\analysis\Earhart analysis15.smcl" ///First time
log using "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\analysis\Earhart analysis15.smcl", append

clear all
set more off

import delimited "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\ordered-output.csv", clear
save "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\analysis\E cleaning and analysis.dta", replace
***

***Start here unless you want to do the entire process from the CSV file.
***ALWAYS START BY STARTING THE LOG***
*log using "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\analysis\Earhart analysis.smcl" ///First time
log using "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\analysis\E cleaning and analysis.smcl", append name(main)

use "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\analysis\E cleaning and analysis.dta", clear
***Format 
format %25s name academicyear graduateinstitution areaofstudy sponsors emailaddress validemailaddress deceased
format %15s  recipientgender recipientgenderizedname simplesponsorgender simplesponsorgenderizedname entryid completiondegree mailingaddress emailaddress validemailaddress deceased
format %4.0g recipientgenderprobability 
drop graduateinstitutioninvalidatedli invalidprefixareaofstudy invalidpostfixareaofstudy

***Rename Graduateinstitution==gi and fix Graduateinstitution Edgecases: gi_subcampus, gi_country, gi_1/gi_2 , weird gi_1 and gi_2 cases***
split graduateinstitution, generate(gi) parse(~) 
rename gi1 gi
gen gi_country=gi2 if regexm(gi2, "Switzerland|United Kingdom|Canada|Mexico|Israel|Germany|France|Belgium")==1
replace gi_country="USA" if regexm(gi2, "Switzerland|United Kingdom|Canada|Mexico|Israel|Germany|France|Belgium")==0
gen gi_subcampus=gi2 if regexm(gi2, "Switzerland|United Kingdom|Canada|Mexico|Israel|Germany|France|Belgium")==0
drop gi2
order name gi academicyear, first
order graduateinstitution entryid gi, last
*gi_1/gi_2*
split(gi), gen(gi_) parse(/)
format gi_1 gi_2 %30s

***institutions that are the same but have different names/have different names but are the same***
replace gi_1="London School of Economics" if regexm(gi_1, "London School of economics")==1
replace gi_1="École des Hautes Etudes en Sciences Sociales" if regexm(gi_1, "Ecol")==1
replace gi_1="Claremont Graduate University" if regexm(gi_1, "Claremont Graduate School")==1
replace gi_1="Claremont McKenna College" if regexm(gi_1, "Claremont Men's College")==1
replace gi_1="Georgetown University" if regexm(gi_1, "Georgetown University")==1 
replace gi_1="Virginia Polytechnic Institute & State University" if regexm(gi_1, "Virginia Polytechnic Institute")==1
replace gi_1="Yale University" if regexm(gi_1, "Yale Divinity School")==1
replace gi_1="Missouri State University" if regexm(gi_1, "Southwest Missouri State University")==1
replace gi_1="University of Cambridge" if regexm(gi_1, "Cambridge University")==1
replace gi_1="University of Notre Dame" if regexm(gi_1, "Notre Dame University")==1
replace gi_1="University of St. Andrews" if regexm(gi_1, "St. Andrews University")==1
replace gi_1="University of Oxford" if regexm(gi_1, "Oxford University")==1

***///If we truly care about peer effects maybe undergrad institutions/women's only schools needs to be categorized..?
replace gi_1="Harvard University" if regexm(gi_1, "Harvard|Radcliffe")==1 
replace gi_1="Columbia University" if regexm(gi_1, "Columbia College")==1 

***Edgecases where we should test whether & document that our assumptions don't influence the results: 
replace gi_1="Michigan State University" if regexm(gi_1, "Kenyon College and Michigan State University")==1
replace gi_2="Kenyon College" if regexm(graduateinstitution, "Kenyon College and Michigan State University")==1
replace gi_1="Indiana University" if regexm(gi_1, "University of Indiana")==1

*replace gi_1="Princeton University" if regexm(gi_1, "Princeton Theological Seminary")==1 ///Not the same according to one comment... Make sure not influential to results...

***Stringgroup to see whether typo's exist in gi_1
*strgroup gi_1, gen(gi_grouped) threshold(.01) ///Not needed anymore?

***Clean/match typo's etc. among sponsors
strgroup sponsors, gen(sponsors_grouped) threshold(0.01)
codebook sponsors_grouped

***Clean typos in sponsors, substitute and for & --> by sponsors_grouped: tab sponsors
*replace sponsors="" if regexm(sponsors, "")==1
replace sponsors="Clifton L. Ganus Jr." if regexm(sponsors, "Clifton L. Gallus")==1
replace sponsors="Christopher Bruell and Robert K. Faulkner" if regexm(sponsors, "Christopher Bruell and Robert K. Faulkners|Christopher Bruen and Robert K. Faulkner")==1
replace sponsors="Edward C. Banfield" if regexm(sponsors, "Edward C. Bonfield")==1
replace sponsors="Murray L. Weidenbaum" if regexm(sponsors, "Murray L. Weidenbaun")==1
replace sponsors="Deil S. Wright" if regexm(sponsors, "Dell S. Wright")==1
replace sponsors="Daniel J. Elazar" if regexm(sponsors, "Daniel J. Elvar")==1
replace sponsors="E. Maynard Aris" if regexm(sponsors, "E. Maynard Eris")==1
replace sponsors="Roland F. Salmonson and James Don Edwards" if regexm(sponsors, "Roland E Salmonson and James Don Edwards")==1
replace sponsors="John J. DiIulio Jr." if regexm(sponsors, "John J. D")==1
replace sponsors="G. Ellis Sandoz Jr." if regexm(sponsors, "G. Ellis Sandoz")==1

***Subinstr inconsistent use of and/&,  
replace sponsors=subinstr(sponsors, "&", "and", 5000)
replace sponsors=subinstr(sponsors, "~", ",", 5000)

***MAKE SURE THIS FITS AT THIS POINT IN FILE***
encode(gi_1), gen(ins)
encode(numyears), gen(nyears)









***Try to scrape wikipedia entry for MPS***
file open test using "https://en.wikipedia.org/wiki/Mont_Pelerin_Society", read
file read test line
while r(eof)==0 {
	di"'line'"
	///Do something with the input
	file read test line
}

***Try different, seemingly simpler method first
set obs 1
gen mps_pp = fileread("https://en.wikipedia.org/wiki/Mont_Pelerin_Society#Past_presidents")

***MPS dummy and, if known, year joined***
gen MPS=0
replace MPS=1 if regexm(




***Academic years; single terms, summer, winter etc. Start with extracting all instances of "and" i.e. "Summer and Fall 2000" - otherwise we will erroneously delete/confuse the terms.. Then replace these with ""
rename academicyear fundingyear
gen abnormaltimeperiod=""
gen abnormaltimeperiod2=""
gen abnormaltimeperiod3=""

*summer and fall first, then spring and summer, winter and spring /// 
///Why on earth did I do this 3 times? In theory one fellow could have received funding for summer and fall multiple times and this method only replaces the first instance, so repeat until no real changes are made.

replace abnormaltimeperiod=regexs(0) if regexm(fundingyear,"Summer and Fall [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear,"Summer and Fall [0-9][0-9][0-9][0-9]","")
replace abnormaltimeperiod=abnormaltimeperiod + "," + regexs(0) if regexm(fundingyear,"Summer and Fall [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear,"Summer and Fall [0-9][0-9][0-9][0-9]","")
replace abnormaltimeperiod=abnormaltimeperiod + "," + regexs(0) if regexm(fundingyear,"Summer and Fall [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear,"Summer and Fall [0-9][0-9][0-9][0-9]","")

replace abnormaltimeperiod2=regexs(0) if regexm(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]","")
replace abnormaltimeperiod2=abnormaltimeperiod2 + "," + regexs(0) if regexm(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]","")
replace abnormaltimeperiod2=abnormaltimeperiod2 + "," + regexs(0) if regexm(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]","")

replace abnormaltimeperiod3=regexs(0) if regexm(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]","")
replace abnormaltimeperiod3=abnormaltimeperiod3 + "," + regexs(0) if regexm(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]","")
replace abnormaltimeperiod3=abnormaltimeperiod3 + "," + regexs(0) if regexm(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]","")

gsort -abnormaltimeperiod

***
*COME BACK AND SORT OUT THE SUMMER AND FALL terms
***Note to self - appears like all the "and" observations are dealt with at this point. With "and" terms extracted -- do the same for odd semesters(oddsem) such as "Fall 2000"
gen oddsem=""
gen oddsem2=""
gen oddsem3=""
gen oddsem4=""
gen oddsem5=""

replace oddsem=regexs(0) if regexm(fundingyear, "Spring [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Spring [0-9][0-9][0-9][0-9]","")
replace oddsem=oddsem + "," + regexs(0) if regexm(fundingyear, "Spring [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Spring [0-9][0-9][0-9][0-9]","")

replace oddsem2=regexs(0) if regexm(fundingyear, "Fall [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Fall [0-9][0-9][0-9][0-9]","")
replace oddsem2=oddsem2 + "," + regexs(0) if regexm(fundingyear, "Fall [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Fall [0-9][0-9][0-9][0-9]","")
replace oddsem2=oddsem2 + "," + regexs(0) if regexm(fundingyear, "Fall [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Fall [0-9][0-9][0-9][0-9]","")

replace oddsem3=regexs(0) if regexm(fundingyear, "Summer [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Summer [0-9][0-9][0-9][0-9]","")
replace oddsem3=oddsem3 + "," + regexs(0) if regexm(fundingyear, "Summer [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Summer [0-9][0-9][0-9][0-9]","")
replace oddsem3=oddsem3 + "," + regexs(0) if regexm(fundingyear, "Summer [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Summer [0-9][0-9][0-9][0-9]","")
replace oddsem3=oddsem3 + "," + regexs(0) if regexm(fundingyear, "Summer [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Summer [0-9][0-9][0-9][0-9]","")

replace oddsem4=regexs(0) if regexm(fundingyear, "Winter [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Winter [0-9][0-9][0-9][0-9]","")
replace oddsem4=oddsem4 + "," + regexs(0) if regexm(fundingyear, "Winter [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Winter [0-9][0-9][0-9][0-9]","")

replace oddsem5=regexs(0) if regexm(fundingyear, "Calendar Year [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Calendar Year [0-9][0-9][0-9][0-9]","")
replace oddsem5=oddsem5 + "," + regexs(0) if regexm(fundingyear, "Calendar Year [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Calendar Year [0-9][0-9][0-9][0-9]","")
replace oddsem5=oddsem5 + "," + regexs(0) if regexm(fundingyear, "Calendar Year [0-9][0-9][0-9][0-9]")==1
replace fundingyear=regexr(fundingyear, "Calendar Year [0-9][0-9][0-9][0-9]","")

*now remove double commas and commas as first character PS only remove 1 commma from last character comma..!
replace fundingyear=subinstr(fundingyear, ",,",",",10)
replace fundingyear=subinstr(fundingyear, ",","",1) if regexm(fundingyear, "^,")==1
replace fundingyear=subinstr(fundingyear, ",","",1) if regexm(fundingyear, ",$")==1

***CONTINUE FROM HERE WITH DIVIDING YEARS INTO HALFYEARS
replace fundingyear=subinstr(fundingyear,",","H1,",10)
replace fundingyear=subinstr(fundingyear,"-","H2,",10)
***Currently no H1 after final year
replace fundingyear=fundingyear + "H1" if regexm(fundingyear, "[0-9]")==1
***Looks good at this point but I haven't looked super closely - continuing with oddsem and abnormaltimeperiods(which btw was a terrible choice of variablename..)
replace oddsem=oddsem + "H1" if regexm(oddsem, "Spring")==1
replace oddsem=subinstr(oddsem,"Spring ","",.)
replace oddsem2=oddsem2 + "H2" if regexm(oddsem2, "Fall")==1
replace oddsem2=subinstr(oddsem2,"Fall ","",.)

***continuing with summer, winter, calendaryear as that appears to be where I left off in the past. Better commenting needed!
*classifying summer as H2, Winter as H1, just to get an idea of funding over time. 
replace oddsem3=oddsem3 + "H2" if regexm(oddsem3, "Summer")==1
replace oddsem3=subinstr(oddsem3,"Summer ","",.)

replace oddsem4=oddsem4 + "H1" if regexm(oddsem4, "Winter")==1
replace oddsem4=subinstr(oddsem4,"Winter ","",.)

*For oddsem5: trying to replace commas during process bc Calendar Year means both H1 and H2, thus previous order seems to get all messed up
replace oddsem5=subinstr(oddsem5,"Calendar Year ","",.)

*further split oddsem5 to avoid stumbling on the multiple year issue
split oddsem5, gen(oddsem5_) parse(",")
replace oddsem5_1=oddsem5_1 + "H1" if regexm(oddsem5_1, "[0-9]")==1
replace oddsem5_1=oddsem5_1 + "," + oddsem5_1 + "H2" if regexm(oddsem5_1, "[0-9]")==1
replace oddsem5_1=subinstr(oddsem5_1,"H1H2","H2",.)

replace oddsem5_2=oddsem5_2 + "H1" if regexm(oddsem5_2, "[0-9]")==1
replace oddsem5_2=oddsem5_2 + "," + oddsem5_2 + "H2" if regexm(oddsem5_2, "[0-9]")==1
replace oddsem5_2=subinstr(oddsem5_2,"H1H2","H2",.)

***Seems like it worked!! end this fix continue to clean multiple observations within each of these special cases

***some observations have multiple semesters, add H1/H2 before comma
replace oddsem2=subinstr(oddsem2,",","H2,",.) if regexm(oddsem2, "[0-9]")==1

***Trying out monthly academicyears...Here comes a head ache?
gen myear="2000H1"
replace myear=subinstr(myear,"H1","m2",.)
replace myear_1=subinstr(myear,"m2","m3",.)





***Does this belong?***
gen academicyear=fundingyear if regexm(fundingyear, "[a-zA-Z]")==0
replace academicyear=subinstr(academicyear, "-", "H2 ", 5000)
replace academicyear=subinstr(academicyear, ",", "H1 ", 5000)
replace academicyear = academicyear + "H1" if academicyear!=""
split academicyear, gen(semester) parse(" ")

gen abnormal_academicyear=fundingyear if regexm(fundingyear, "[a-zA-Z]")==1
replace abnormal_academicyear=subinstr(abnormal_academicyear, "-", "H2 ", 5000)
split abnormal_academicyear, gen(ay) parse(",")
replace ay1=ay1 + "H1" if regexm(ay1, "^Fall ")==1
replace ay1=ay1 + "H2" if regexm(ay1, "Spring [0-9]")==1

replace ay5=ay5 + "H1" if regexm(ay5, "H2 ")==1
replace ay4=ay4 + "H1" if regexm(ay4, "H2 ")==1
replace ay3=ay3 + "H1" if regexm(ay3, "H2 ")==1
replace ay2=ay2 + "H1" if regexm(ay2, "H2 ")==1
replace ay1=ay1 + "H1" if regexm(ay1, "H2 ")==1

*Remove the abnormal terms from abnormal years...
gen ay11=ay1 if regexm(ay1, "Summer|Winter|Calendar Year")==1
gen ay12=ay2 if regexm(ay2, "Summer|Winter|Calendar Year")==1
gen ay13=ay3 if regexm(ay3, "Summer|Winter|Calendar Year")==1
gen ay14=ay4 if regexm(ay4, "Summer|Winter|Calendar Year")==1
gen ay15=ay5 if regexm(ay5, "Summer|Winter|Calendar Year")==1

replace ay1="" if regexm(ay1, "Summer|Winter|Calendar Year")==1
replace ay2="" if regexm(ay2, "Summer|Winter|Calendar Year")==1
replace ay3="" if regexm(ay3, "Summer|Winter|Calendar Year")==1
replace ay4="" if regexm(ay4, "Summer|Winter|Calendar Year")==1
replace ay5="" if regexm(ay5, "Summer|Winter|Calendar Year")==1

*Add H1/H2 and replace "Fall " with ""
replace ay2=ay2 + "H1" if regexm(ay2, "Fall ")==1
replace ay2=ay2 + "H2" if regexm(ay2, "Spring ")==1
replace ay3=ay3 + "H1" if regexm(ay3, "Fall ")==1
replace ay3=ay3 + "H2" if regexm(ay3, "Spring ")==1
replace ay4=ay4 + "H1" if regexm(ay4, "Fall ")==1
replace ay4=ay4 + "H2" if regexm(ay4, "Spring ")==1
replace ay5=ay5 + "H1" if regexm(ay5, "Fall ")==1
replace ay5=ay5 + "H2" if regexm(ay5, "Spring ")==1



replace ay1=subinstr(ay1, "Fall ", "", 5000)
replace ay1=subinstr(ay1, "Spring ", "", 5000)
replace ay2=subinstr(ay2, "Fall ", "", 5000)
replace ay2=subinstr(ay2, "Spring ", "", 5000)
replace ay3=subinstr(ay3, "Fall ", "", 5000)
replace ay3=subinstr(ay3, "Spring ", "", 5000)
replace ay4=subinstr(ay4, "Fall ", "", 5000)
replace ay4=subinstr(ay4, "Spring ", "", 5000)
replace ay5=subinstr(ay5, "Fall ", "", 5000)
replace ay5=subinstr(ay5, "Spring ", "", 5000)

*split ay1,2,3,4,5 to 1-10 then replace semesters with semesters
split ay1, gen(ay_1) parse(" ")
split ay2, gen(ay_2) parse(" ")
split ay3, gen(ay_3) parse(" ")
split ay4, gen(ay_4) parse(" ")
split ay5, gen(ay_5) parse(" ")

replace semester1=ay_11 if ay_11!=""
replace semester2=ay_12 if ay_12!=""
replace semester3=ay_21 if ay_21!=""
replace semester4=ay_22 if ay_22!=""
replace semester5=ay_31 if ay_31!=""
replace semester6=ay_32 if ay_32!=""
replace semester7=ay_41 if ay_41!=""
replace semester8=ay_42 if ay_42!=""
replace semester9=ay_51 if ay_51!=""
replace semester10=ay_52 if ay_52!=""

***Gen temporary MPS variable
gen notmps_preliminary=0
replace notmps_preliminary=1 if regexm(sponsors,"Weimer|Gaumnitz|Boddy|Viner|Paton|Kendrick|Lamborn|Schwenning|Eckelberry|Wolman|Briefs|Ross|Muth|Roegen|McCracken")==1




***Match fellows and sponsors to see who went from being fellow to sponsor***///THIS DIDN'T WORK -TRYING AGAIN WITH RECLINK
split name, gen(name_match) parse(",")
gen name_match=name_match2 + " " + name_match1
drop name_match1 name_match2
split sponsors, gen(sponsors_match) parse(" and ")

matchit name_match sponsors_match1, gen(f2s) ///Matching sponsors and fellow names for each entry, not over the entire variable. 

***trying with reclink
gen id=_n
replace name_match=lower(name_match)
reclink name_match using "C:\Users\Markus\Desktop\sponsors.dta", idmaster(id) idusing(B) uvarlist(A) gen(f2s)
reclink name_match using "C:\Users\Markus\Desktop\sponsors.dta", idmaster(id) idusing(B) uvarlist(A) gen(f2s2)

***Trying with instructions from Steve Smela
capture drop WasSponsor
gen WasSponsor = 0

local Obs = _N

forvalues i = 1 / `Obs' {
	forvalues j = 1 / `Obs' {
*		di `i' `j'
		replace WasSponsor = 1 in `i' if name[`i'] == sponsors[`j'] 
	}
}	





***DISREGARD***
/*
replace ay1=subinstr(ay1, "Calendar Year ", "", 5000)
replace ay1=ay1 + "H1H2" if regexm(ay1, " ")==0 

replace ay1=ay1 + "H1" if regexm(ay1, "H2 ")==1
replace ay1=subinstr(ay1, "Fall ", "H1 $", 5000)
*/

/*gen ay1=substr(abnormal_academicyear, 1, 4) + "H1" if regexm(abnormal_academicyear, "^[0-9][0-9][0-9][0-9]")==1
replace abnormal_academicyear=subinstr(abnormal_academicyear, "[0-9][0-9][0-9][0-9]", "", 5000)

gen ay2=substr(abnormal_academicyear, 6, 4) + "H2" if regexm(abnormal_academicyear, "^[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]")==1
replace abnormal_academicyear=subinstr(abnormal_academicyear, "-", "H1 ", 5000)
replace abnormal_academicyear=subinstr(abnormal_academicyear, ",", "H2 ", 5000)
*/
/*




replace abnormaltimeperiod=abnormaltimeperiod + "," + regexs(0) if regexm(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]")==1
replace abnormaltimeperiod=abnormaltimeperiod + "," + regexs(0) if regexm(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]")==1

replace abnormaltimeperiod=abnormaltimeperiod + "," + regexs(0) if regexm(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]")==1
replace abnormaltimeperiod=abnormaltimeperiod + "," + regexs(0) if regexm(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]")==1

replace fundingyear=regexr(fundingyear,"Summer and Fall [0-9][0-9][0-9][0-9]","")
replace fundingyear=regexr(fundingyear,"Summer and Fall [0-9][0-9][0-9][0-9]","")
replace fundingyear=regexr(fundingyear,"Summer and Fall [0-9][0-9][0-9][0-9]","")

replace fundingyear=regexr(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]","")
replace fundingyear=regexr(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]","")
replace fundingyear=regexr(fundingyear,"Spring and Summer [0-9][0-9][0-9][0-9]","")

replace fundingyear=regexr(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]","")
replace fundingyear=regexr(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]","")
replace fundingyear=regexr(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]","")




|Fall [0-9][0-9][0-9][0-9],|Summer [0-9][0-9][0-9][0-9],|Summer [0-9][0-9][0-9][0-9]|Winter [0-9][0-9][0-9][0-9],|Winter [0-9][0-9][0-9][0-9]|Calendar Year [0-9][0-9][0-9][0-9],|Calendar Year [0-9][0-9][0-9][0-9]")==1
replace abnormaltimeperiod=regexs(0) if regexm(fundingyear,"Fall [0-9][0-9][0-9][0-9]|Fall [0-9][0-9][0-9][0-9],|Summer [0-9][0-9][0-9][0-9],|Summer [0-9][0-9][0-9][0-9]|Winter [0-9][0-9][0-9][0-9],|Winter [0-9][0-9][0-9][0-9]|Calendar Year [0-9][0-9][0-9][0-9],|Calendar Year [0-9][0-9][0-9][0-9]")==1



replace fundingyear=subinstr(fundingyear,"Summer [0-9][0-9][0-9][0-9]","",.)

replace abnormaltimeperiod=regexr(fundingyear,"[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9],","")
|Winter and Spring [0-9][0-9][0-9][0-9],|Summer and Fall [0-9][0-9][0-9][0-9],|Summer and Fall [0-9][0-9][0-9][0-9]|Spring and Summer [0-9][0-9][0-9][0-9],|Spring and Summer [0-9][0-9][0-9][0-9]","")==1
replace abnormaltimeperiod=regexs(3) if regexm(fundingyear,"Winter and Spring [0-9][0-9][0-9][0-9]|Winter and Spring [0-9][0-9][0-9][0-9],|Summer and Fall [0-9][0-9][0-9][0-9],|Summer and Fall [0-9][0-9][0-9][0-9]|Spring and Summer [0-9][0-9][0-9][0-9],|Spring and Summer [0-9][0-9][0-9][0-9]")==1

*/




***Rename some variable ///What's going on here???
rename gi_country country

***gen  MPS sponsors during 50's***
gen MPS=0
replace MPS=1 if regexm(sponsors, "Friedman|Hayek|




***Encode clean categorical variables***
encode areaofstudy, gen(major)
encode completiondegree, gen(degree)
encode validemailaddress, gen(validemail)
encode deceased, gen(deceased_fellow)
encode simplesponsorgender, gen(gender_sponsor)
encode recipientgender, gen(gender_recipient)
encode country, gen(gi_country)





///Save until proven worthwhile///
***Correct for institutions that ONLY award undergrad degrees/did NOT award graduate degrees at the time Fellow attended..***
/*gen undergrad=0
replace undergrad=1 if regexm(gi, "Claremont Men's College|Claremont McKenna College|Alma College|Asbury College|Harvard College")==1 ///confirmed all gi's with "College" in name except 3 that are assigned to RA
*/


export excel using "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\analysis\E cleaning and analysis.xls", firstrow(variables) replace
save "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\analysis\E cleaning and analysis.dta", replace





