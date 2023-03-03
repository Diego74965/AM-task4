use usmacro.dta

************ Test for stationarity ************
dfuller dlrinv, trend lags(12)
dfuller dlrinv, lags(12)

dfuller dlrgdp, trend lags(12)
dfuller dlrgdp, lags(12)

dfuller dlrcons, trend lags(12)
dfuller dlrcons, lags(12)

/* The three variables have a p-value lower than .05 so we can reject the null hypothesis of non-stationarity. Or test statistic value more negative than critical values. 
	All three are stationary. */
tsset time

varsoc dlrinv dlrgdp dlrcons, maxlag(12)

/* When we increase the number of lags to be tested to 12, the optimal number is 6  but HQIC & SBIC says 1 lag */

/* 6 lags */
var dlrinv dlrgdp dlrcons, lags(1/6)

predict r_dlrinv, r eq(dlrinv)
predict r_dlrgdp, r eq(dlrgdp)
predict r_dlrcons, r eq(dlrcons)

corrgram r_dlrinv, lags(20)
corrgram r_dlrgdp, lags(20)
corrgram r_dlrcons, lags(20)

drop r_dlrinv r_dlrcons r_dlrgdp

** No evidence of serial correlation **

/* 1 lag */
var dlrinv dlrgdp dlrcons, lags(1)

predict r_dlrinv, r eq(dlrinv)
predict r_dlrgdp, r eq(dlrgdp)
predict r_dlrcons, r eq(dlrcons)

corrgram r_dlrinv, lags(20)
corrgram r_dlrgdp, lags(20)
corrgram r_dlrcons, lags(20)

* evidence of autocorrelation *

/* The model with no autocorrelation is the one with 6 lags so we will use that */

var dlrinv dlrgdp dlrcons, lags(1/6)
vargranger
* H0: variable _excluded_ does not granger cause _Equation_ *
/* 
dlrgdp granger causes dlrinv 
both gdp and cons jointly granger cause dlrinv 

inv, consumption, and jointly granger cause gdp

inv, gdp nor jointly granger cause consumption
*/


**** Impulse response ***
* 1. growth rate of consumption responds to a one time positive shock in gr of income
* 2. growth rate of investment responds to one time positive shock in the growth rate of consumption
irf create myirf, step(10) set(myirfs) 
irf create myirf, step(20) set(myirfs, replace) 

irf graph oirf, impulse(dlrgdp) response(dlrcons)
** One standard deviation shock of gdp rises consumption about .3 percentage points the first quarter and then .1 in the next. Then 0 (when gray area touches zero)

irf graph oirf, impulse(dlrcons) response(dlrinv)
** Even though blue line goes up, the gray area (confidence interval) never stops touching zero, so an unexpectes shock in consumption has no effect on investment. Reason: firms could think the shock in consumption is temporal so they don't invest.

********** PART 5: Estimate an exactly identified SVAR ******
*\ represent a row change*
matrix A = (1,0,0 \ .,1,0 \ .,.,1)
matrix B = (.,0,0 \ 0,.,0 \ 0,0,.)

*structural var*
svar dlrinv dlrgdp dlrcons, aeq(A) beq(B) lags(1/6)

*If you want to see the estimated A and B matrices
matlist e(A)
matlist e(B)

*** dlrcons = 0.06 dlrinv + 0.52 dlrgdp ***
* This relation does holds. Proven!

