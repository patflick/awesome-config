------------------------------------
--         Configuration          --
------------------------------------
-- Edit this file to fit your favorite settings
-- and audio and network interfaces


-- default programs:

-- terminal:
--terminal = "x-terminal-emulator"
terminal = "urxvt"
-- terminal for quake-style drop down list
--light_terminal = "xterm"
light_terminal = "urxvt -tr -sh 50 -e zsh"
-- browser:
browser="chromium-browser"

--------------------------
--  session management  --
--------------------------

-- screensaver lock command
-- screen_lock_cmd = "gnome-screensaver-command -l"
screen_lock_cmd = "i3lock -c 000000"
-- auto lock after 5 minutes
screen_autolock_time = "1"
screen_autolock_warn_sec = "10"


-- shutdown, restart and hybernate (using ubus, ConsoleKit and UPower)
shutdown_command = 'dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop'
reboot_command = 'dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart'
suspend_command = 'dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend'
suspend_command = 'dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Hibernate'




-- editor:
-- editor = os.getenv("EDITOR") or "editor"
editor = "vim"
editor_cmd = terminal .. " -e " .. editor

-- PULSE audio controller program, to be spawned when clicked on the audio control
audio_controller = "pavucontrol"
-- pulse audio device for use in the audio control
-- get the device name with the command:
--    pactl list | grep -A2 'Source #' | grep 'Name: '
-- TODO: might be deprecated:
audio_device = "alsa_input.pci-0000_00_1b.0.analog-stereo"

-- network device for the up/download stats
-- net_device = "eth0"
net_device = "wlan0"

-- the theme to use (the folder in .config/awesome/themes/)
-- use_theme = "default"
use_theme = "power3" -- my own theme!

-- whether or not to show the sysmon widgets
-- Consider: they can eat up system ressources, don't turn them on
-- on a laptop or such.
show_sysmon_widgets = true
-- update interval for sysmon widgets, every X seconds
sysmon_update_intervall = 2

