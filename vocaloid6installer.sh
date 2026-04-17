#!/usr/bin/env bash
echo "Starting Vocaloid6 Linux Installer.  For VST support, wine 9.21 staging is recommended for yabridge."

# Checking if everything we need is installed
if ! [ -x "$(command -v wine)" ]; then
  echo 'Error: Wine is not installed.' >&2
  exit 1
fi
if ! [ -x "$(command -v winetricks)" ]; then
  echo 'Error: Winetricks is not installed.' >&2
  exit 1
fi
if ! ls /usr/share/vulkan/icd.d/ 1>/dev/null 2>&1 ; then
  echo 'Error: No Vulkan installation.' >&2
  exit 1
fi
if ! [ -x "$(command -v yabridgectl)" ]; then
  echo "Yabridgectl is not installed, vst support won't work." >&2
fi
echo 'Passed dependency checks'

# Lets set the wineprefix path
read -p "Please enter the location you would like to install VOCALOID6 (default ~/vocaloid6/): " wineprefix_path
wineprefix_path=${wineprefix_path:-~/vocaloid6/}
wineprefix_path="${wineprefix_path/#\~/$HOME}"
echo "Install path: $wineprefix_path"
mkdir -p "$wineprefix_path"
if [ ! -d "$wineprefix_path" ]; then
    echo "Error: Could not create $wineprefix_path." >&2
    exit 1
fi

# Download Vocaloid6 trial
curl -L -o VOCALOID_Trial_Win_en.zip vocaloid.com/en/download_trials/vocaloid_trial_win
unzip VOCALOID_Trial_Win_en.zip
rm VOCALOID_Trial_Win_en.zip
cd VOCALOID_Trial_Win
unzip VOCALOID6_Editor_*
unzip VOCALOID6_Voicebanks_*
mv VOCALOID6_Voicebanks_Installer.exe ../
mv VOCALOID6_Editor_Installer.exe ../
cd ..
rm -r VOCALOID_Trial_Win

# Install VOCALOID6 Editor
WINEPREFIX="$wineprefix_path" wineboot > /dev/null 2>&1 | echo "Wineboot Complete"
WINEPREFIX="$wineprefix_path" winetricks -q dxvk corefonts > /dev/null 2>&1 | echo "Installing prerequitsites...."
WINEPREFIX="$wineprefix_path" wine VOCALOID6_Editor_Installer.exe > /dev/null 2>&1 | echo "VOCALOID6 Editor Installing..."
cat > $wineprefix_path/regfix.reg <<EOF
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Avalon.Graphics]
"DisableHWAcceleration"=dword:00000001
EOF

WINEPREFIX="$wineprefix_path" wine regedit $wineprefix_path/regfix.reg

read -p "Do you need to install the VOCALOID6 Voicebanks? " yn

case $yn in
    [yY] ) WINEPREFIX="$wineprefix_path" wine VOCALOID6_Voicebanks_Installer.exe 2>&1 | echo "VOCALOID6 Voicebanks Installing";;
    [nN] ) echo "";;
    * ) echo invalid response;;
esac

# Cleanup downloads
rm VOCALOID6_Editor_Installer.exe
rm VOCALOID6_Voicebanks_Installer.exe

# Converting VST for Linux
yabridgectl add $wineprefix_path/drive_c/Program\ Files/Common\ Files/VST3/ > /dev/null 2>&1 | echo "Converting VST for Linux..."
yabridgectl sync > /dev/null 2>&1

echo "Installing User Supplied Voices..."
for exe in ~/V6Voices/*.exe; do
    echo "Installing $(basename "$exe")..."
    WINEPREFIX="$wineprefix_path" wine "$exe" > /dev/null 2>&1
done

echo ""
echo "Completed, you may use VOCALOID6 Editor standalone or the VST might work in your DAW of choice, it should be in your VST3 folder if you had yabridgectl installed. Use offline activation for your editor and voicebanks."
exit 0
