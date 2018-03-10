#!/bin/bash

# Oppgave: kap 8. lab exercices c) (OBLIG) Page faults
 
# File:   chromemajPF.bash
# Author: Alexander Jakobsen, 16BITSEC, Studentnr: 473151
# E-mail: alexajak@stud.ntnu.no
# Created on Mach 7, 2018, 18:00 AM
# Created with gvim in Ubuntu 16.04.3 LTS


#################### Feilskjekk ####################

#sjekker at det ikke er sendet med argumenter
if [ "$#" -gt 0 ]                         # hvis ant. arg. > 0
 then
   echo "dette skriptet aksepterer ikke argumenter"
   exit 0                                 # avslutt script
 fi

##################### Conster ######################

maxfeil=999 # brukes til aa skrive ut extramelding

################### Funksjoner #####################

#brukes til aa sjekke returverdier paa programm call
function sjekkFeil { 
 if [ "$1" -ne 0  ]      #hvis returverdi fra forige programm != 0
   then                                   # skriv feilmelding
     echo "Noe har gaat galt, proov igjen senere"
     exit 0                               # avslutt script
   fi 
}

###################### Main ########################

#hvis man vil resette hva som er i RAM. så kommenter bort linjen under
# sync ; echo 3 | sudo tee /proc/sys/vm/drop_caches

# start chrome + kast feilmeldingene som altid kommer, i soopla
google-chrome > /dev/null 2>&1 &
e=$?                                      # hent returverdi
sjekkFeil $e                              # sjekk om forrige programm-call lyktes

sleep 4                                   # sov slik at chrome kan staret alle prosseser

a=$( pgrep chrome )                       # hent string med prosess ID-er
e=$?                                      # hent returverdi
sjekkFeil $e                              # sjekk om forrige programm-call lyktes

pid=( $a )                                # konverter array fra a[] til pid[][]

for i in "${pid[@]}";                     #loop gjennom hele array "pid"
 do
   err=$(ps --no-headers -o maj_flt "$i") # hent ant. major feil for prosess ID-en i "$i"
   e=$?                                   # hent returverdi
   sjekkFeil $e                           # sjekk om forrige programm-call lyktes

   string="chrome $i har forasaket $err major page faults"   
   if [ "$err" -gt $maxfeil  ]            # er ant. feil > maxfeil
    then
      string+=" (mer enn $maxfeil!)"      # concatinate 
    fi
   echo "$string"
 done

exit 0                                    # avslutt script


