#!/bin/bash
printf '\033[8;40;140t'

# Farben Palette
red="\e[0;31m" # ${red}
green="\e[0;32m" # ${green}
white="\e[1;37m" # ${white}
blue="\e[0;94m" # ${blue}
grey="\e[0;31m" # ${grey}
violet="\e[0;36" # ${violet}
bold="\e[1m" # ${bold}
reset="\e[0m" # ${reset}



START () {
jsonFile=$(cat db.json | jq)
    if [[ -z $jsonFile ]]; then
        jsonFile=$(jq --null-input '{"DATA": {"apiKey": 0, "Currency": "USD", "Portfolio": "1", "sortTable": "a", "Lable": "on", "Coins": {"BTC": {"Holding": 0, "FIATholding": 0, "Marketcap": 0}, "ETH": {"Holding": 0, "FIATholding": 0, "Marketcap": 0}, "BNB": {"Holding": 0, "FIATholding": 0, "Marketcap": 0}, "SOL": {"Holding": 0, "FIATholding": 0}, "DOGE": {"Holding": 0, "FIATholding": 0, "Marketcap": 0},}}}');
        echo $jsonFile | jq > db.json
        INSTALL
    fi
TABLE
}

INSTALL () {
clear
echo;echo;
echo -e "       WELCOME TO"
echo -e "                   _    _______             _     "
echo -e "                  (_)  |__   __|           | |   "
echo -e "          ___ ___  _ _ __ | |_ __ __ _  ___| | __"
echo -e "         / __/ _ \| |  _ \| |  __/ _  |/ __| |/ / "
echo -e "        | (_| (_) | | | | | | | | (_| | (__|   < "
echo -e "         \___\___/|_|_| |_|_|_|  \____|\___|_|\_\."
echo;
echo;
echo -e "       You need to get a (free) API Key from https://min-api.cryptocompare.com/ in order for coinTrack to work."
echo -e "       Please enter your API Key from Cryptocompare:"
echo -n "       : "
read APIkey

jsonFile=$(cat db.json | jq)
jsonFile=$(echo "$jsonFile" | jq --arg apiKey "$APIkey" '.DATA += {"apiKey": $apiKey}')
echo "$jsonFile" | jq > db.json
echo;
APITEST
echo;echo;
echo -e "       Just hit ${white}${bold}[enter]${reset} to fetch the current Prices."
echo -e "       For Information about all Commands just enter ${white}${bold}[i]${reset}."
echo;
echo -n "       [enter] to start."
read enter

LOGO
}


LOGO () {

# get Options
jsonFile=$(cat db.json | jq);


portF=$(echo "$jsonFile" | jq -r '.DATA.Portfolio');
currency=$(echo "$jsonFile" | jq -r '.DATA.Currency');
sortTABLE=$(echo "$jsonFile" | jq -r '.DATA.sortTable');
lable=$(echo "$jsonFile" | jq -r '.DATA.Lable');

clear
if [[ -z $lable || $lable == "on" ]]; then
echo -e "                   _    _______             _     "
echo -e "                  (_)  |__   __|           | |   "
echo -e "          ___ ___  _ _ __ | |_ __ __ _  ___| | __"
echo -e "         / __/ _ \| |  _ \| |  __/ _  |/ __| |/ / "
echo -e "        | (_| (_) | | | | | | | | (_| | (__|   < "
echo -e "         \___\___/|_|_| |_|_|_|  \____|\___|_|\_\."
fi
echo;echo;

}


