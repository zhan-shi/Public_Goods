clear
drop _all

* generating fake dataset 
set seed 1
set obs 20000

mat mCorr = (1, .9, .8, .6, .4, .2, .01\    ///
			.9, 1, .7, .6, .4, .2, .1\    ///
			.8, .7, 1, .5, .3, .15, .05\    ///
			.6, .6, .5, 1, .25, .12, .05\    ///
			.4, .4, .3, .25, 1, .1, .05\     ///
			.2, .2, .15, .12, .1, 1, .05\    ///
			.01, .1, .05, .05, .05, .05, 1) 
corr2data x1 x2 x3 x4 x5 x6 x7, means(1 1 1 1 1 1 1) sds(0.4 0.4 0.4 0.4 0.4 0.4 0.4) cstorage(full) corr(mCorr) n(20000) clear
corr

gen double e = rnormal()


cap drop y
gen y = 2*x1 + 1*x2 + 4*x3 + 5*x2*x4 + 6*x5 + x6 + e

sum y, d 
local mean_y = string(r(mean), "%9.2f")

reg y x1 
estadd local mean_depvar = "`mean_y'"
est sto est1

reg y x1 x2 x3 
estadd local mean_depvar = "`mean_y'"
est sto est2 

reg y x1 c.x2##c.x4 
estadd local mean_depvar = "`mean_y'"
est sto est3 

reg y x1 c.x2##c.x4 x5 x6 
estadd local mean_depvar = "`mean_y'"
est sto est4 

* stata outcome to latex 
cap file close table_out
file open table_out using "eg.tex", write replace
file write table_out "\begin{tabular}{l cccc}" _n
file write table_out "\toprule" _n
file write table_out "& \multicolumn{4}{c}{Dep Var}  \\ \cmidrule(lr){2-5}" _n
file write table_out "& (1) & (2) & (3) & (4)  \\ " _n
file close table_out

esttab est1 est2 est3 est4 ///
using "eg.tex", append f ///
label booktabs b(2) se(2) nonotes eqlabels(none) nomtitles collabels(none) nonumbers  ///
varlabel(x1 "IndepVar1 " x2 "IndepVar2" x3 "IndepVar3")   ///
indicate( ///
	"Control1 = x4" ///
	"Control2 = x5" ///
	"Control3 = x6" ///
	"Interaction = c.x2#c.x4" ///
) ///
keep(x1 x2 x3) star(* .10 ** .05 *** .01) ///
stats(mean_depvar N r2, fmt(3 "%9.0fc" 3)  labels(`"Mean Dep Var"' `"Observations"' `"$ R^2 $"') )  

file open table_out using "eg.tex", write append
file write table_out "\bottomrule" _n
file write table_out "\end{tabular}" 
file close table_out 

