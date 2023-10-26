#!/bin/bash
#
# Created by: hug2@gmx.com
# Created on: 2023-10-25 Wed 13:56
#
# Project Description:
# Call pactl; parse the volume level; 


# -------------------------

# See Audio_Volume_notes for more on working with audio and on commands used below;
# There's a few ways to get the volume; and other ways can't/not using here
# because I have an older version of pulseaudio/pactl;

# -------------------------

# $ man pactl
#   Control a running PulseAudio sound server
#
# What is "sink"? From Bard:
  # a sink is an audio output device. It is a destination for audio streams from PulseAudio sources, such as applications or media players. PulseAudio can manage multiple sinks simultaneously, allowing users to route audio to different devices, such as headphones, speakers, or a sound card.


# ---------------------------


# 2 possible commands to use: pulsemixer and pactl;
# Will use pactl because based on 'time', appears order of magtitude faster;
# output_res=$(pulsemixer --get-volume | awk '{print $1}')
# output_res=$(pactl list sinks | grep "Volume" | sed -n '3p' | awk '{print $5}')


output_res=$(pactl list sinks | grep -e "Mute" -e "Volume: front-left" | sed -n '3,4p' | xargs)
    # Output from above should be something like:
    #:: Mute: no Volume: front-left: 62830 / 96% / -1.10 dB, front-right: 62830 / 96% / -1.10 dB
    # The mute will either be 'Mute: no' or 'Mute: yes'; we'll check this for mute status;
    # list sinks
      # list sinks, ie, audio output devices;
    # grep -e "Mute" -e "Volume"
      # -e <pattern> : multiple pattern match
      # grep for lines with mute and Volume; 3rd line should be Mute status; 4th our volume level;
    # sed -n '3,4p'
      # -n : suppress auto printing of pattern space;
      # '3,4p' : get 3rd line; p, print matched line;
    # xargs : Put the 2 lines into 1 line

# Note about (bluetooth) headsets connected/disconnected:
    # In my case, if my bluetooth is not operating, then only 2 lines will output; which seems to be the hardware settings? It's Sink#2, "Built-in Auidio Analog Stereo";
    # And this device always reads 100% volume; interstingly, when I have my bluetooth disconnected, the Mate volume control also returns to 100%;
    #  But it's not the regular bluetooth device I use; who knows, with a different bluetooth device, the setting again might be different???
    # So the above, when bluetooth headset is disconnected, lines 3,4 will output a blank line; that will then give the same result as when the system is muted; do I want that?
    # Tried out a different bluetooth headset, and while the sink number is different, it does appear as lines 3, 4; so this code will work with other bluetooth devices, it appears;
    # ANd each device has its own volume level
    # I don't know what would happen if I had both a bluetooth and wired headphone at same time? Or just wired?


# So when bluetooth is disconnected, I'll show this emoji:
if [[ -z "$output_res" ]]; then

    vol_res=👻


# If bluetooth connected, check for mute status; if not mute, then show volume:
# Here, bash lint telling me to use grep -q command instead; but have to leave out brackets;
# Not sure when or when not to use brackets?? The brackets is basically a "test" command;
# It's saying, "test $a = $b" or [ $a = $b ]; If no need to "test", then don't need brackets?
# if [[ $(echo $output_res | grep -s 'Mute: no') ]]; then
elif echo -n "$output_res" | grep -q 'Mute: no'; then
    # -q : Quiet :
      # don't write to standard output; exit with zero status if successful
      # So this basically will give a return status of zero, which the if statement reads as true;
      # if 'Mute: no' is not found, then I think the return status should be non-zero;
    # -s, --no-messages :
      # suppress errror messages about nonexistent or unreadble fiels;
      # If match not found, then will be mute;
      # Used this with the previous syntax;
      # If I had gone with the -s option, then if match found, then will print, 'Must: no';

    # Output is this; so get the 7th string;
    # Mute: no Volume: front-left: 62830 / 96% / -1.10 dB, front-right: 62830 / 96% / -1.10 dB
    vol_res=$(echo "$output_res" | awk '{print $7}')


# If mute, thenshow this emoji:
else
    # The sound is muted; show donut;
    vol_res=🍩
fi


# Echo our formatted emoji/string
echo -n "¦    $vol_res"
  # -n : avoid newline; not necessary, but just put here;
  # Could also use printf command; by default, no new line;

# -----------------------------------------


# Various icons to use, emojis and nerdfons:
# 󰗅  󱄡   󰓀   󱟛 🔈 🔉  🔊 󱡏 󱡒  󰟅
#  󰎆   󰝚 󰎄 󱍙 󰃂 󰽭 󰽻 🤖 📻 📣 💬 💭 🎻 🎸 🪕 🥁
# 🎹  🍩 🌋 📻 👻 💀 ☠️


