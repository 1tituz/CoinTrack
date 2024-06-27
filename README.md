# coinTrack
### Just a very simple Bash script to track your cryptocurrency Portfolio in the Linux Terminal.


![coinTrack Screenshot]( https://raw.githubusercontent.com/1tituz/CoinTrack/main/Screenshot_TableView.png "Standard View")
Standart View

![coinTrack Screenshot]( https://raw.githubusercontent.com/1tituz/CoinTrack/main/screenshot_coinTrack2.png "History View")
History View

#### Dependencies:
You need `jq` Version 1.7.0 (maybe 1.6.1 works, but didnt test fully) or above, and `gawk` installed in order for coinTrack to work.  
You also might need a free API Key form Cryptocompare (https://min-api.cryptocompare.com/), but it seems to work without it at the moment.

#### How to Install:
  - You only need one File: coinTrack.sh
  - Best to copy file to its own Folder
  - give the file necessary permissions `sudo chmod +x coinTrack.sh`
  - Start with `./coinTrack.sh`