############################# PRICE TABLE
TABLE () {
LOGO




#Count amount of CoinstoTrack
n=$(echo "$jsonFile" | jq '.DATA.Coins | length')

# Generate coinsToTrack
coinsToTrack=$(echo "$jsonFile" | jq '.DATA.Coins | keys.[]' | sed 's/\"//g;s/$/,/' | tr -d '\n')
# Set totalValue to 0
totalValue=0;

# get current Values
newValues=$(curl -g -s -X GET "https://min-api.cryptocompare.com/data/pricemultifull?fsyms="$coinsToTrack"&tsyms=$currency&api_key={$APIkey}" | jq)


# SORT COINS AS PREFERED
if [[ $sortTABLE == "a" ]]; then
    # Alphabetical Sort
    coinn=$(echo "$jsonFile" | jq -r ".DATA.Coins | keys.[$i]") # Symbol
    elif [[ $sortTABLE == "p" ]]; then
    # Sort by Portfolio Value
    coinn=$(echo "$jsonFile" | jq '.DATA.Coins | to_entries | sort_by( .value.FIATholding | tonumber) | reverse | from_entries' | jq -r "keys_unsorted[$i]");
    elif [[ $sortTABLE == "m" ]]; then
    # Sort by Portfolio Value
    coinn=$(echo "$jsonFile" | jq '.DATA.Coins | to_entries | sort_by( .value.Marketcap | tonumber) | reverse | from_entries' | jq -r "keys_unsorted[$i]");
    elif [[ $sortTABLE == "1" ]]; then
    # Sort by Portfolio Value
    coinn=$(echo "$jsonFile" | jq '.DATA.Coins | to_entries | sort_by( .value.change1h | tonumber) | reverse | from_entries' | jq -r "keys_unsorted[$i]");
    elif [[ $sortTABLE == "2" ]]; then
    # Sort by Portfolio Value
    coinn=$(echo "$jsonFile" | jq '.DATA.Coins | to_entries | sort_by( .value.change24h | tonumber) | reverse | from_entries' | jq -r "keys_unsorted[$i]");
fi


echo;
echo -e "***  Coin  ******  Price ********* 1h% ** 24h%  ***   24h Volume   ***     Marketcap    ***  Holdings & Value in $currency ***";
echo -e "–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––----";
for (( i=0; i<$n; i++ ));  do

# Add 1 to $i since awk starts counting at 1
cn=$(($i+1));
# Get Coinname from Variable
coin=$(echo "$coinn" | awk "NR==$cn")


rawPrice=$(echo "$newValues" | jq -r .RAW.$coin.$currency.PRICE) # Current RawPrice
price=$(echo "$newValues" | jq -r .DISPLAY.$coin.$currency.PRICE) # Current Price
change=$(echo "$newValues" | jq -r .DISPLAY.$coin.$currency.CHANGE24HOUR) # 24h pricechange $currency
changePct=$(echo "$newValues" | jq -r .DISPLAY.$coin.$currency.CHANGEPCT24HOUR) # 24h pricechange in %
changeHour=$(echo "$newValues" | jq -r .DISPLAY.$coin.$currency.CHANGEHOUR) # 1h pricechange in USD
changePctHour=$(echo "$newValues" | jq -r .DISPLAY.$coin.$currency.CHANGEPCTHOUR) # 1h pricechange in $currency
marketCapDsp=$(echo "$newValues" | jq -r .DISPLAY.$coin.$currency.MKTCAP) # Marketcap
totalVolume=$(echo "$newValues" | jq -r .DISPLAY.$coin.$currency.TOTALVOLUME24HTO) # Total Volume last 24h



if [[ $changePct == -* ]]; then changePct=${red}$changePct${reset}; else changePct=${green}+$changePct${reset}; fi
if [[ $changePctHour == -* ]]; then changePctHour=${red}$changePctHour${reset}; else changePctHour=${green}+$changePctHour${reset}; fi
if [[ $change == -* ]]; then change=${red}$change${reset}; else change=${green}$change${reset}; fi


# Calculate FIAT value of Holdings
holding=$(echo "$jsonFile" | jq -r ".DATA.Coins.$coin.Holding") # get Holdings
value=$(awk "BEGIN {h=$holding; p=$rawPrice; vl=h*p; print vl}")
# Write FIAT value to db.json
jsonFile=$(echo "$jsonFile" | jq --arg newHolding $value --arg c "$coin" '.DATA.Coins.[$c] += {"FIATholding": $newHolding}');
# Also add current Marketcap
marketCap=$(echo "$newValues" | jq -r .RAW.$coin.$currency.MKTCAP)
jsonFile=$(echo "$jsonFile" | jq --arg Mcap $marketCap --arg c "$coin" '.DATA.Coins.[$c] += {"Marketcap": $Mcap}');
# Now add % Changes
change24=$(echo "$newValues" | jq -r .DISPLAY.$coin.$currency.CHANGEPCT24HOUR) # 24h pricechange in %
jsonFile=$(echo "$jsonFile" | jq --arg change $change24 --arg c "$coin" '.DATA.Coins.[$c] += {"change24h": $change}');
change1=$(echo "$newValues" | jq -r .DISPLAY.$coin.$currency.CHANGEPCTHOUR) # 1h pricechange in %
jsonFile=$(echo "$jsonFile" | jq --arg change $change1 --arg c "$coin" '.DATA.Coins.[$c] += {"change1h": $change}');
# Write new json Data to db.json only once
if [[ $i == $(($n-1)) ]]; then
echo "$jsonFile" | jq > db.json
fi

if [[ $portF == 0 ]]; then
    holding="******";
    value="******";
fi
if [[ $value == 0 ]]; then
    holding=" ";
    value=" ";
fi
echo -e "... ${bold}${white}$coin${reset} ... $price ... $changePctHour $changePct  ... $totalVolume ... $marketCapDsp ... $holding     =     ${blue}$value${reset}"; 

done | column -t;
echo;echo;


# Calculate Total Value
jsonFile=$(cat db.json | jq)
valueList=$(echo "$jsonFile" | jq '.DATA.Coins.[] | .FIATholding' | sed 's/\"//g')
    
while IFS= read -r line; do
totalValue=$(awk "BEGIN {t=$totalValue; l=$line; tl=t+l; print tl}");
done <<< "$valueList"

# Read totalValue
oldValue=$(echo $jsonFile | jq -r .DATA.Totalvalue)
if [[ $oldValue == null ]]; then
    oldValue=$totalValue
fi



LASTREFRESH


# Write new totalValue
jsonFile=$(echo "$jsonFile" | jq --arg tvalue "$totalValue" '.DATA += {"Totalvalue": $tvalue}')


differenz=$(awk "BEGIN { print ($totalValue-$oldValue)/$oldValue*100 }")

if [[ $portF == 0 ]]; then
    totalValue="****"
fi




echo -e "   Total Value: ${blue}$currency $totalValue ${reset}";
if [[ $differenz == -* ]]; then
echo -e "   Change in the last ${bold}$lastRefresh${reset}: ${red}${bold}$differenz % ${reset}";
    else
echo -e "   Change in the last ${bold}$lastRefresh${reset}: ${green}${bold}$differenz % ${reset}";
fi

echo $jsonFile | jq > db.json
echo;echo;echo;echo;
MENU
}


