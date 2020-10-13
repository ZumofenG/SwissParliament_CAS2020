# ##### BUCH Parlament - Ist Konkordanz noch die Rede Wert?
# ### 1. Setting ---
Sys.setenv(LANG="en")
rm(list=ls())
setwd("/Users/ZumofenG/OneDrive/PhD/Formation/CAS_ADS/M2_StatisticalInference/Project_representationSwissParliament")

# 0. Install packages
library (stringr)
library(stringi)
library(dplyr)
library(tidytext)
library(tm)
library(quanteda)
library(broom)
library(tidyr)
library (tidyverse)
library (tokenizers)
library(tau)
library(nlp)
library(plyr)
library(ggplot2)
library(readxl)
library (gdata)
library(Hmisc)

# 1. Database to import
themen <- readRDS("themen.rds")
ratsvoten <- readRDS("ratsvoten_neu2.rds")
a_details <- readRDS("a_details.rds")
personen <- readRDS("personen.rds")
abstimmungen <- readRDS("abstimmungen.rds")


# 1.1 Set the database - via g_nummer
a_details$a_id_jahr<-substr(a_details$a_id, 1, 4)
a_details$a_id_rest<-str_sub(a_details$a_id, -4,-1)
a_details$a_id_4<-str_sub(a_details$a_id, -4, -4)
a_details$a_id_3<-str_sub(a_details$a_id, -3, -1)
a_details$a_id_rest2<-NA
a_details$a_id_rest2[a_details$a_id_4!=0]<-a_details$a_id_rest[a_details$a_id_4!=0]
a_details$a_id_rest2[a_details$a_id_4==0]<-a_details$a_id_3[a_details$a_id_4==0]
a_details$g_nummer<-paste(a_details$a_id_jahr, a_details$a_id_rest2, sep = ".")

# 1.2 Merge a_details and themen
data_parl <- left_join(a_details, themen, by="g_nummer")
data_parl$Name <- data_parl$a_author_name
data_parl2 <- left_join(data_parl, personen, by="Name")

# 1.3 Prepare dataset
data_object_parl <-subset(data_parl2, a_type=="Motion" | a_type=="Postulat")
data_object_parl$a_id_jahr <- as.integer(data_object_parl$a_id_jahr)
data_swissparl <- subset(data_object_parl, a_id_jahr>=2011 )

# 1.3 Create/Recode some variables
data_swissparl$a_date1 <- substr(data_swissparl$a_date1, 6,7)
                                                                                               
# 1.4 Rename some variables - Delimit a subset (variables of interest)
data_swissparl$id <- data_swissparl$a_id
data_swissparl$affair_title <- data_swissparl$a_title
data_swissparl$affair_type <- data_swissparl$a_type
data_swissparl$name <- data_swissparl$Name
data_swissparl$council <- data_swissparl$a_council
data_swissparl$language <- data_swissparl$a_language
data_swissparl$status <- data_swissparl$a_state
data_swissparl$year <- data_swissparl$a_id_jahr
data_swissparl$affair_number <- data_swissparl$g_nummer
data_swissparl$topics <- data_swissparl$a_themen
data_swissparl$date_join <- data_swissparl$date_join1
data_swissparl$date_leave <- data_swissparl$date_leave1
data_swissparl$party <- data_swissparl$party1
data_swissparl$sex <- data_swissparl$GenderAsString
data_swissparl$canton <- data_swissparl$CantonAbbreviation
data_swissparl$parl_group <- data_swissparl$ParlGroupName
data_swissparl$party_name <- data_swissparl$PartyName
data_swissparl$affair_date <- data_swissparl$a_date1

data_swissparl <- subset(data_swissparl, select=c("id", "status", "year", "sex", "canton", "party", "party_name", "parl_group", "name", "language", "date_join", "date_leave", "council", "affair_number", "affair_type", "affair_title", "affair_date", "topics"))


write.csv(data_swissparl, "data_swissparl.csv")




##########################################



# 1.2 Merge ratsvoten with a_details
voten <- left_join(ratsvoten, a_details, by="g_nummer")
# 1.3 Merge voten with themen
voten <- left_join(voten, themen, by="g_nummer")
# 1.4 Merge voten with personen
voten$Name <- voten$v_person_name
voten <- left_join(voten, personen, by="Name")

# 1.5 Recode some variables
# 1.5.1 Rename political parties
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(C)"]<- "CVP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(-)"]<- "LOS"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="NA"]<- "NO"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz==""]<- "NO"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(L)"]<- "FDP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(G)"]<- "GREEN"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(V)"]<- "SVP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(S)"]<- "SP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(R)"]<- "FDP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(BD)"]<- "BDP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(CE)"]<- "CVP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(E)"]<- "EVP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(GL)"]<- "GLP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(CEg)"]<- "CVP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(RL)"]<- "FDP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(U)"]<- "EVP"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(A)"]<- "Frei"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(F)"]<- "Frei"
voten$v_person_fraktion_kurz[voten$v_person_fraktion_kurz=="(D)"]<- "Lega"
voten$v_person_fraktion_kurz[voten$v_person_rat=="Bundeskanzler"]<- "BK"
voten$v_person_fraktion_kurz[voten$v_person_rat=="Bundesrat"]<- "BR"
voten$party <- voten$v_person_fraktion_kurz

