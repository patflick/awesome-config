-------------------------------------------------------
-- Defines all applications to be started on startup --
-------------------------------------------------------


-------------------------------------------------------
-- The function to start/run the applications        --
-------------------------------------------------------
local awful = require('awful')
local function run_once(prg,arg_string,pname,screen)
    if not prg then
        do return nil end
    end

    if not pname then
       pname = prg
    end

    if not arg_string then
        awful.util.spawn_with_shell("pgrep " .. pname .. " || (" .. prg .. ")",screen)
    else
        awful.util.spawn_with_shell("pgrep " .. pname .. " || (" .. prg .. " " .. arg_string .. ")",screen)
    end
end


--------------------------------------------------------
-- automatically lock screen (settings in config.lua) --
--------------------------------------------------------

require("config")
--screen_autolock_warn_cmd = "notify-send -t " .. screen_autolock_warn_sec .. " -u critical 'LOCKING in " .. screen_autolock_warn_sec .. " seconds'"
screen_autolock_warn_cmd = "echo \\\"naughty.notify({preset = naughty.config.presets.critical,text='LOCKING IN "
.. screen_autolock_warn_sec ..  " s', timeout=".. screen_autolock_warn_sec .. "})\\\" | awesome-client"
run_once('xautolock', '-time ' ..  screen_autolock_time
                      .. ' -locker "' .. screen_lock_cmd
                      .. '" -notifier "' .. screen_autolock_warn_cmd
                      .. '" -notify ' .. screen_autolock_warn_sec)

-------------------------------------------------------
-- start the applications                            --
-- modify this to your preferences                   --
-------------------------------------------------------

-- most importantly load the Xresources file for all X configs
-- (Xterm, urvxt, etc)
run_once('xrdb', '-load ~/.Xresources')

-- make sure gnome authentication works
-- (for unlock of settings windows and installing of updates)
-- refer to:
-- https://bugs.launchpad.net/ubuntu/+source/synaptic/+bug/912857
run_once('/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1')
-- run_once('/usr/lib/policykit-1/polkitd')

-- start dropbox
run_once('dropbox', 'start')

-- update notifications
run_once('update-notifier')

-- sound: pulse & applet
run_once('start-pulseaudio-x11')
run_once('gnome-sound-applet')

-- network applet
run_once('nm-applet')

-- printer applet
run_once('system-config-printer-applet')

-- automount (gnome fallback dependency!)
-- run_once('/usr/lib/gnome-settings-daemon/gnome-fallback-mount-helper')

-- touchpad settings app
-- run_once('/opt/extras.ubuntu.com/touchpad-indicator/bin/touchpad-indicator')
