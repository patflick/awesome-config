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

-- start dropbox
run_once('dropbox', 'start')

-- start productivity app Tomate (https://launchpad.net/tomate/)
run_once('tomate')

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
run_once('/usr/lib/gnome-settings-daemon/gnome-fallback-mount-helper')

