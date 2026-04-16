# Vocaloid6 Linux Installer
 Just a script to install Vocaloid6 on Linux. 
 
 Download the script and run it, make sure you have wine, winetricks and yabridge/yabridgectl installed if you want to try and use the VST plugin.
 
 I have not tested this with wine earlier than 11.6. 

*Bash* 
```bash
bash <(curl -s https://raw.githubusercontent.com/eric5949/Vocaloid6-Linux-Installer/refs/heads/main/sv2linuxinstaller.sh)
```

*Fish* (because I use fish and fish is wierd)
```fish
bash (curl -s https://raw.githubusercontent.com/eric5949/Vocaloid6-Linux-Installer/refs/heads/main/sv2linuxinstaller.sh | psub)
```

VST works on new wine with this yabridge: https://github.com/robbert-vdh/yabridge/actions/workflows/build.yml?query=branch%3Anew-wine10-embedding
