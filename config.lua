------------------------------------
--         Configuration          --
------------------------------------
-- Edit this file to fit your favorite settings
-- and audio and network interfaces


-- default programs:

-- terminal:
terminal = "x-terminal-emulator"
-- terminal for quake-style drop down list
light_terminal = "xterm"
-- browser:
browser="chromium-browser"

-- editor:
-- editor = os.getenv("EDITOR") or "editor"
editor = "vim"
editor_cmd = terminal .. " -e " .. editor

-- PULSE audio controller program, to be spawned when clicked on the audio control
audio_controller = "pavucontrol"
-- pulse audio device for use in the audio control
-- get the device name with the command:
--    pactl list | grep -A2 'Source #' | grep 'Name: '
audio_device = "alsa_output.pci-0000_00_07.0.analog-stereo"

-- network device for the up/download stats
-- net_device = "eth0"
net_device = "eth0"

-- the theme to use (the folder in .config/awesome/themes/)
-- use_theme = "default"
use_theme = "power3" -- my own theme!

-- whether or not to show the sysmon widgets
-- Consider: they can eat up system ressources, don't turn them on
-- on a laptop or such.
show_sysmon_widgets = true
-- update interval for sysmon widgets, every X seconds
sysmon_update_intervall = 2
