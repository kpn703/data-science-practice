***Try different, seemingly simpler method first
set obs 1
gen mps_pp = fileread("https://en.wikipedia.org/wiki/Mont_Pelerin_Society#Past_presidents")
split mps_pp, gen(text) parse([A-Z])
gen mps=0
replace MPS=1 if regexm(mps_pp, "[A

***Not much luck. Trying import.io before I sink more time with Stata.