#### HISTORY TABLE
HISTORY () {
LOGO
#Count amount of CoinstoTrack
n=$(echo "$jsonFile" | jq '.DATA.Coins | length')

echo;
echo -e "*******  Coin  ******  Price ********* 1h% ** 24h% ** 3D% ** 7D% **  1M%  ** 3M%  **  6M%  **  9M%  **  1Y% ";
echo -e "––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––";
for (( i=0; i<$n; i++ ));  do

# Get the Coinsymbols from db.json
if [[ $sortTABLE == "a" ]]; then
    # Alphabetical Sort
    coin=$(echo "$jsonFile" | jq -r ".DATA.Coins | keys.[$i]") # Symbol
    elif [[ $sortTABLE == "p" ]]; then
    # Sort by Portfolio Value
    coin=$(echo "$jsonFile" | jq '.DATA.Coins | to_entries | sort_by( .value.FIATholding | tonumber) | reverse | from_entries' | jq -r "keys_unsorted[$i]");
    elif [[ $sortTABLE == "m" ]]; then
    # Sort by Portfolio Value
    coin=$(echo "$jsonFile" | jq '.DATA.Coins | to_entries | sort_by( .value.Marketcap | tonumber) | reverse | from_entries' | jq -r "keys_unsorted[$i]");
    elif [[ $sortTABLE == "1" ]]; then
    # Sort by Portfolio Value
    coin=$(echo "$jsonFile" | jq '.DATA.Coins | to_entries | sort_by( .value.change1h | tonumber) | reverse | from_entries' | jq -r "keys_unsorted[$i]");
    elif [[ $sortTABLE == "2" ]]; then
    # Sort by Portfolio Value
    coin=$(echo "$jsonFile" | jq '.DATA.Coins | to_entries | sort_by( .value.change24h | tonumber) | reverse | from_entries' | jq -r "keys_unsorted[$i]");
fi


rawPrice=$(echo "$newValues" | jq .RAW.$coin.$currency.PRICE | sed s/\"//g;) # Current RawPrice
price=$(echo "$newValues" | jq .DISPLAY.$coin.$currency.PRICE | sed s/\"//g;) # Current Price
change=$(echo "$newValues" | jq .DISPLAY.$coin.$currency.CHANGE24HOUR | sed s/\"//g;) # 24h pricechange $currency
changePct=$(echo "$newValues" | jq .DISPLAY.$coin.$currency.CHANGEPCT24HOUR | sed s/\"//g;) # 24h pricechange in %
changeHour=$(echo "$newValues" | jq .DISPLAY.$coin.$currency.CHANGEHOUR | sed s/\"//g;) # 1h pricechange in USD
changePctHour=$(echo "$newValues" | jq .DISPLAY.$coin.$currency.CHANGEPCTHOUR | sed s/\"//g;) # 1h pricechange in $currency


history=$(curl -g -s -X GET "https://min-api.cryptocompare.com/data/v2/histoday?fsym="$coin"&tsym=$currency&limit=365&api_key={$APIkey}");
# History Price-Changes. To round numbers after . use "LC_ALL=C /usr/bin/printf" because of german locale Numberformat using , instad of . ( 6,666).

ONEy=$(printf $history | jq '.Data.Data[0].close');
ONEy=$(awk "BEGIN {a=$ONEy; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
ONEy=$(echo $ONEy | sed "s/","/\./");
#SIXm=$(echo "scale=2; $SIXm/1" | bc)
ONEy=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $ONEy);

NINEm=$(printf $history | jq '.Data.Data[91].close');
NINEm=$(awk "BEGIN {a=$NINEm; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
NINEm=$(echo $NINEm | sed "s/","/\./");
#SIXm=$(echo "scale=2; $SIXm/1" | bc)
NINEm=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $NINEm);

SIXm=$(printf $history | jq '.Data.Data[182].close');
SIXm=$(awk "BEGIN {a=$SIXm; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
SIXm=$(echo $SIXm | sed "s/","/\./");
#SIXm=$(echo "scale=2; $SIXm/1" | bc)
SIXm=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $SIXm);

THREm=$(printf $history | jq '.Data.Data[272].close');
THREm=$(awk "BEGIN {a=$THREm; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
SIXm=$(echo $SIXm | sed "s/","/\./");
#THREm=$(echo "scale=2; $THREm/1" | bc)
THREm=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $THREm);

ONEm=$(printf $history | jq '.Data.Data[320].close');
ONEm=$(awk "BEGIN {a=$ONEm; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
ONEm=$(echo $ONEm | sed "s/","/\./");
#ONEm=$(echo "scale=2; $ONEm/1" | bc)
ONEm=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $ONEm);

SEVENd=$(printf $history | jq '.Data.Data[358].close');
SEVENd=$(awk "BEGIN {a=$SEVENd; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
SEVENd=$(echo $SEVENd | sed "s/","/\./");
#SEVENd=$(echo "scale=2; $SEVENd/1" | bc)
SEVENd=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $SEVENd);

THREd=$(printf $history | jq '.Data.Data[362].close');
THREd=$(awk "BEGIN {a=$THREd; e=$rawPrice; ep=(e-a)/a*100; printf ep}");
THREd=$(echo $THREd | sed "s/","/\./");
#THREd=$(echo "scale=2; $THREd/1" | bc)
THREd=$(LC_ALL=C /usr/bin/printf '%.*f\n' 2 $THREd);

if [[ $changePct == -* ]]; then changePct=${red}$changePct${reset}; else changePct=${green}+$changePct${reset}; fi
if [[ $changePctHour == -* ]]; then changePctHour=${red}$changePctHour${reset}; else changePctHour=${green}+$changePctHour${reset}; fi
if [[ $change == -* ]]; then change=${red}$change${reset}; else change=${green}$change${reset}; fi

if [[ $ONEy == -* ]]; then ONEy=${red}$ONEy${reset}; else ONEy=${green}+$ONEy${reset}; fi
if [[ $NINEm == -* ]]; then NINEm=${red}$NINEm${reset}; else NINEm=${green}+$NINEm${reset}; fi
if [[ $SIXm == -* ]]; then SIXm=${red}$SIXm${reset}; else SIXm=${green}+$SIXm${reset}; fi
if [[ $THREm == -* ]]; then THREm=${red}$THREm${reset}; else THREm=${green}+$THREm${reset}; fi
if [[ $ONEm == -* ]]; then ONEm=${red}$ONEm${reset}; else ONEm=${green}+$ONEm${reset}; fi
if [[ $SEVENd == -* ]]; then SEVENd=${red}$SEVENd${reset}; else SEVENd=${green}+$SEVENd${reset}; fi
if [[ $THREd == -* ]]; then THREd=${red}$THREd${reset}; else THREd=${green}+$THREd${reset}; fi

#if [[ $change == -* ]]; then price=${red}$price${reset}; else price=${green}$price${reset}; fi




echo -e "....... ${bold}${white}$coin${reset} ... $price ... $changePctHour $changePct $THREd $SEVENd  $ONEm  $THREm  $SIXm  $NINEm  $ONEy";

done | column -t;

echo;echo;echo;echo;
MENU
}


### MENU
MENU () {
echo -e "   [enter] - Refresh Price | [h] - Price History Table | [i] - Info | [q] - Quit"
echo;
echo -n "   : "
read next

case $next in  
    "q") exit ;;
    "a") ADDCOIN ;;
    "d") DELETECOIN ;;
    "i") INFO ;;
    "p") SHOWPORT ;;
    "h") HISTORY ;;
    "H") HOLDINGS ;;
    "c") CURRENCY ;;
    "s") SORT ;;
    "L") LABLE ;;
    *) TABLE ;;
