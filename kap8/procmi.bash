#!/bin/bash

#################### Feilskjekk ####################

if [ "$#" -gt 0  ]
 then
  pid=( "$@" )
else
  echo "mangler ProsessID argument"
  exit 0
fi

################### Funksjoner #####################

#brukes til aa sjekke returverdier paa programm call

function sjekkFeil {
  if [ "$1" -ne 0  ]      #hvis returverdi fra forige programm != 0
    then                                   # skriv feilmelding
      echo "Noe har gaat galt, proov igjen senere"
      exit 0                               # avslutt script
   fi
}


function hentOgSkrivData {
 name="$1"

 proc=$(cat "/proc/$name/status")
e="$?"
sjekkFeil $e

 vmSize=$(echo "$proc" | grep -i vmsize | awk '{print $2}')
 vmData=$(echo "$proc" | grep -i vmData | awk '{print $2}')
 vmStk=$( echo "$proc" | grep -i vmStk | awk '{print $2}')
 vmExe=$( echo "$proc" | grep -i vmExe | awk '{print $2}')
 privVirtueltMinne=$(echo "$vmData + $vmStk + $vmExe" | bc )
 vmLib=$( echo "$proc" | grep -i vmLib | awk '{print $2}')
 vmRSS=$( echo "$proc" | grep -i vmRSS | awk '{print $2}')
 vmPTE=$( echo "$proc" | grep -i vmPTE | awk '{print $2}')

 now=$(date +%d_%m_%y-%H.%M.%S)
touch "$name"-"$now"
e="$?"
sjekkFeil $e

if [ -f ./"$name"-"$now" ]; 
 then
  {
   echo "******** Minne info om prosess med PID $name ********";
   echo "Total bruk av virtuelt minne (VmSize): $vmSize KB";
   echo "Mengde privat virtuelt minne (VmData+VmStk+VmExe): $privVirtueltMinne KB";
   echo "Mengde shared virtuelt minne (VmLib): $vmLib KB";
   echo "Total bruk av fysisk minne (VmRSS): $vmRSS KB";
   echo "Mengde fysisk minne som benyttes til page table (VmPTE): $vmPTE KB"; 
 } >> "$name"-"$now"
 else
   echo "finner ikke filen $name-$now"
 fi
}

###################### Main ########################

for i in "${pid[@]}";
 do
    if [ -f /proc/"$i"/status ]; 
      then
        hentOgSkrivData "$i"
      else
        echo "ProsessID $i finnes ikke"
      fi
 done

exit 0

 