# 1.5.2 Transformer time
voten$time<-voten$d_zeit
voten$time[voten$time=="08h00"]<-"8"
voten$time[voten$time=="08h05"]<-"8"
voten$time[voten$time=="08h10"]<-"8"
voten$time[voten$time=="08h15"]<-"8"
voten$time[voten$time=="08h20"]<-"8"
voten$time[voten$time=="08h25"]<-"8"
voten$time[voten$time=="08h30"]<-"8"
voten$time[voten$time=="08h35"]<-"8"
voten$time[voten$time=="08h40"]<-"8"
voten$time[voten$time=="08h45"]<-"8"
voten$time[voten$time=="08h50"]<-"8"
voten$time[voten$time=="08h55"]<-"8"
voten$time[voten$time=="09h00"]<-"9"
voten$time[voten$time=="09h05"]<-"9"
voten$time[voten$time=="09h10"]<-"9"
voten$time[voten$time=="09h15"]<-"9"
voten$time[voten$time=="09h20"]<-"9"
voten$time[voten$time=="09h25"]<-"9"
voten$time[voten$time=="09h30"]<-"9"
voten$time[voten$time=="09h35"]<-"9"
voten$time[voten$time=="09h40"]<-"9"
voten$time[voten$time=="09h45"]<-"9"
voten$time[voten$time=="09h50"]<-"9"
voten$time[voten$time=="10h00"]<-"10"
voten$time[voten$time=="10h15"]<-"10"
voten$time[voten$time=="10h45"]<-"10"
voten$time[voten$time=="11h00"]<-"11"
voten$time[voten$time=="11h20"]<-"11"
voten$time[voten$time=="11h25"]<-"11"
voten$time[voten$time=="11h30"]<-"11"
voten$time[voten$time=="11h35"]<-"11"
voten$time[voten$time=="13h00"]<-"13"
voten$time[voten$time=="13h40"]<-"13"
voten$time[voten$time=="13h45"]<-"13"
voten$time[voten$time=="14h00"]<-"14"
voten$time[voten$time=="14h15"]<-"14"
voten$time[voten$time=="14h30"]<-"14"
voten$time[voten$time=="14h40"]<-"14"
voten$time[voten$time=="14h45"]<-"14"
voten$time[voten$time=="14h50"]<-"14"
voten$time[voten$time=="15h00"]<-"15"
voten$time[voten$time=="15h05"]<-"15"
voten$time[voten$time=="15h15"]<-"15"
voten$time[voten$time=="15h30"]<-"15"
voten$time[voten$time=="15h45"]<-"15"
voten$time[voten$time=="16h00"]<-"16"
voten$time[voten$time=="16h15"]<-"16"
voten$time[voten$time=="16h30"]<-"16"
voten$time[voten$time=="16h45"]<-"16"
voten$time[voten$time=="17h00"]<-"17"
voten$time[voten$time=="17h15"]<-"17"
voten$time[voten$time=="17h30"]<-"17"
voten$time[voten$time=="18h15"]<-"18"

voten$time_2<-voten$time
voten$time_2[voten$time_2=="8"]<-"am"
voten$time_2[voten$time_2=="9"]<-"am"
voten$time_2[voten$time_2=="10"]<-"am"
voten$time_2[voten$time_2=="11"]<-"am"
voten$time_2[voten$time_2=="13"]<-"pm"
voten$time_2[voten$time_2=="14"]<-"pm"
voten$time_2[voten$time_2=="15"]<-"pm"
voten$time_2[voten$time_2=="16"]<-"pm"
voten$time_2[voten$time_2=="17"]<-"pm"
voten$time_2[voten$time_2=="18"]<-"pm"

# 1.5.3 Transform conseil
voten$council <- voten$d_rat

# 1.5.4 Transform sitzung
voten$meeting <- voten$g_sitzung
str_replace(voten$meeting, "[ö]", "o")
voten$meeting[voten$meeting=="Erste Sitzung"] <- 1
voten$meeting[voten$meeting=="Zweite Sitzung"] <- 2
voten$meeting[voten$meeting=="Dritte Sitzung"] <- 3
voten$meeting[voten$meeting=="Vierte Sitzung"] <- 4
voten$meeting[voten$meeting=="Funfte Sitzung"] <- 5
voten$meeting[voten$meeting=="Sechste Sitzung"] <- 6
voten$meeting[voten$meeting=="Siebte Sitzung"] <- 7
voten$meeting[voten$meeting=="Achte Sitzung"] <- 8
voten$meeting[voten$meeting=="Neunte Sitzung"] <- 9
voten$meeting[voten$meeting=="Zehnte Sitzung"] <- 10
voten$meeting[voten$meeting=="Elfte Sitzung"] <- 11
voten$meeting[voten$meeting=="Zwolfte Sitzung"] <- 12
voten$meeting[voten$meeting=="Dreizehnte Sitzung"] <- 13
voten$meeting[voten$meeting=="Vierzehnte Sitzung"] <- 14
voten$meeting[voten$meeting=="Fünfzehnte Sitzung"] <- 15
voten$meeting[voten$meeting=="Sechzehnte Sitzung"] <- 16
voten$meeting[voten$meeting=="Siebzehnte Sitzung"] <- 17
voten$meeting[voten$meeting=="Achtzehnte Sitzung"] <- 18
voten$meeting[voten$meeting=="Neunzehnte Sitzung"] <- 19
voten$meeting[voten$meeting=="Zwanzigste Sitzung"] <- 20
voten$meeting[voten$meeting=="Einundzwanzigste Sitzung"] <- 21
voten$meeting[voten$meeting=="Zweiundzwanzigste Sitzung"] <- 22
voten$meeting[voten$meeting=="Dreiundzwanzigste Sitzung"] <- 23

