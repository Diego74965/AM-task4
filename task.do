log using log.txt, replace text
/*
Date: 03/03/2023
Autor: Diego Ariel Soto Díaz
ID: 1797743
Subject: Applied Macroeconomics
Task: VAR model
*/

use usmacro.dta

***************************************************
********** PART 1: Test for stationarity **********
***************************************************
dfuller dlrinv, trend lags(12)
dfuller dlrinv, lags(12)

dfuller dlrgdp, trend lags(12)
dfuller dlrgdp, lags(12)

dfuller dlrcons, trend lags(12)
dfuller dlrcons, lags(12)

/* 
The three variables have a p-value lower than .05 so we can reject the null hypothesis of non-stationarity. Or if the test statistic value is more negative than critical values also means stationarity. 
All three are stationary. 
*/

************************************************
********** PART 2: Optimal lag lenght **********
************************************************
tsset time

varsoc dlrinv dlrgdp dlrcons, maxlag(12)

/* 
According to the Akaike Information Criteria (AIC), the optimal number of lags is 6.
According to the Hannan-Quinn Information Criteria (HQIC) and the Schwarz Bayesian Information Criteria (SBIC), the optimal number of lags is 1. 

We test both for autocorrelation to decide which will we keep.
*/

/* 6 lags */
var dlrinv dlrgdp dlrcons, lags(1/6)

predict r_dlrinv, r eq(dlrinv)
predict r_dlrgdp, r eq(dlrgdp)
predict r_dlrcons, r eq(dlrcons)

corrgram r_dlrinv, lags(20)
corrgram r_dlrgdp, lags(20)
corrgram r_dlrcons, lags(20)

drop r_dlrinv r_dlrcons r_dlrgdp

** No evidence of serial correlation (autocorrelation) for either residual **

/* 1 lag */
var dlrinv dlrgdp dlrcons, lags(1)

predict r_dlrinv, r eq(dlrinv)
predict r_dlrgdp, r eq(dlrgdp)
predict r_dlrcons, r eq(dlrcons)

corrgram r_dlrinv, lags(20)
corrgram r_dlrgdp, lags(20)
corrgram r_dlrcons, lags(20)

* evidence of autocorrelation in residuals of investment *

/* The model with no autocorrelation is the one with 6 lags so we will keep that */

*****************************************************
********** PART 3: Granger causality tests ********** 
*****************************************************

var dlrinv dlrgdp dlrcons, lags(1/6)
vargranger
* H0: variable _excluded_ does not granger cause _Equation_ *
/* 
dlrgdp granger causes dlrinv 
both gdp and cons jointly granger cause dlrinv 

inv, consumption, and jointly granger cause gdp

inv, gdp nor jointly granger cause consumption
*/



********************************************************
********** PART 4: Impulse response functions ********** 
********************************************************

* 1. growth rate of consumption responds to a one time positive shock in gr of income
* 2. growth rate of investment responds to one time positive shock in the growth rate of consumption
irf create myirf, step(20) set(myirfs, replace) 

*1*
irf graph oirf, impulse(dlrgdp) response(dlrcons)
/* 
One standard deviation shock of gdp rises consumption about .3 percentage points the first quarter and then .1 in the next. Then 0 (when gray area touches zero)
*/

*2*
irf graph oirf, impulse(dlrcons) response(dlrinv)
/*
Even though blue line goes up, the gray area (confidence interval) never stops touching zero, so an unexpected shock in consumption has no effect on investment. Reason: firms could think the shock in consumption is temporal so they don't invest.
*/

******************************************************************
********** PART 5: Estimate an exactlty identified SVAR ********** 
******************************************************************

* '\' represents a row change *
matrix A = (1,0,0 \ .,1,0 \ .,.,1)
matrix B = (.,0,0 \ 0,.,0 \ 0,0,.)

*structural var*
svar dlrinv dlrgdp dlrcons, aeq(A) beq(B) lags(1/6)

*If you want to see the estimated A and B matrices
matlist e(A)
matlist e(B)

*** dlrcons = 0.06 dlrinv + 0.52 dlrgdp ***
* This relation does holds. Proven!
log close