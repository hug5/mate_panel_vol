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

# Here, bash lint telling me to use grep -q command instead; but have to leave out brackets;
# Not sure when or when not to use brackets?? The brackets is basically a "test" command;
# It's saying, "test $a = $b" or [ $a = $b ]; If no need to "test", then don't need brackets?
# if [[ $(echo $output_res | grep -s 'Mute: no') ]]; then
if echo "$output_res" | grep -q 'Mute: no'; then
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

    # Then echo our result:
    echo "¦    $vol_res"

else
    # The sound is muted; show donut;
    echo "¦    🍩"
fi



# -----------------------------------------


# Various icons to use, emojis and nerdfons:
# 󰗅  󱄡   󰓀   󱟛 🔈 🔉  🔊 󱡏 󱡒  󰟅
#  󰎆   󰝚 󰎄 󱍙 󰃂 󰽭 󰽻 🤖 📻 📣 💬 💭 🎻 🎸 🪕 🥁
# 🎹  🍩 🌋 📻