# 1.5.5 Transform person
voten$person_council<-voten$v_person_rat
voten$person_president<-voten$v_person_praesident
voten$person_council[voten$person_council=="Nationalrat"]<-"NR"
voten$person_council[voten$person_council=="Stnderat"]<-"SR"
voten$person_council[voten$person_council=="Bundesrat"]<-"BR"
voten$person_council[voten$person_council=="Bundeskanzler"]<-"BK"

# 1.5.6 Transform date
voten$date<-voten$d_datum

# 1.5.7 Transform canton
voten$canton <- voten$v_person_kanton
voten$canton[voten$canton=="Aargau"]<-"AG"
voten$canton[voten$canton=="Appenzell A.-Rh."]<-"AR"
voten$canton[voten$canton=="Appenzell I.-Rh."]<-"AI"
voten$canton[voten$canton=="Basel-Landschaft"]<-"BL"
voten$canton[voten$canton=="Basel-Stadt"]<-"BS"
voten$canton[voten$canton=="Bern"]<-"BE"
voten$canton[voten$canton=="Freiburg"]<-"FR"
voten$canton[voten$canton=="Genf"]<-"GE"
voten$canton[voten$canton=="Glarus"]<-"GL"
voten$canton[voten$canton=="Graubunden"]<-"GR"
voten$canton[voten$canton=="Jura"]<-"JU"
voten$canton[voten$canton=="Luzern"]<-"LU"
voten$canton[voten$canton=="Neuenburg"]<-"NE"
voten$canton[voten$canton=="Nidwalden"]<-"NW"
voten$canton[voten$canton=="Obwalden"]<-"OW"
voten$canton[voten$canton=="Schaffhausen"]<-"SH"
voten$canton[voten$canton=="Schwyz"]<-"SZ"
voten$canton[voten$canton=="Solothurn"]<-"SO"
voten$canton[voten$canton=="St. Gallen"]<-"SG"
voten$canton[voten$canton=="Tessin"]<-"TI"
voten$canton[voten$canton=="Thurgau"]<-"TG"
voten$canton[voten$canton=="Uri"]<-"UR"
voten$canton[voten$canton=="Waadt"]<-"VD"
voten$canton[voten$canton=="Wallis"]<-"VS"
voten$canton[voten$canton=="Zug"]<-"ZG"
voten$canton[voten$canton=="Zurich"]<-"ZH"
voten$canton[voten$canton=="NA"]<-"BR"

