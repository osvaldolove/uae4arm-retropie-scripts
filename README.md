# uae4arm-retropie-whdload-zips
Scripts to allow the use of Zipped WHDLoad folders with uae4arm using Retropie runcommand


## prerequisites
- Raspberry Pi with Retropie 4.02+
- zip command
```
sudo apt-get install zip
```
- unzip command
```
sudo apt-get install unzip
```


## setup
Zip contents should be the contents of the WhdLoad folder, reside in the folder above the desired WHDLoad folder and named identically to the WHDLoad folder name. This information is parsed by the script using the "uaehf0" parameter in the .uae config used as a ROM to launch the game.

e.g.

Speedball 2.uae
```config
uaehf0=dir,rw,DH1:games:/home/pi/RetroPie/roms/amiga/Games_WHDLoad/Speedball2/,0
```
Zip Location
```
/home/pi/RetroPie/roms/amiga/Games_WHDLoad/Speedball2.zip
```


## usage
- Copy runcommand-uae4arm.sh to /opt/retropie/configs/all
- Add the following line to /opt/retropie/config/all/runcommand-onstart.sh
```shell
source /opt/retropie/configs/all/runcommand-uae4arm.sh "$1" "$2" "$3" "$4" "start"
```
- Add the following line to /opt/retropie/config/all/runcommand-onend.sh
```shell
source /opt/retropie/configs/all/runcommand-uae4arm.sh "$1" "$2" "$3" "$4" "stop"
```
