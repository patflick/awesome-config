------------------------------------
--         Configuration          --
------------------------------------

-- default programs:

-- terminal:
terminal = "x-terminal-emulator"
-- browser:
browser="chromium-browser"

-- editor:
-- editor = os.getenv("EDITOR") or "editor"
editor = "vim"
editor_cmd = terminal .. " -e " .. editor

-- PULSE audio controller program, to be spawned when clicked on the audio control
audio_controller = "pavucontrol"
-- pulse audio device for use in the audio control
audio_device = "alsa_output.pci-0000_00_07.0.analog-stereo"

-- network device for the up/download stats
net_device = "eth0"
-- net_dev = "wifi0"

-- whether or not to show the sysmon widgets
-- Consider: they can eat up system ressources, don't turn them on
-- on a laptop or such.
show_sysmon_widgets = true
-- update interval for sysmon widgets, every X seconds
sysmon_update_intervall = 2


------------------------------------
--        Load Libraries          --
------------------------------------

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- load delightful widgets
vicious = require("vicious")

-- Load Debian menu entries
require("debian.menu")


-- defines the gradient colors

-- heatmap:
gradient_colors = {"#0000FF", "#00FFFF", "#00FF00", "#FFFF00", "#FF0000"}
-- old green->orange->red gradient
-- gradient_colors = { "#AECF96", "#88A175", "#FF5656" }


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
default_tags = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
default_layout = layouts[2]
default_layouts = {default_layout, default_layout, default_layout,
                   default_layout, default_layout, default_layout,
                   default_layout, default_layout, default_layout}

-- first screen:
s1_tags = default_tags
tags[1] = awful.tag(s1_tags, 1, default_layouts)


if (screen.count() > 1) then
    -- second screen
    s2_tags = default_tags
    s2_tags[3] = "music"
    s2_tags[4] = "torrent"
    tags[2] = awful.tag(s2_tags, 2, default_layouts)
end

-- for all further screens
if (screen.count() > 2) then
    for s = 3, screen.count() do
        -- Each screen has its own tag table.
        tags[s] = awful.tag(default_tags, s, default_layouts)
    end
end
-- }}}



-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywiboxtop = {}
mywiboxbottom = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))



------------------------------------
--     System monitor widgets     --
------------------------------------


