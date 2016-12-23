# uae4arm-retropie-scripts
Scripts to allow the use of Zipped WHDLoad folders with uae4arm using Retropie runcommand

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
