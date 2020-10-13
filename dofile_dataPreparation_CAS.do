* CAS ADS - Project - Political Representation Swiss Parliament
* Handling some parte of the Data Science Project with Stata

clear all
cd "/Users/ZumofenG/OneDrive/PhD/Formation/CAS_ADS/M2_StatisticalInference/Project_RepresentationSwissParliament"
capture log close
log using p1_enlightenedselective.log, replace
set more off

* 1. Importing dataset - Elaborated with R
use data_swissparl.dta, replace

* 2. Data preparation
rename state status
* status_v = code status 0 =Accepted, 1 = Rejected, .= otherwise
generate status_v = 1 if status=="Angenommen"
replace status_v=0 if status=="Erledigt"

*sex_v
generate sex_v=1 if sex=="f"
replace sex_v=0 if sex=="m"
replace sex_v=99 if sex=="NA"

* canton_v
generate canton_v=1 if canton=="ZH"
replace canton_v=2 if canton=="BE"
replace canton_v=3 if canton=="LZ"
replace canton_v=4 if canton=="UR"
replace canton_v=5 if canton=="SZ"
replace canton_v=6 if canton=="OW"
replace canton_v=7 if canton=="NW"
replace canton_v=8 if canton=="GL"
replace canton_v=9 if canton=="ZG"
replace canton_v=10 if canton=="FR"
replace canton_v=11 if canton=="SO"
replace canton_v=12 if canton=="BS"
replace canton_v=13 if canton=="BL"
replace canton_v=14 if canton=="SH"
replace canton_v=15 if canton=="AR"
replace canton_v=16 if canton=="AI"
replace canton_v=17 if canton=="SG"
replace canton_v=18 if canton=="GR"
replace canton_v=19 if canton=="AG"
replace canton_v=20 if canton=="TG"
replace canton_v=21 if canton=="TI"
replace canton_v=22 if canton=="VD"
replace canton_v=23 if canton=="VS"
replace canton_v=24 if canton=="NE"
replace canton_v=25 if canton=="GE"
replace canton_v=26 if canton=="JU"

* party_v
generate party_v=1 if party=="CVP"
replace party_v=2 if party=="FDP-Liberale"
replace party_v=2 if party=="FDP"
replace party_v=3 if party=="SP"
replace party_v=4 if party=="SVP"
replace party_v=5 if party=="GPS"
replace party_v=6 if party=="glp"
replace party_v=7 if party=="BDP"
replace party_v=8 if party_v==.

* council_v (0=Nationalrat, 1=Standerat)
drop if council==""
generate council_v=0 if council=="Nationalrat"
replace council_v=1 if council_v==.

* years_parliament_v
generate year_join=substr(date_join, 1, 4)
replace year_join="." if year_join=="NA"
destring year_join, replace
generate year_leave=substr(date_leave, 1, 4)
replace year_leave="." if year_leave=="NA"
replace year_leave="2020" if year_leave=="."
destring year_leave, replace
generate years_parliament_v = year_leave-year_join

* affair_no_v
tostring id, replace
generate year_affair = substr(id, 3, 2)
generate nbrs_affairs=substr(id, 5, 4)
generate affair_no_v=year_affair+"."+nbrs_affairs

* affair_type_v
generate affair_type_v=1 if affair_type=="Motion"
replace affair_type_v=2 if affair_type=="Postulat"

* legislative_periods_v
generate legislative_periods_v=48 if year==2011 & affair_date<11
replace legislative_periods_v=49 if year==2011 & affair_date>=11
replace legislative_periods_v=49 if year>=2012 & year<=2014
replace legislative_periods_v=49 if year==2015 & affair_date<11
replace legislative_periods_v=50 if year==2015 & affair_date>=11
replace legislative_periods_v=50 if year>=2016 & year<=2018
replace legislative_periods_v=50 if year==2019 & affair_date<11
replace legislative_periods_v=51 if year==2019 & affair_date>=11
replace legislative_periods_v=51 if year>=2020

* Concentrate only on legislative periods: 49 and 50
drop if legislative_periods_v==48

* Merge with vote parliament. Obtain a brand new dataset
clear all 
use data_swissparl_vote, replace

* department_v
generate department_v=1 if department=="ChF"
replace department_v=2 if department=="DDPS"
replace department_v=3 if department=="DEFR"
replace department_v=4 if department=="DETEC"
replace department_v=5 if department=="DFAE"
replace department_v=6 if department=="DFF"
replace department_v=7 if department=="DFI"
replace department_v=8 if department=="DFJP"
replace department_v=9 if department=="Parl"

* commission_v
generate commission_v=1 if commission=="Bu"
replace commission_v=2 if commission=="CAJ" | commission=="RK"
replace commission_v=3 if commission=="CEATE"
replace commission_v=4 if commission=="CER" | commission=="WAK"
replace commission_v=5 if commission=="CIP" | commission=="SPK"
replace commission_v=6 if commission=="CPE"
replace commission_v=7 if commission=="CPS"
replace commission_v=8 if commission=="CSEC" | commission=="WBK"
replace commission_v=9 if commission=="CSSS"
replace commission_v=10 if commission=="CTT" | commission=="KVF"
replace commission_v=11 if commission=="CdF" | commission=="FK"

* Keep Only Nationalrat (because vote in the nationalrat)
drop if council_v==1

* Own party representation
generate own_party=CVP_parl if party_v==1
replace own_party=FDP_parl if party_v==2
replace own_party=SP_parl if party_v==3
replace own_party=SVP_parl if party_v==4
replace own_party=GPS_parl if party_v==5
replace own_party=GLP_parl if party_v==6
replace own_party=BDP_parl if party_v==7
replace own_party=Other_parl if own_party==.