esac

}

INFO () {
    echo -e "${white}______________________________________________________________________________________________${reset}";
    echo;echo;
    echo -e "   ${white}Key configuration INFO:${reset}"
    echo -e "   ----------------------"
    echo;
    echo -e "   ${bold}a${reset} - Add Coin"
    echo -e "   ${bold}d${reset} - Delete Coin"
    echo -e "   ${bold}H${reset} - Change Holdings"
    echo
    echo -e "   ${bold}p${reset} - Portfolio Visible/Hidden"
    echo -e "   ${bold}c${reset} - Change Currency USD/EUR"
    echo -e "   ${bold}s${reset} - Sort the listing"
    echo -e "   ${bold}L${reset} - Show/Hide coinTrack Logo"
    echo
    echo -e "   ${bold}q${reset} - Quit"
    echo;echo;echo;
    MENU
}

LABLE () {
    if [[ $lable == "on" ]]; then
        lable="off"
        jsonFile=$(echo "$jsonFile" | jq --arg lab "$lable" '.DATA += {"Lable": $lab}')
    else
        lable="on"
        jsonFile=$(echo "$jsonFile" | jq --arg lab "$lable" '.DATA += {"Lable": $lab}')
    fi
    echo $jsonFile | jq > db.json
    TABLE
}
SORT () {
    echo -e "${white}______________________________________________________________________________________________${reset}";
    echo;echo;
    echo -e "   ${white}PREFERRED SORTING ORDER OF COIN LIST"
    echo -e "   ------------------------------------${reset}"
    echo;
    echo -e "   ${white}a${reset} = Alphabetical"
    echo -e "   ${white}m${reset} = Marketcap"
    echo -e "   ${white}p${reset} = Portfolio Value"
    echo -e "   ${white}1${reset} = 1h % change"
    echo -e "   ${white}2${reset} = 24h % change"
    echo;
    echo -n "   : "
    read sortOrder
    if [[ -z $sortOrder ]]; then
        TABLE
        elif [[ $sortOrder == *"a"* || $sortOrder == *"m"* || $sortOrder == *"p"* || $sortOrder == *"1"* || $sortOrder == *"2"* ]]; then
        jsonFile=$(echo "$jsonFile" | jq --arg sort "$sortOrder" '.DATA += {"sortTable": $sort}')
        echo $jsonFile | jq > db.json
        TABLE
        else
        echo
        echo -e "   ${red}Incorrect Input - only a, m or p are valid."${reset};
        sleep 2s;
        TABLE
    fi
}