# 1.5.8 Transform session
voten$year<-voten$d_session
voten$year[voten$year=="Sondersession August 1999"]<-"1999"
voten$year[voten$year=="Sondersession November 2001"]<-"2001"
voten$year[voten$year=="Sondersession Januar 1998"]<-"1998"
voten$year[voten$year=="Sondersession Januar 1995"]<-"1995"
voten$year[voten$year=="Sondersession April 1999"]<-"1999"
voten$year[voten$year=="Sondersession April 1998"]<-"1998"
voten$year[voten$year=="Sondersession April 1997"]<-"1997"
voten$year[voten$year=="Fruehjahrssession 1995"]<-"1995"
voten$year[voten$year=="Sommersession 1995"]<-"1995"
voten$year[voten$year=="Herbstsession 1995"]<-"1995"
voten$year[voten$year=="Wintersession 1995"]<-"1995"
voten$year[voten$year=="Fruehjahrssession 1996"]<-"1996"
voten$year[voten$year=="Sommersession 1996"]<-"1996"
voten$year[voten$year=="Herbstsession 1996"]<-"1996"
voten$year[voten$year=="Wintersession 1996"]<-"1996"
voten$year[voten$year=="Fruehjahrssession 1997"]<-"1997"
voten$year[voten$year=="Sommersession 1997"]<-"1997"
voten$year[voten$year=="Herbstsession 1997"]<-"1997"
voten$year[voten$year=="Wintersession 1997"]<-"1997"
voten$year[voten$year=="Fruehjahrssession 1998"]<-"1998"
voten$year[voten$year=="Sommersession 1998"]<-"1998"
voten$year[voten$year=="Herbstsession 1998"]<-"1998"
voten$year[voten$year=="Wintersession 1998"]<-"1998"
voten$year[voten$year=="Fruehjahrssession 1999"]<-"1999"
voten$year[voten$year=="Sommersession 1999"]<-"1999"
voten$year[voten$year=="Herbstsession 1999"]<-"1999"
voten$year[voten$year=="Wintersession 1999"]<-"1999"
voten$year[voten$year=="Fruehjahrssession 2000"]<-"2000"
voten$year[voten$year=="Sommersession 2000"]<-"2000"
voten$year[voten$year=="Herbstsession 2000"]<-"2000"
voten$year[voten$year=="Wintersession 2000"]<-"2000"
voten$year[voten$year=="Fruehjahrssession 2001"]<-"2001"
voten$year[voten$year=="Sommersession 2001"]<-"2001"
voten$year[voten$year=="Herbstsession 2001"]<-"2001"
voten$year[voten$year=="Wintersession 2001"]<-"2001"
voten$year[voten$year=="Fruehjahrssession 2002"]<-"2002"
voten$year[voten$year=="Sommersession 2002"]<-"2002"
voten$year[voten$year=="Herbstsession 2002"]<-"2002"
voten$year[voten$year=="Wintersession 2002"]<-"2002"
voten$year[voten$year=="Fruehjahrssession 2003"]<-"2003"
voten$year[voten$year=="Sommersession 2003"]<-"2003"
voten$year[voten$year=="Herbstsession 2003"]<-"2003"
voten$year[voten$year=="Wintersession 2003"]<-"2003"
voten$year[voten$year=="Fruehjahrssession 2004"]<-"2004"
voten$year[voten$year=="Sommersession 2004"]<-"2004"
voten$year[voten$year=="Herbstsession 2004"]<-"2004"
voten$year[voten$year=="Wintersession 2004"]<-"2004"
voten$year[voten$year=="Fruehjahrssession 2005"]<-"2005"
voten$year[voten$year=="Sommersession 2005"]<-"2005"
voten$year[voten$year=="Herbstsession 2005"]<-"2005"
voten$year[voten$year=="Wintersession 2005"]<-"2005"
voten$year[voten$year=="Fruehjahrssession 2006"]<-"2006"
voten$year[voten$year=="Sommersession 2006"]<-"2006"
voten$year[voten$year=="Herbstsession 2006"]<-"2006"
voten$year[voten$year=="Wintersession 2006"]<-"2006"
voten$year[voten$year=="Fruehjahrssession 2007"]<-"2007"
voten$year[voten$year=="Sommersession 2007"]<-"2007"
voten$year[voten$year=="Herbstsession 2007"]<-"2007"
voten$year[voten$year=="Wintersession 2007"]<-"2007"
voten$year[voten$year=="Fruehjahrssession 2008"]<-"2008"
voten$year[voten$year=="Sommersession 2008"]<-"2008"
voten$year[voten$year=="Herbstsession 2008"]<-"2008"
voten$year[voten$year=="Wintersession 2008"]<-"2008"
voten$year[voten$year=="Fruehjahrssession 2009"]<-"2009"
voten$year[voten$year=="Sommersession 2009"]<-"2009"
voten$year[voten$year=="Herbstsession 2009"]<-"2009"
voten$year[voten$year=="Wintersession 2009"]<-"2009"
voten$year[voten$year=="Fruehjahrssession 2010"]<-"2010"
voten$year[voten$year=="Sommersession 2010"]<-"2010"
voten$year[voten$year=="Herbstsession 2010"]<-"2010"
voten$year[voten$year=="Wintersession 2010"]<-"2010"
voten$year[voten$year=="Fruehjahrssession 2011"]<-"2011"
voten$year[voten$year=="Sommersession 2011"]<-"2011"
voten$year[voten$year=="Herbstsession 2011"]<-"2011"
voten$year[voten$year=="Wintersession 2011"]<-"2011"
voten$year[voten$year=="Fruehjahrssession 2012"]<-"2012"
voten$year[voten$year=="Sommersession 2012"]<-"2012"
voten$year[voten$year=="Herbstsession 2012"]<-"2012"
voten$year[voten$year=="Wintersession 2012"]<-"2012"
voten$year[voten$year=="Fruehjahrssession 2013"]<-"2013"
voten$year[voten$year=="Sommersession 2013"]<-"2013"
voten$year[voten$year=="Herbstsession 2013"]<-"2013"
voten$year[voten$year=="Wintersession 2013"]<-"2013"
voten$year[voten$year=="Fruehjahrssession 2014"]<-"2014"
voten$year[voten$year=="Sommersession 2014"]<-"2014"
voten$year[voten$year=="Herbstsession 2014"]<-"2014"
voten$year[voten$year=="Wintersession 2014"]<-"2014"
voten$year[voten$year=="Fruehjahrssession 2015"]<-"2015"
voten$year[voten$year=="Sommersession 2015"]<-"2015"
voten$year[voten$year=="Herbstsession 2015"]<-"2015"
voten$year[voten$year=="Wintersession 2015"]<-"2015"
voten$year[voten$year=="Fruehjahrssession 2016"]<-"2016"
voten$year[voten$year=="Sommersession 2016"]<-"2016"
voten$year[voten$year=="Herbstsession 2016"]<-"2016"
voten$year[voten$year=="Wintersession 2016"]<-"2016"
voten$year[voten$year=="Fruehjahrssession 2017"]<-"2017"
voten$year[voten$year=="Sommersession 2017"]<-"2017"
voten$year[voten$year=="Herbstsession 2017"]<-"2017"
voten$year[voten$year=="Wintersession 2017"]<-"2017"
voten$year[voten$year=="Fruehjahrssession 2018"]<-"2018"
voten$year[voten$year=="Sondersession April 2002"]<-"2002"
voten$year[voten$year=="Sondersession April 2008"]<-"2008"
voten$year[voten$year=="Sondersession April 2009"]<-"2009"
voten$year[voten$year=="Sondersession April 2011"]<-"2011"
voten$year[voten$year=="Sondersession April 2013"]<-"2013"
voten$year[voten$year=="Sondersession April 2016"]<-"2016"
voten$year[voten$year=="Sondersession August 2009"]<-"2009"
voten$year[voten$year=="Sondersession Mai 2001"]<-"2001"
voten$year[voten$year=="Ausserordentliche Session November 2001"]<-"2001"
voten$year[voten$year=="Sondersession Mai 2003"]<-"2003"
voten$year[voten$year=="Sondersession Mai 2004"]<-"2004"
voten$year[voten$year=="Sondersession Mai 2006"]<-"2006"
voten$year[voten$year=="Sondersession Mai 2012"]<-"2012"
voten$year[voten$year=="Sondersession Mai 2014"]<-"2014"
voten$year[voten$year=="Sondersession Mai 2015"]<-"2015"
voten$year[voten$year=="Sondersession Mai 2017"]<-"2017"

