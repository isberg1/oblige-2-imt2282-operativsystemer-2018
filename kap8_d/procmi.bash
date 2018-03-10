#!/bin/bash

#################### Feilskjekk ####################

if [ "$#" -gt 0  ]                             #hvis det er sendt med argumenter
 then
  pid=( "$@" )                                 #kopier arg. til egen variabel
else
  echo "mangler ProsessID argument"            #feilmelding
  exit 0                                       #avslutt scrip
fi

################### Funksjoner #####################

#brukes til aa sjekke returverdier paa programm call

function sjekkFeil {
  if [ "$1" -ne 0  ]                           #hvis returverdi fra forige programm != 0
    then                                       #skriv feilmelding
      echo "Noe har gaat galt, proov igjen senere"
      exit 0                                   # avslutt script
   fi
}


function hentOgSkrivData {
 name="$1"                                     #kopier arg. til egen variabel

 proc=$(cat "/proc/$name/status")              #hent data fra fil
 e="$?"                                        #finn returverdi
 sjekkFeil $e                                  #se om forrige programmkal lyktes

# hent ut all relevant data og legg det i egne variable
 vmSize=$(echo "$proc" | grep -i vmsize | awk '{print $2}')
 vmData=$(echo "$proc" | grep -i vmData | awk '{print $2}')
 vmStk=$( echo "$proc" | grep -i vmStk | awk '{print $2}')
 vmExe=$( echo "$proc" | grep -i vmExe | awk '{print $2}')
 privVirtueltMinne=$(echo "$vmData + $vmStk + $vmExe" | bc ) #regn ut summ av flere data
 vmLib=$( echo "$proc" | grep -i vmLib | awk '{print $2}')
 vmRSS=$( echo "$proc" | grep -i vmRSS | awk '{print $2}')
 vmPTE=$( echo "$proc" | grep -i vmPTE | awk '{print $2}')

 now=$(date +%d_%m_%y-%H.%M.%S)                #lag en datomerket streng
 touch "$name"-"$now"                          #lag en fil bestaaende av 2 variabelnavn
 e="$?"                                        #finn returverdi
 sjekkFeil $e                                  #se om forrige programmkal lykktes


 if [ -f ./"$name"-"$now" ];                   #hvis filen finnes
  then
   {                                           #skriv all data til fil
    echo "******** Minne info om prosess med PID $name ********";
    echo "Total bruk av virtuelt minne (VmSize): $vmSize KB";
    echo "Mengde privat virtuelt minne (VmData+VmStk+VmExe): $privVirtueltMinne KB";
    echo "Mengde shared virtuelt minne (VmLib): $vmLib KB";
    echo "Total bruk av fysisk minne (VmRSS): $vmRSS KB";
    echo "Mengde fysisk minne som benyttes til page table (VmPTE): $vmPTE KB"; 
  } >> "$name"-"$now"
  else 
    echo "finner ikke filen $name-$now"        # feilmelding
  fi
}

###################### Main ########################

for i in "${pid[@]}";                          #for alle argumenter
 do
    if [ -f /proc/"$i"/status ];               #hcis filen finnes
      then
        hentOgSkrivData "$i"                   #hent data fra fil og skriv data til en annen fil
      else
        echo "ProsessID $i finnes ikke"        #feilmelding
      fi
 done

exit 0                                         #avslutt scirpt

 