SHOWPORT () {
    if [[ $portF == "1" ]]; then
        portF="0";
        jsonFile=$(echo "$jsonFile" | jq --arg port "$portF" '.DATA += {"Portfolio": $port}')
        else
        portF="1";
        jsonFile=$(echo "$jsonFile" | jq --arg port "$portF" '.DATA += {"Portfolio": $port}')
    fi
    echo $jsonFile | jq > db.json
    TABLE
}

CURRENCY () {
    if [[ $currency == "USD" ]]; then
        currency="EUR"
        jsonFile=$(echo "$jsonFile" | jq --arg Cur "$currency" '.DATA += {"Currency": $Cur}')
        echo $jsonFile | jq > db.json
        else
        currency="USD"
        jsonFile=$(echo "$jsonFile" | jq --arg Cur "$currency" '.DATA += {"Currency": $Cur}')
        echo $jsonFile | jq > db.json
    fi
    TABLE
}

DELETECOIN () {
    echo -e "${red}______________________________________________________________________________________________${reset}";
    echo;echo;
    echo -e "   ${red}DELETE COIN"
    echo -e "   ------------${reset}"
    echo;
    coinList=$(echo "$jsonFile" | jq '.DATA.Coins | keys.[]' | sed 's/\"//g')
    count=1;
    while IFS= read -r line; do
    echo "$count. $line"
    coinContainer[$count]="$line"
    count=$((count+1))
    done <<< "$coinList"
    echo
    echo -e "   Select Coin Nr."
    echo -n "   : "
    read dcoin
    if [[ -z $dcoin ]]; then
        TABLE
    fi
    dcoin="${coinContainer[$dcoin]}"
    echo
    echo -e "   Are you sure to delete ${red}${bold}"$dcoin"${reset}? [y/n]"
    echo -n "   : "
    read sure
    if [[ $sure == y || -z $sure ]]; then
        jsonFile=$(echo "$jsonFile" | jq --arg delCoin "$dcoin" 'del(.DATA.Coins.[$delCoin])')
        echo "$jsonFile" | jq > db.json

        TABLE
    else
        echo
        echo "  abort.";
        sleep 1s;
        TABLE
    fi
}