# 1.7 Transform session - Cut at the session level (not year level)

voten$u_session<-voten$d_session
voten$u_session[voten$u_session=="Sondersession Januar 1995"]<-"1"
voten$u_session[voten$u_session=="Fruehjahrssession 1995"]<-"2"
voten$u_session[voten$u_session=="Sommersession 1995"]<-"3"
voten$u_session[voten$u_session=="Herbstsession 1995"]<-"4"
voten$u_session[voten$u_session=="Wintersession 1995"]<-"5"
voten$u_session[voten$u_session=="Fruehjahrssession 1996"]<-"6"
voten$u_session[voten$u_session=="Sommersession 1996"]<-"7"
voten$u_session[voten$u_session=="Herbstsession 1996"]<-"8"
voten$u_session[voten$u_session=="Wintersession 1996"]<-"9"
voten$u_session[voten$u_session=="Fruehjahrssession 1997"]<-"10"
voten$u_session[voten$u_session=="Sondersession April 1997"]<-"11"
voten$u_session[voten$u_session=="Sommersession 1997"]<-"12"
voten$u_session[voten$u_session=="Herbstsession 1997"]<-"13"
voten$u_session[voten$u_session=="Wintersession 1997"]<-"14"
voten$u_session[voten$u_session=="Sondersession Januar 1998"]<-"15"
voten$u_session[voten$u_session=="Fruehjahrssession 1998"]<-"16"
voten$u_session[voten$u_session=="Sondersession April 1998"]<-"17"
voten$u_session[voten$u_session=="Sommersession 1998"]<-"18"
voten$u_session[voten$u_session=="Herbstsession 1998"]<-"19"
voten$u_session[voten$u_session=="Wintersession 1998"]<-"20"
voten$u_session[voten$u_session=="Fruehjahrssession 1999"]<-"21"
voten$u_session[voten$u_session=="Sondersession April 1999"]<-"22"
voten$u_session[voten$u_session=="Sommersession 1999"]<-"23"
voten$u_session[voten$u_session=="Sondersession August 1999"]<-"24"
voten$u_session[voten$u_session=="Herbstsession 1999"]<-"25"
voten$u_session[voten$u_session=="Wintersession 1999"]<-"26"
voten$u_session[voten$u_session=="Fruehjahrssession 2000"]<-"27"
voten$u_session[voten$u_session=="Sommersession 2000"]<-"28"
voten$u_session[voten$u_session=="Herbstsession 2000"]<-"29"
voten$u_session[voten$u_session=="Wintersession 2000"]<-"30"
voten$u_session[voten$u_session=="Fruehjahrssession 2001"]<-"31"
voten$u_session[voten$u_session=="Sondersession Mai 2001"]<-"32"
voten$u_session[voten$u_session=="Sommersession 2001"]<-"33"
voten$u_session[voten$u_session=="Herbstsession 2001"]<-"34"
voten$u_session[voten$u_session=="Sondersession November 2001"]<-"35"
voten$u_session[voten$u_session=="Ausserordentliche Session November 2001"]<-"36"
voten$u_session[voten$u_session=="Wintersession 2001"]<-"37"
voten$u_session[voten$u_session=="Fruehjahrssession 2002"]<-"38"
voten$u_session[voten$u_session=="Sondersession April 2002"]<-"39"
voten$u_session[voten$u_session=="Sommersession 2002"]<-"40"
voten$u_session[voten$u_session=="Herbstsession 2002"]<-"41"
voten$u_session[voten$u_session=="Wintersession 2002"]<-"42"
voten$u_session[voten$u_session=="Fruehjahrssession 2003"]<-"43"
voten$u_session[voten$u_session=="Sondersession Mai 2003"]<-"44"
voten$u_session[voten$u_session=="Sommersession 2003"]<-"45"
voten$u_session[voten$u_session=="Herbstsession 2003"]<-"46"
voten$u_session[voten$u_session=="Wintersession 2003"]<-"47"
voten$u_session[voten$u_session=="Fruehjahrssession 2004"]<-"48"
voten$u_session[voten$u_session=="Sondersession Mai 2004"]<-"49"
voten$u_session[voten$u_session=="Sommersession 2004"]<-"50"
voten$u_session[voten$u_session=="Herbstsession 2004"]<-"51"
voten$u_session[voten$u_session=="Wintersession 2004"]<-"52"
voten$u_session[voten$u_session=="Fruehjahrssession 2005"]<-"53"
voten$u_session[voten$u_session=="Sommersession 2005"]<-"54"
voten$u_session[voten$u_session=="Herbstsession 2005"]<-"55"
voten$u_session[voten$u_session=="Wintersession 2005"]<-"56"
voten$u_session[voten$u_session=="Fruehjahrssession 2006"]<-"57"
voten$u_session[voten$u_session=="Sondersession Mai 2006"]<-"58"
voten$u_session[voten$u_session=="Sommersession 2006"]<-"59"
voten$u_session[voten$u_session=="Herbstsession 2006"]<-"60"
voten$u_session[voten$u_session=="Wintersession 2006"]<-"61"
voten$u_session[voten$u_session=="Fruehjahrssession 2007"]<-"62"
voten$u_session[voten$u_session=="Sommersession 2007"]<-"63"
voten$u_session[voten$u_session=="Herbstsession 2007"]<-"64"
voten$u_session[voten$u_session=="Wintersession 2007"]<-"65"
voten$u_session[voten$u_session=="Fruehjahrssession 2008"]<-"66"
voten$u_session[voten$u_session=="Sondersession April 2008"]<-"67"
voten$u_session[voten$u_session=="Sommersession 2008"]<-"68"
voten$u_session[voten$u_session=="Herbstsession 2008"]<-"69"
voten$u_session[voten$u_session=="Wintersession 2008"]<-"70"
voten$u_session[voten$u_session=="Fruehjahrssession 2009"]<-"71"
voten$u_session[voten$u_session=="Sondersession April 2009"]<-"72"
voten$u_session[voten$u_session=="Sommersession 2009"]<-"73"
voten$u_session[voten$u_session=="Sondersession August 2009"]<-"74"
voten$u_session[voten$u_session=="Herbstsession 2009"]<-"75"
voten$u_session[voten$u_session=="Wintersession 2009"]<-"76"
voten$u_session[voten$u_session=="Fruehjahrssession 2010"]<-"77"
voten$u_session[voten$u_session=="Sommersession 2010"]<-"78"
voten$u_session[voten$u_session=="Herbstsession 2010"]<-"79"
voten$u_session[voten$u_session=="Wintersession 2010"]<-"80"
voten$u_session[voten$u_session=="Fruehjahrssession 2011"]<-"81"
voten$u_session[voten$u_session=="Sondersession April 2011"]<-"82"
voten$u_session[voten$u_session=="Sommersession 2011"]<-"83"
voten$u_session[voten$u_session=="Herbstsession 2011"]<-"84"
voten$u_session[voten$u_session=="Wintersession 2011"]<-"85"
voten$u_session[voten$u_session=="Fruehjahrssession 2012"]<-"86"
voten$u_session[voten$u_session=="Sondersession Mai 2012"]<-"87"
voten$u_session[voten$u_session=="Sommersession 2012"]<-"88"
voten$u_session[voten$u_session=="Herbstsession 2012"]<-"89"
voten$u_session[voten$u_session=="Wintersession 2012"]<-"90"
voten$u_session[voten$u_session=="Fruehjahrssession 2013"]<-"91"
voten$u_session[voten$u_session=="Sondersession April 2013"]<-"92"
voten$u_session[voten$u_session=="Sommersession 2013"]<-"93"
voten$u_session[voten$u_session=="Herbstsession 2013"]<-"94"
voten$u_session[voten$u_session=="Wintersession 2013"]<-"95"
voten$u_session[voten$u_session=="Fruehjahrssession 2014"]<-"96"
voten$u_session[voten$u_session=="Sondersession Mai 2014"]<-"97"
voten$u_session[voten$u_session=="Sommersession 2014"]<-"98"
voten$u_session[voten$u_session=="Herbstsession 2014"]<-"99"
voten$u_session[voten$u_session=="Wintersession 2014"]<-"100"
voten$u_session[voten$u_session=="Fruehjahrssession 2015"]<-"101"
voten$u_session[voten$u_session=="Sondersession Mai 2015"]<-"102"
voten$u_session[voten$u_session=="Sommersession 2015"]<-"103"
voten$u_session[voten$u_session=="Herbstsession 2015"]<-"104"
voten$u_session[voten$u_session=="Wintersession 2015"]<-"105"
voten$u_session[voten$u_session=="Fruehjahrssession 2016"]<-"106"
voten$u_session[voten$u_session=="Sondersession April 2016"]<-"107"
voten$u_session[voten$u_session=="Sommersession 2016"]<-"108"
voten$u_session[voten$u_session=="Herbstsession 2016"]<-"109"
voten$u_session[voten$u_session=="Wintersession 2016"]<-"110"
voten$u_session[voten$u_session=="Fruehjahrssession 2017"]<-"111"
voten$u_session[voten$u_session=="Sondersession Mai 2017"]<-"112"
voten$u_session[voten$u_session=="Sommersession 2017"]<-"113"
voten$u_session[voten$u_session=="Herbstsession 2017"]<-"114"
voten$u_session[voten$u_session=="Wintersession 2017"]<-"115"
voten$u_session[voten$u_session=="Fruehjahrssession 2018"]<-"116"