if show_sysmon_widgets then

    total_height = 19

    -- create a memory widget for vicious
    -- Initialize widget
    memwidget = awful.widget.progressbar()
    -- Progressbar properties
    memwidget:set_width(40)
    --memwidget:set_height(10)
    memwidget:set_vertical(false)
    memwidget:set_background_color("#494B4F")
    memwidget:set_border_color(nil)
    memwidget:set_color("#AECF96")
    memwidget:set_gradient_colors(gradient_colors)
    -- Register widget
    vicious.register(memwidget, vicious.widgets.mem, "$1", sysmon_update_intervall)


    -- cpu widget

    -- get number of CPUs in the system
    n_cpus = #vicious.widgets.cpu()-1
    cpu_bars = {}
    for i = 1, n_cpus do
        -- create n bar widgets
        -- TODO get this somehow automatically
        
        height_per_bar = math.floor((total_height-n_cpus) / n_cpus)
        cpu_bars[i] = awful.widget.progressbar()
        cpu_bars[i]:set_width(40)
        cpu_bars[i]:set_max_value(100)
        cpu_bars[i]:set_background_color("#494B4F")
        cpu_bars[i]:set_gradient_colors(gradient_colors)
        cpu_bars[i]:set_height(height_per_bar)
        cpu_bars[i]:set_vertical(false)
    end

    cpu_bars["layout"] = awful.widget.layout.vertical.flex

    -- create cpu text widget
    cpu_text = widget({ type = "textbox" })
    cpu_text.width = 80

    -- create pseudo widget
    pseudowidget = widget({type = "textbox"})

    -- register cpuwidget
    vicious.register(pseudowidget, vicious.widgets.cpu, 
        function (widget, args)
            -- display the total cpu consumption sum in text field
            cpu_sum = 0
            for i = 1, n_cpus do
                cpu_sum = cpu_sum + args[i+1]
            end
            cpu_text.text = "   cpus: " .. cpu_sum .. "%"

            -- update all the bars
            for i = 1, n_cpus do
                cpu_bars[i]:set_value(args[i+1])
            end
        end
        , sysmon_update_intervall)

    -- Initialize widget
    -- cpuwidget = awful.widget.graph()
    -- Graph properties
    --cpuwidget:set_width(50)
    --cpuwidget:set_stack(false)
    --cpuwidget:set_max_value(400)
    --cpuwidget:set_background_color("#333333")
    --cpuwidget:set_color("#FF5656")
    ----cpuwidget:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
    ---- cpuwidget:set_stack_colors({"#FFFF66", "#0066FF", "#FF3300", "#009933"})
    ---- Register widget
    --vicious.register(cpuwidget, vicious.widgets.cpu, 
    --    function (widget, args)
    --        cpuwidget:add_value(args[2] + args[3] + args[4] + args[5]) -- add all cores at once
    --        -- cpuwidget:add_value(args[3], 2)
    --        -- cpuwidget:add_value(args[4], 3)
    --        -- cpuwidget:add_value(args[5], 4) -- core 4, color 4
    --    end, sysmon_update_intervall)



    --vicious.register(cpu_text, vicious.widgets.cpu, "   cpu: $1% ", sysmon_update_intervall)

    mem_text = widget({ type = "textbox" })
    mem_text.width = 80
    vicious.register(mem_text, vicious.widgets.mem, "   mem: $1% ", sysmon_update_intervall)


    -- enable caching for netwidgets
    vicious.cache(vicious.widgets.net)


    netwidget_down = awful.widget.graph()
    -- Graph properties
    netwidget_down:set_width(50)
    -- netwidget_down:set_background_color("#494B4F")
    netwidget_down:set_background_color("#333333")
    netwidget_down:set_color("#CC33FF")
    netwidget_down:set_scale(true)
    --netwidget_down:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
    -- Register widget
    vicious.register(netwidget_down, vicious.widgets.net, "${" .. net_device .. " down_kb}", sysmon_update_intervall)
    net_down_text = widget({ type = "textbox"})
    vicious.register(net_down_text, vicious.widgets.net, "  down: ${" .. net_device .. " down_kb} kbs ", sysmon_update_intervall)


    netwidget_up = awful.widget.graph()
    -- Graph properties
    netwidget_up:set_width(50)
    -- netwidget_up:set_background_color("#494B4F")
    netwidget_up:set_background_color("#333333")
    netwidget_up:set_color("#FF3399")
    -- netwidget_up:set_scale(true)
    --netwidget_up:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
    -- Register widget
    vicious.register(netwidget_up, vicious.widgets.net, "${" .. net_device .. " up_kb}", sysmon_update_intervall)
    net_up_text = widget({ type = "textbox"})
    vicious.register(net_up_text, vicious.widgets.net, "  up: ${" .. net_device .. " up_kb} kbs ", sysmon_update_intervall)



    stats_widgets = {
        cpu_text,
        cpu_bars,
        mem_text,
        memwidget,
        net_down_text,
        netwidget_down,
        net_up_text,
        netwidget_up,
        layout = awful.widget.layout.horizontal.leftright
    }
end


-- PulseAudio widget for audio-control
require("vicious.contrib")


volbarwidget = awful.widget.progressbar()
-- Progressbar properties
volbarwidget:set_width(5)
--volbarwidget:set_height(10)
volbarwidget:set_vertical(true)
volbarwidget:set_background_color("#494B4F")
volbarwidget:set_border_color(nil)
volbarwidget:set_color("#AECF96")
volbarwidget:set_gradient_colors(gradient_colors)
-- Register widget
vicious.register(volbarwidget, vicious.contrib.pulse, "$1", 10, audio_device)




vol = widget({type="textbox"})
vicious.register(vol, vicious.contrib.pulse, " $1%", 1, audio_device)
vol:buttons(awful.util.table.join(
  awful.button({ }, 1, function () awful.util.spawn(audio_controller) end),
  awful.button({ }, 4, function () vicious.contrib.pulse.add(5, audio_device); vicious.force({vol, volbarwidget}) end),
  awful.button({ }, 5, function () vicious.contrib.pulse.add(-5, audio_device); vicious.force({vol, volbarwidget}) end)
     ))


for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widgeat
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywiboxtop[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywiboxtop[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            show_sysmon_widgets and s == 1 and stats_widgets or nil,
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        s == 1 and mysystray or nil,
        mytextclock,
        volbarwidget.widget,
        vol,
                -- mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }

    -- create the bottom wibox
    mywiboxbottom[s] = awful.wibox({ position = "bottom", screen = s})
    -- add systray and tasklist to bottom wibox
    mywiboxbottom[s].widgets = {
        {
            mytasklist[s],
            --widget({ type = "systray" }),
            -- s == 1 and mysystray or nil,
            layout = awful.widget.layout.horizontal.leftright

        },
        -- s == 1 and mysystray or nil,
        -- mysystray,
        
        layout =  awful.widget.layout.horizontal.rightleft
    }


end
-- }}}



-- load keybindings
require("keybindings")

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}


if screen.count() > 1 then
table.insert(awful.rules.rules,
      { rule = {class = "Rhythmbox" },
        properties = { tag = tags[2][3]}})
table.insert(awful.rules.rules,
    { rule = { class = "Qbittorrent" },
        properties = { tag = tags[2][4]}})
end

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