CHECKSYMBOL () {
    checkSymbol=$(curl -g -s -X GET "https://min-api.cryptocompare.com/data/price?fsym="$cadd"&tsyms=USD&api_key={$APIkey}" | jq)
    check=$(echo $checkSymbol | jq -r '.Response');
    if [[ $check == "Error" ]]; then
        echo
        echo -e "   ${red}${bold}$cadd${reset} ${white}is not a valid Coinsymbol. Please check and try again.${reset}"
        echo;echo;
        ADDCOIN
        else
        jsonFile=$(echo "$jsonFile" | jq --arg Coin "$cadd" '.DATA.Coins += {$Coin: {"Holding": "0", "FIATholding": "0", "Marketcap": "0"}}')
        echo "$jsonFile" | jq > db.json
    fi
}

ADDCOIN () {
    echo -e "${white}______________________________________________________________________________________________${reset}";
    echo;echo;
    echo -e "   ${white}ADD COIN${reset}"
    echo -e "   --------"
    echo;
    echo -e "   Coinsymbol to add:"
    echo -n "   : "
    read cadd
    cadd=${cadd^^}
    if [[ -z $cadd ]]; then
        TABLE
        else
        CHECKSYMBOL
    fi 
TABLE
}

HOLDINGS () {
    echo -e "${white}______________________________________________________________________________________________${reset}";
    echo;echo;
    echo -e "   ${white}ADD/REMOVE Holdings${reset}"
    echo -e "   -------------------"
    echo;

    coinList=$(echo "$jsonFile" | jq '.DATA.Coins | keys.[]' | sed 's/\"//g')
    count=1;
    while IFS= read -r line; do
    echo "$count. $line"
    coinContainer[$count]="$line"
    count=$((count+1))
    done <<< "$coinList"
    echo
    echo -e "   Select Coin Nr."
    echo -n "   : "
    read selectedCoin
    if [[ -z $selectedCoin ]]; then
        TABLE
    fi
    echo;echo;
    selectedCoin="${coinContainer[$selectedCoin]}"
    currentAmount=$(echo "$jsonFile" | jq --arg c "$selectedCoin" '.DATA.Coins.[$c].Holding' | sed 's/\"//g')

    echo -e "   You are currently holding: ${blue}${bold}"$selectedCoin" "$currentAmount" ${reset}"
    echo -e "   ${grey}To add or subtract, simply use a plus or minus sign in front of the value (e.g.+100).${reset}"
    echo;
    echo -n "   Amount: "   
    read amount
    amount=$(echo $amount | sed 's/\,/\./g');
    if [[ $amount == *"+"* ]] || [[ $amount == *"-"* ]]; then
        newAmount=$(awk "BEGIN {a="$currentAmount"; n="$amount"; an=a+n; printf an}");
    elif [[ -z $amount ]]; then
       TABLE
    else
        echo "error...NO CHANGES SAVED!"
        echo "try again..."
        sleep 3s;
        TABLE
    fi

    jsonFile=$(echo "$jsonFile" | jq --arg newHolding $newAmount --arg c "$selectedCoin" '.DATA.Coins.[$c] += {"Holding": $newHolding}')
    echo "$jsonFile" | jq > db.json
   



    TABLE
}
APITEST () {
echo -e "       Testing API Key"
testKey=$(curl -g -s -X GET "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC&tsyms=USD&api_key={$APIkey}"| jq)
resp="$(echo $testKey | grep -o "Error")" 
if [[ "$resp" == "Error" ]]; then
    echo;
    echo -e "${red}${bold}"
    echo -e "       API Error! Either wrong API Key or API just not working :(${reset}"
    echo -n "       Let's try again...press [enter]"
    read enter
    INSTALL
    else
    echo -e "       ${green}${bold}All good!${reset}"
fi
echo;
}