# 1.8 Rename variables (to make it readable and understandable)
voten$sex <- voten$GenderAsString
voten$name <- voten$Name
voten$themen <- voten$a_themen2
voten$type <- voten$a_type
voten$title <- voten$a_title
voten$language <- voten$v_sprache
voten$text <- voten$v_text
voten$number <- voten$g_nummer
voten$session <- voten$d_session
names(voten)[19:22] <- c("president", "v_sprache", "ncharacters", "nwords")

describe(voten$language)

# 1.8 Drop useless columns
voten <- subset(voten, select=c(name, sex, canton, party, party1, person_council, president, number, title, language, text, year, session, date, council, time, time_2, meeting, session, u_session, themen, nwords, ncharacters, a_state))

# 1.9 Save dataset
saveRDS(voten, "voten.rds")

# 2. Preprocess texts
# 2.1 Subset Language
voten_fr <- subset(voten, language=="french")
voten_ge <- subset(voten, language=="german")
voten_it <- subset(voten, language=="italian")

# 2.2 Download dictionaries
dico_fr <- dictionary(file="French_LIWC2007_Dictionary.dic", format="LIWC", tolower)
dico_ge <- dictionary(file="German_LIWC2001_Dictionary.dic", format="LIWC", tolower)
dico_it <- dictionary(file="Italian_LIWC2007_Dictionary.dic", format="LIWC", tolower)

