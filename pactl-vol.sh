#!/usr/bin/bash
#
# Created by: hug2@gmx.com
# Created on: 2023-10-25 Wed 13:56
# Modified:   2024-03-19 Tue 22:00
#
# Project Description:
# Call pactl; parse the volume level; 
# See notes;

#----------------------------------------------

# Global variables
pactl_sinks=''
bluetooth_connected=false
volume_line=''
is_muted=false
volume_level=''
print_result=''
which_sink='system'


# Print pactl sinks; parse output;
function get_pactl_sinks() {
    pactl_sinks=$(pactl list sinks | grep -e 'Mute' -e 'Volume: front-left')
}

# Determine if bluetooth is connected
function is_bluetooth_connected() {

    local lines
    lines=$(echo "$pactl_sinks" | wc -l)
    # wc -l : line count;
    # if 4, then bluetooth; if 2, then system

    if [[ "$lines" == "4" ]]; then
        bluetooth_connected=true
    fi

}

# Check if vol is muted
function check_muted() {
    if echo -n "$pactl_sinks" | grep -q 'Mute: yes'; then
        is_muted=true
    fi
    # -q : Quiet
      # don't write to standard output; exit with zero status if successful
      # So this basically will give a return status of zero, which the if statement reads as true;
}

function parse_vol() {

    if $bluetooth_connected; then
        # parse text for connected bluetooth
        volume_line=$(echo "$pactl_sinks" | sed -n '3,4p' | xargs)
        volume_level=$(echo "$volume_line" | awk '{print $7}')
        which_sink="bluetooth"

    else
        # parse text for system vol
        volume_line=$(echo "$pactl_sinks" | sed -n '1,2p' | xargs)
        volume_level=$(echo "$volume_line" | awk '{print $7}')
        which_sink="system"
    fi
    # See notes below about sed command;
}

function format_print_vol() {

    if [[ "$which_sink" == "system" ]]; then
        print_result="🍔  "
    else
        print_result="🌮  "
    fi

    if $is_muted; then
        print_result=👻
    else
        print_result+="$volume_level"
    fi
}

function do_print_vol() {
    echo -n "¦    $print_result"
}

# Logic:
# blutooth connected
  # get 4 lines back
# bluetooth not connected
  # Get 2 lines back
# Is muted?
# Get volume of system/bluetooth
# Format and print output

get_pactl_sinks
is_bluetooth_connected
format_print_vol
check_muted
if ! $is_muted; then parse_vol; fi
format_print_vol
do_print_vol


# -----------------------------------------


# Various icons to use, emojis and nerdfons:
# 󰗅  󱄡   󰓀   󱟛 🔈 🔉  🔊 󱡏 󱡒  󰟅
#  󰎆   󰝚 󰎄 󱍙 󰃂 󰽭 󰽻 🤖 📻 📣 💬 💭 🎻 🎸 🪕 🥁
# 🎹  🍩 🌋 📻 👻 💀 ☠️ 🍔 🌮 🍟



