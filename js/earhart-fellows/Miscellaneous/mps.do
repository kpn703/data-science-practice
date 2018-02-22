***MPS Directory
clear all

*log using 

import delimited "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\Miscellaneous\Mont Pelerin Society Directory 2010.txt", delimiter("  ", asstring) ///Importing everything to one variable--> parse
use "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\Miscellaneous\mps10.dta"
*** Generate variables that easily subtracted from string. 
gen lifemember=0
replace lifemember=1 if regexm(v1, "Life Member")==1

gen yearentered=substr(v1,-5,.) if regexm(v1,"[0-9],$")==1
replace yearentered=subinstr(yearentered,",","",.)

*Now extract entering years for life members
replace yearentered=regexs(0) if regexm(v1,"[0-9][0-9][0-9][0-9]")==1
destring yearentered, replace ignore(`","') force ///This is easier than subinstr!

*trim the comma at the end of v1
replace v1=substr(v1,,-1)

*after manually filling in country - ugh! drop "country observations"
drop if yearentered==""

***Now separate honorifics, names, positions, affiliations
drop hon
gen hon=""
replace hon=regexs(0) if regexm(v1,"Dr.|Mr.|Ms.|Mrs.|^(Professor)|Monsieur|Hon. Sir|Honorable|Rt. Hon. Dr. Sir |Prof.|Ambassador|The Honorable|^(Hon.)|Judge|Dipl.|Reverend|The Rt. Hon. The Lord Howe Of Aberavon")==1

split v1, generate(name_) parse(,) 
*gen categorical society variables
gen fmrpres=0
replace fmrpres=1 if regexm(v1, "'*'")==1
gen foundingmember=0
replace foundingmember=1 if regexm(name_1,"Hayek|Milton Friedman|Stigler|Ropke|Röpke|Mises|Rappard|Robbins|Allais|Brandt|Popper")==1



subinstr(name_1,"Dr.|Mr.|Ms.|Mrs.|Professor|Monsieur|Hon. Sir|Honorable|Rt. Hon. Dr. Sir |Prof.|Ambassador|The Honorable|Hon.|Judge|Dipl.|Reverend|The Rt. Hon. The Lord Howe Of Aberavon","",.)==1
"Dr.|Mr.|Ms.|Mrs.|^(Professor)|Monsieur|Hon. Sir|Honorable|Rt. Hon. Dr. Sir |Prof.|Ambassador|The Honorable|^(Hon.)|Judge|Dipl.|Reverend|The Rt. Hon. The Lord Howe Of Aberavon","",.)
***Remove entry years from other vars
replace name_1="" if regexm(name_1,"[0-9][0-9][0-9][0-9]")==1
replace name_2="" if regexm(name_2,"[0-9][0-9][0-9][0-9]")==1
replace name_3="" if regexm(name_3,"[0-9][0-9][0-9][0-9]")==1
replace name_4="" if regexm(name_4,"[0-9][0-9][0-9][0-9]")==1
replace name_5="" if regexm(name_5,"[0-9][0-9][0-9][0-9]")==1
replace name_6="" if regexm(name_6,"[0-9][0-9][0-9][0-9]")==1
replace name_7="" if regexm(name_7,"[0-9][0-9][0-9][0-9]")==1
*
replace name_3=name_2 if name_3==""
replace name_2="" if name_2==name_3
* life time

replace name_1="" if regexm(name_1,"Life Member")==1
replace name_2="" if regexm(name_2,"Life Member")==1
replace name_3="" if regexm(name_3,"Life Member")==1
replace name_4="" if regexm(name_4,"Life Member")==1
replace name_5="" if regexm(name_5,"Life Member")==1
replace name_6="" if regexm(name_6,"Life Member")==1
replace name_7="" if regexm(name_7,"Life Member")==1
*formatting
format name_2 hon %40s
format hon %10s
format name_3 name_4 name_5 name_6 %20s

*Now sort out the institutions/roles that included commas...
replace name_2=name_2 + " " + name_3 + " " + name_4 + " " + name_5 in 490
replace name_4=name_3 if name_4==""
replace name_3="" if name_3==name_4
/*
replace name_1-name_7=="" if regexm(name_1-name_7,"[0-9][0-9][0-9][0-9]")
rename name_2 title
*/

rename (


*replace yearentered=substr(v1,-5,.) if regexm(v1,"[0-9],$")==1
export excel using "mps10", replace
save "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\Miscellaneous\mps10.dta", replace