# 2.3 Remove punctuation
removePunctuation(voten_fr$text, preserve_intra_word_contractions = TRUE, preserve_intra_word_dashes = TRUE)
removePunctuation(voten_ge$text, preserve_intra_word_contractions = TRUE, preserve_intra_word_dashes = TRUE)
removePunctuation(voten_it$text, preserve_intra_word_contractions = TRUE, preserve_intra_word_dashes = TRUE)

# 3. Dictionary - DFM lookup
# 3.1 French
voten_fr_dfm <- dfm(voten_fr$text, tolower=TRUE, stem=FALSE)
voten_fr_liwc <- dfm_lookup(voten_fr_dfm, dico_fr, valuetype=c("fixed"))
voten_fr_liwc <- as.data.frame(voten_fr_liwc)
voten_fr_liwc$id <- row.names(voten_fr_liwc)
voten_fr$id <- row.names(voten_fr_liwc)
voten_fr_score <- left_join(voten_fr, voten_fr_liwc, by="id")
voten_fr_score2 <- voten_fr_score

# 3.2 German
voten_ge_dfm <- dfm(voten_ge$text, tolower=TRUE, stem=FALSE)
voten_ge_liwc <- dfm_lookup(voten_ge_dfm, dico_ge, valuetype=c("fixed"))
voten_ge_liwc <- as.data.frame(voten_ge_liwc)
voten_ge_liwc$id <- row.names(voten_ge_liwc)
voten_ge$id <- row.names(voten_ge_liwc)
voten_ge_score <- left_join(voten_ge, voten_ge_liwc, by="id")

# 3.3 Italian
voten_it_dfm <- dfm(voten_it$text, tolower=TRUE, stem=FALSE)
voten_it_liwc <- dfm_lookup(voten_it_dfm, dico_it, valuetype=c("fixed"))
voten_it_liwc <- as.data.frame(voten_it_liwc)
voten_it_liwc$id <- row.names(voten_it_liwc)
voten_it$id <- row.names(voten_it_liwc)
voten_it_score <- left_join(voten_it, voten_it_liwc, by="id")

# 3.4 Tri columns
# FR
voten_fr_score <- subset(voten_fr_score, select=c(name, sex, canton, party, party1, person_council, president, number, title, language, text, year, session, date, council, time, time_2, meeting, session, u_session, themen, nwords, ncharacters, je, nous, vous))
voten_fr_score2 <- subset(voten_fr_score, select=c(name, sex, canton, party, party1, person_council, president, number, title, language, text, year, session, date, council, time, time_2, meeting, session, u_session, themen, nwords, ncharacters, je, nous, vous))

# GER
voten_ge_score$je <- voten_ge_score$I
voten_ge_score$nous <- voten_ge_score$We
voten_ge_score$vous <- voten_ge_score$You
voten_ge_score$negate <- voten_ge_score$Negate
voten_ge_score$council [voten_ge_score$council=="St<U+00E4>nderat"] <- ""
voten_ge_score <- subset(voten_ge_score, select=c(name, sex, canton, party, party1, person_council, president, number, title, language, text, year, session, date, council, time, time_2, meeting, session, u_session, themen, nwords, ncharacters, je, nous, vous))

# IT
voten_it_score$je <- voten_it_score$Io
voten_it_score$nous <- voten_it_score$Noi
voten_it_score$vous <- voten_it_score$Tu
voten_it_score$negate <- voten_it_score$Negazio
voten_it_score <- subset(voten_it_score, select=c(name, sex, canton, party, party1, person_council, president, number, title, language, text, year, session, date, council, time, time_2, meeting, session, u_session, themen, nwords, ncharacters, je, nous, vous))

# 4. Aggregate dataset together
voten <- rbind (voten_fr_score, voten_ge_score)
voten <- rbind (voten, voten_it_score)

saveRDS(voten, "voten.rds")