#-----------------------------------------------
### Notes:
#-----------------------------------------------


  # See Audio_Volume_notes for more on working with audio and on commands used below;
  # There's a few ways to get the volume; and other ways can't/not using here because I have an older version of pulseaudio/pactl;

  #-------------------------

  # $ man pactl
  #   Control a running PulseAudio sound server
  #
  # What is "sink"? From Bard:
    # a sink is an audio output device. It is a destination for audio streams from PulseAudio sources, such as applications or media players. PulseAudio can manage multiple sinks simultaneously, allowing users to route audio to different devices, such as headphones, speakers, or a sound card.


  #---------------------------


  # 2 possible commands to use: pulsemixer and pactl;
  # Will use pactl because based on 'time', appears order of magtitude faster;
  # output_res=$(pulsemixer --get-volume | awk '{print $1}')
  # output_res=$(pactl list sinks | grep "Volume" | sed -n '3p' | awk '{print $5}')

  #---------------------------

  # Note about (bluetooth) headsets connected/disconnected:
  # In my case, if my bluetooth is not operating, then only 2 lines will output; which seems to be the hardware settings? It's Sink#2, "Built-in Auidio Analog Stereo";
  # And this device always reads 100% volume; interstingly, when I have my bluetooth disconnected, the Mate volume control also returns to 100%;
    # // 2024-03-19: This doesn't seem to be true anymore; the system vol. now seems to read the correct level, not 100%;
  #  But it's not the regular bluetooth device I use; who knows, with a different bluetooth device, the setting again might be different???
  # So the above, when bluetooth headset is disconnected, lines 3,4 will output a blank line; that will then give the same result as when the system is muted; do I want that?
  # Tried out a different bluetooth headset, and while the sink number is different, it does appear as lines 3, 4; so this code will work with other bluetooth devices, it appears;
  # ANd each device has its own volume level
  # I don't know what would happen if I had both a bluetooth and wired headphone at same time? Or just wired?

  #-----------------------------------------

  # output_res=$(pactl list sinks | grep -e "Mute" -e "Volume: front-left" | sed -n '3,4p' | xargs)
  ###
    # If bluetooth is connected, output from above should be something like:
    #:: Mute: no Volume: front-left: 62830 / 96% / -1.10 dB, front-right: 62830 / 96% / -1.10 dB
    # If no bluetooth, then blank

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


  #---------------------------

  # // 2024-03-19 Tue 22:03
  # Notes:
  #
  # pactl list sinks gives output like this, depending on whether you have bluetooth connected or not; the non-bluetooth volume seems to be always displayed;

  # $ pactl list sinks
  # Output result depending on whether bluetooth is connected:
  # The starred lines below are the lines we're interested in; the result we get back with our grep command: grep -e "Mute" -e "Volume: front-left"
  # The -e is a multipattern match ; will return lines containing "Mute" and "Volume: front-left"
  # If bluetooth is connected, will get back 4 lines; if bluetooth not connected, then 2 lines;
  # If we get 4 lines back, then blutooth is connected, and we want lines 3 and 4; if 2 lines back, then bluetooth is disconnected;
  # Then we xargs the lines to flatten it all into 1 line that we can parse;
  #
  #
  #
  # With bluetooth connected:
  # Sink #3
  #     State: RUNNING
  #     Name: bluez_sink.30_53_C1_8E_86_A0.a2dp_sink
  #     Description: WF-C500
  #     Driver: module-bluez5-device.c
  #     Sample Specification: s16le 2ch 48000Hz
  #     Channel Map: front-left,front-right
  #     Owner Module: 27
  # *   Mute: no
  # *      Volume: front-left: 55708 /  85% / -4.23 dB,   front-right: # 55708 /  85% / -4.23 dB
  # *   Mute: no
  # *      Volume: front-left: 32561 /  50% / -18.23 dB,   front-right: # 32561 /  50% / -18.23 dB
  #     Base Volume: 65536 / 100% / 0.00 dB
  #     Monitor Source: bluez_sink.30_53_C1_8E_86_A0.a2dp_sink.monitor
  #     Latency: 45459 usec, configured 43666 usec
  #     Flags: HARDWARE DECIBEL_VOLUME LATENCY
  #     Properties:
  #
  # # Without bluetooth connected:
  # Sink #2
  #     State: RUNNING
  #     Name: alsa_output.pci-0000_00_14.2.analog-stereo
  #     Description: Built-in Audio Analog Stereo
  #     Driver: module-alsa-card.c
  #     Sample Specification: s32le 2ch 48000Hz
  #     Channel Map: front-left,front-right
  #     Owner Module: 8
  # *   Mute: no
  # *   Volume: front-left: 55708 /  85% / -4.23 dB,   front-right: 55708 # /  85% / -4.23 dB
  #     balance 0.00
  #     Base Volume: 65536 / 100% / 0.00 dB
  #     Monitor Source: alsa_output.pci-0000_00_14.2.analog-stereo.monitor
  #     Latency: 22122 usec, configured 26000 usec
  #     Flags: HARDWARE HW_MUTE_CTRL HW_VOLUME_CTRL DECIBEL_VOLUME LATENCY
  #     Properties:




