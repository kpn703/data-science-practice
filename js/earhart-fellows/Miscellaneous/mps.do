***MPS Directory
clear all

*log using 

import delimited "C:\Users\Markus\Desktop\GIT\data-science-practice\js\earhart-fellows\Miscellaneous\Mont Pelerin Society Directory 2010.txt", delimiter("  ", asstring) ///Importing everything to one variable--> parse

*** Generate variables that easily subtracted from string. 
gen lifemember=0
replace lifemember=1 if regexm(v1, "Life Member")==1

gen yearentered=substr(v1,-5,.) if regexm(v1,"[0-9],$")==1
replace yearentered=substr(v1,-5,.) if regexm(v1,"[0-9],$")==1


*fail
gen yearentered=subinstr(v1,"[0-9][0-9][0-9][0-9]")
