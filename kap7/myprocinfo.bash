#!/bin/bash


# Oppgave: kap 7. lab exercices a)
# 
# File:   myprocinfo.bash
# Author: Alexander Jakobsen, 16BITSEC, Studentnr: 473151
# E-mail: alexajak@stud.ntnu.no
# Created on Febuary 20, 2018, 17:00 AM
# Created with gvim in Ubuntu 16.04.3 LTS


####################################################

################### Funksjoner #####################

####################################################

function meny {                        #printer meny
 printf "\n"
 echo "1 - Hvem er jeg og hva er navnet paa dette scriptet?"
 echo "2 - Hvor lenge er det siden siste boot?"
 echo "3 - Hvor mange prosesser og traader finnes?"
 echo "4 - Hvor mange context switch'er fant sted siste sekund?"
 echo "5 - Hvor stor andel av CPU-tiden ble benyttet i kernelmode og i usermode siste sekund?"
 echo "6 - Hvor mange interrupts fant sted siste sekund?"
 echo "9 - Avslutt dette scriptet"
 echo "Velg en funksjon:  "
}

#tar et argument og skriver det til consol
function skriv { 
 clear                              # fjern tidliger text fra consol
 echo "$1"                          # print ut arumentet
 sleep 3                            # sov i 3 sek
}

# finner antall hendelser lik $1 fra /proc/stat som har forekommet det siste 1 sek 
# $1 = hva det sookes etter i /proc/stat (f.exs: ctxt)
# $2 = text som forklarer hva det sookes etter (f.exs: contextswitch)
function antSisteSec {
 a=$( grep "$1" /proc/stat | awk '{ print $2}') # hent riktig tall
 sleep 1                                      # sov i 1 sek
 b=$( grep "$1" /proc/stat | awk '{ print $2}') # hent riktig tall
 c=$(echo "$b-$a" | bc )                      # regn ut ant hendelser siste sek
 skriv "antall $2 det siste sekunder er $c"   # print resultat til konsol
}

# finner % andel av CPU tid i user- og kernelmode det siste 1 sek
function modes {
 a=$(grep cpu /proc/stat | awk 'NR<2 { print $2, $4}') # foorste mooling
 u1=$( echo "$a" | awk '{print $1}' ) # hent tall for usermode
 k1=$( echo "$a" | awk '{print $2}' ) # hent tall for kernelmode
 sum1=$(echo "$u1+$k1" | bc  )        # regn ut summtallet for de 2 modene

 sleep 1                              # sov i 1 sek

 b=$(grep cpu /proc/stat | awk 'NR<2 { print $2, $4}') # andre mooling
 u2=$( echo "$b" | awk '{print $1}' ) # hent tall for usermode
 k2=$( echo "$b" | awk '{print $2}' ) # hent tall for kernelmode
 sum2=$(echo "$u2+$k2" | bc  )        # regn ut summtallet for de 2 modene

 u3=$(echo "$u2-$u1" | bc  )          # regn ut antall usermode hendelser siste sek
 k3=$(echo "$k2-$k1" | bc  )          # regn ut antall kernelmode hendelser siste sek
 diff=$(echo "$sum2-$sum1" | bc  )    # regn ut totalt antall hendeser siste sek

 uAndel=$( echo " 100 * $u3/$diff " | bc )  # regn ut % av tid i usermode
 kAndel=$( echo " 100 * $k3/$diff " | bc )  # regn ut % av tid i kernelmode
 
# skriv til consol
 skriv "Det siste sekundet var CPU $uAndel % i usermode og $kAndel % i kernelmode"
 }

####################################################

################## Script Start ####################

####################################################

i="0"                        # set startverdi for $i

while [ $i -ne 9 ]           # kjør så lenge $i ikke er lik 9
do

 meny                         # print meny
 read -r i                    # les brukerinnput
 clear                        # clear conlol

 case "$i" in

 "1") #Hvem er jeg og hva er navnet p˚ a dette scriptet?
       skriv "Jeg er $(whoami), dette skriptet heter $0"
     ;;
 "2") #Hvor lenge er det siden siste boot?
       skriv "System has been $(uptime -p)"
     ;;
 "3") #Hvor mange prosesser og traader finnes? 
       skriv "Det er akurat nå $(ps -AL | wc -l) antall prosesser og traaer kjorende"
     ;;
 "4") #Hvor mange context switcher fant sted siste sekund?
       antSisteSec "ctxt" "contextswitcher"  # se egen funksjon
     ;;
 "5") #Hvor stor andel av CPU-tiden ble benyttet i kernelmode og i usermode siste sekund? 
       modes        # se egen funksjon
     ;;
 "6") #Hvor mange interrupts fant sted siste sekund?
       antSisteSec "intr" "interrupts"       # se egen funksjon
     ;;
 "9") #avslutt script
       clear        # clear consol
       exit 0       # exit fra script med verdi 0
     ;;
  *)  #alle andere innputt en 1-9
     skriv "feil innputverdi"   # feilmeding
     i=0                        # reset verdi tilbake til intiger
     ;;
 esac
done
