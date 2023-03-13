# actuallymentor-batteryCalibrationScript
### STILL TESTING - MACOS OVERRIDING WHEN HITTING BELOW 80%

A script to run a battery calibration ala aldente

Using 'battery' from actuallymentor this script will discharge your battery to 15% then charge to 100% before holding for 1 hour. It will then discharge down to 80% and maintain that state of charge. 

Find 'battery' here - https://github.com/actuallymentor/battery. Give it a star for appreciation.

'Optimise battery' must be turned off in mac settings in order for this to work, otherwise it will charge to 80% and macos will override it and hold the script in a loop. Feel free to fix.

I've also not implemented a current battery check, so make sure that your mac is over 15%, preferably starting at 80% before you run the script. 

According to [this](https://batteryuniversity.com/article/bu-603-how-to-calibrate-a-smart-battery) website about battery maintenance, you should calibrate your battery every 40 partial cycles or every 3 months if not taken off charge.

To make sure you remember to do this, here's one way to set a reminder that will give you a notification every 3 months:
Open crontab:
```
crontab -e
```
Then paste this in and save
```
0 12 1 */3 * osascript -e 'display notification "It may be time for another battery calibration" with title "Battery Calibration Time" sound name "default"'
```
It is set to send a reminder notification every 3 months on the 1st at midday. You might want to change the '1' to the date that you first ran the battery-calibration script. 