# 5. Calculations
# 5.1 Introduction
words_council <- aggregate(voten, by=list(voten$council), FUN=mean)
words_council <- aggregate(voten, by=list(voten$council, voten$language), FUN=mean)
words_party <- aggregate(voten, by=list(voten$party), FUN=mean)
words_sex <- aggregate(voten, by=list(voten$sex), FUN=mean)
words_time <- aggregate(voten, by=list(voten$time), FUN=mean)
words <- aggregate(voten, by=list(voten$number), FUN=mean)

# 5.2 Results
score_year <- aggregate (voten, by=list(voten$year), FUN=mean)
score_party <- aggregate(voten, by=list(voten$party, voten$year), FUN=mean)
score_name <- aggregate (voten, by=list(voten$name, voten$year), FUN=mean)
score_themen <- aggregate (voten, by=list(voten$themen, voten$year), FUN=mean)
score_council <- aggregate (voten, by=list(voten$council, voten$year), FUN=mean)
score_sex <- aggregate (voten, by=list(voten$sex, voten$year), FUN=mean)
score_canton <- aggregate (voten, by=list(voten$canton, voten$year), FUN=mean)
score_session <- aggregate (voten, by=list(voten$u_session), FUN=mean)
score_themen_council <- aggregate (voten, by=list(voten$themen, voten$council), FUN=mean)
score_object_council <- aggregate (voten, by=list(voten$number, voten$council), FUN=mean)
score_themen_council_year <- aggregate (voten, by=list(voten$themen, voten$council, voten$year), FUN=mean)
score_name_council <- aggregate (voten, by=list(voten$name, voten$council), FUN=mean)
score_party_themen <- aggregate(voten, by=list(voten$party, voten$themen), FUN=mean)
score_party_council_year <- aggregate (voten, by=list(voten$party, voten$council, voten$year), FUN=mean)
score_objectfr <- aggregate (voten_fr_score2, by=list(voten_fr_score2$number), FUN=mean)
score_partyfr <- aggregate(voten_fr_score2, by=list(voten_fr_score2$party, voten_fr_score2$year), FUN=mean)
score_namefr <- aggregate (voten_fr_score2, by=list(voten_fr_score2$name, voten_fr_score2$year), FUN=mean)
score_themenfr <- aggregate (voten_fr_score2, by=list(voten_fr_score2$themen, voten_fr_score2$year), FUN=mean)
score_councilfr <- aggregate (voten_fr_score2, by=list(voten_fr_score2$council, voten_fr_score2$year), FUN=mean)
score_party_themen <- aggregate(voten, by=list(voten$party, voten$themen), FUN=mean))

score_themen_test <- aggregate (voten, by=list(voten$themen, voten$canton), FUN=mean)

write.csv(score_year, file="score_year.csv")
write.csv(score_session, file="score_session.csv")
write.csv(score_party, file="score_party.csv")
write.csv(score_themen, file="score_themen.csv")
write.csv(score_council, file="score_council.csv")
write.csv(score_sex, file="score_sex.csv")
write.csv(score_canton, file="score_canton.csv")
write.csv(score_themen_council, file="score_themen_council.csv")
write.csv(score_object_council, file="score_object_council.csv")
write.csv(score_party_council, file="score_party_council.csv")
write.csv(score_object, file="score_object.csv")
write.csv(score_objectfr, file="socre_objectfr.csv")
write.csv(score_namefr, file="socre_namefr.csv")
write.csv(score_partyfr, file="socre_partyfr.csv")
write.csv(score_themenfr, file="socre_themenfr.csv")
write.csv(score_councilfr, file="socre_councilfr.csv")
write.csv(score_party_themen, file="score_party_themen.csv")









##################################################################

voten <- readRDS("voten.rds")


voten_stata <- subset(voten_it_score, select=c(name, sex, canton, party, party1, person_council, president, number, title, language, year, session, date, council, time, time_2, meeting, session, themen, nwords, ncharacters, je, nous, vous, negate))
write.csv(voten, "voten_stata.csv")

voten_words <- unnest_tokens(voten, words, text, token="words", format=c("text"), to_lower=TRUE)


# 5. Calculations



##########
write.csv(ratsvoten, file="ratsvoten.csv")

# Define legislature
data_swissparl$a_date1 <- as.integer(data_swissparl$a_date1)
data_swissparl$legislative_periods <- ifelse ((data_swissparl$a_date1<11)&(data_swissparl$a_id_jahr==2011), 48, ifelse((data_swissparl$a_date1>=11)&(data_swissparl$a_id_jahr==2011), 49, ifelse((data_swissparl$a_id_jahr==2012)|(data_swissparl$a_id_jahr==2013)|(data_swissparl$a_id_jahr==2014), 49, ifelse(data_swissparl$a_id_date<11)&(data_swissparl$a_id_jahr==2015), 49, 99)))

ifelse(data_swissparl$a_id_date<11)&(data_swissparl$a_id_jahr==2015), 49, ifelse(data_swissparl$a_id_date>=11)&(data_swissparl$a_id_jahr==2015), 50, ifelse(data_swissparl$a_id_jahr==2016), 50, ifelse(data_swissparl$a_id_jahr==2017), 50, ifelse(data_swissparl$a_id_jahr==2018), 50, ifelse(data_swissparl$a_id_date<11)&(data_swissparl$a_id_jahr==2019), 50, ifelse(data_swissparl$a_id_date>=11)&(data_swissparl$a_id_jahr==2019), 51, ifelse(a_id_jahr==2020), 51, 99)))))))))))))   