LASTREFRESH () {
# Get last refresh Date
date2=$(echo $jsonFile | jq -r .DATA.lastValueRefresh)
if [[ $date2 == null ]]; then
    date=$(date +%s);
fi
# Create current Date
date1=$(date +%s)

# Get the difference
diff_seconds=$(awk "BEGIN { t=$date1; l=$date2; tl=t-l; print tl}");

# Calculate days, hours, minutes, and seconds
days=$((diff_seconds / 86400))
hours=$(( (diff_seconds % 86400) / 3600 ))
minutes=$(( (diff_seconds % 3600) / 60 ))
seconds=$((diff_seconds % 60))
# Format nicely
dz="$days Days"
hz="$hours"h""
mz="$minutes"min""
sz="$seconds"sec""

if [[ $minutes == 0 ]]; then
    lastRefresh=$sz
    elif [[ $hours == 0 ]]; then
    lastRefresh="$mz $sz"
    elif [[ $days == 0 ]]; then
    lastRefresh="$hz $mz $sz"
    else
    lastRefresh="$dz $hz $mz $sz"
fi

# Write current refresh time
lastValueRefresh=$(date +%s);
jsonFile=$(echo "$jsonFile" | jq --arg trefresh "$lastValueRefresh" '.DATA += {"lastValueRefresh": $trefresh}')
echo $jsonFile | jq > db.json
}

START