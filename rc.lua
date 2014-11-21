------------------------------------------------
--   My Awesome 3.5 configuration             --
--    Author: Patrick Flick (github.com/r4d2) --
------------------------------------------------
-- Much of this configuration is `hacked` together
-- and I took ideas from many different sources.
-- Main features:
--  - freedesktop menu
--  - scratch drop down terminal
--  - sweet modularized theme (part of it is `stolen` from
--    copycat-killer `s awesome themes (https://github.com/copycat-killer/awesome-copycats)
--  - widgets: CPU, mem, network, pulse audio control, and task list
--  - separate files for configuration (config.lua) and autostart (autostart.lua)



------------------------------------
--        Load Libraries          --
------------------------------------

-- Standard awesome library
awful = require("awful")
wibox = require("wibox")
require("awful.autofocus")
awful.rules = require("awful.rules")
-- Theme handling library
beautiful = require("beautiful")
gears = require("gears")
-- Notification library
naughty = require("naughty")

-- load delightful widgets
vicious = require("vicious")

-- load scratch for drop-down terminal:
--  src (http://awesome.naquadah.org/wiki/Scratchpad_manager)
scratch = require("scratch")


-- load user configuration
require("config")

-- Load Debian menu entries

-- Use Free Desktop for debian menu (https://github.com/terceiro/awesome-freedesktop)
-- part of the repo as git submodule
require('awesome-freedesktop.freedesktop.utils')
freedesktop.utils.terminal = terminal  -- default: "xterm"
freedesktop.utils.icon_theme = 'gnome' -- look inside /usr/share/icons/, default: nil (don't use icon theme)
require('awesome-freedesktop.freedesktop.menu')




-- defines the gradient colors

-- heatmap:
default_gradient_colors = {"#0000FF", "#00FFFF", "#00FF00", "#FFFF00", "#FF0000"}

function get_linear_gradient_vert(height, colors)
  result = { type = "linear", from = { 0, 0 }, to = { 0,  height}}
  stops = {}
  for i = 0, #colors - 1 do
    stops[i+1] = {i*1.0/(#colors - 1), colors[#colors - i]}
  end
  result["stops"] = stops
  return result
end

function get_linear_gradient_horiz(width, colors)
  
  result = { type = "linear", from = { 0, 0 }, to = { width,  0}}
  stops = {}
  for i = 0, #colors - 1 do
    stops[i+1] = {i*1.0/(#colors - 1), colors[i+1]}
  end
  result["stops"] = stops
  return result
end

function get_default_gradient(width)
  return get_linear_gradient_horiz(width, default_gradient_colors)
end

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
    awesome.connect_signal("debug::error", function (err)
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

beautiful.init(awful.util.getdir("config") .. "/themes/" .. use_theme .. "/theme.lua")

-- set background wallpaper
for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
end


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
    -- s2_tags[3] = "music"
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

-- create Freedesktop main menu
menu_items = freedesktop.menu.new()
myawesomemenu = {
   { "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help' }) },
   { "edit config", editor_cmd .. " " .. awesome.conffile, freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
   { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
   { "quit", awesome.quit, freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
}
table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'}) })


mymainmenu = awful.menu.new({ items = menu_items })




mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a systray
mysystray = wibox.widget.systray()

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

sysmon = require('sysmon')

volwidget = sysmon.get_vol_widget(beautiful, true, true, audio_device)

spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)


local function combine_widgets(widgets)
    local wid_layout = wibox.layout.fixed.horizontal()

    -- start with a space
    wid_layout:add(spr)

    -- make sure this always ends in black
    if #widgets % 2 == 0 then
        wid_layout:add(arrl)
    else
        wid_layout:add(arrl_ld)
    end

    for j, v in ipairs(widgets) do
        local i = #widgets - j + 1
        if i % 2 == 0 then
            wid_layout:add(widgets[i])
            wid_layout:add(spr)
        else
            wid_layout:add(wibox.widget.background(widgets[i],beautiful.widgets_bg_2))
            wid_layout:add(wibox.widget.background(spr, beautiful.widgets_bg_2))
        end
        if i ~= 1 then
            if i % 2 == 0 then
                wid_layout:add(arrl_ld)
            else
                wid_layout:add(arrl_dl)
            end
        end
    end

    wid_layout:add(arrl_dl)

    return wid_layout
end

common = require('awful.widget.common')

local function custom_tasklist_update(w, buttons, label, data, objects)
     -- update the widgets, creating them if needed
     w:reset()
     local task_widgets = {}
     for i, o in ipairs(objects) do
         local text, bg, bg_image, icon = label(o)
         -- build custom task list
         local lay = wibox.layout.fixed.horizontal()
         local ib = wibox.widget.imagebox(icon)
         lay:add(ib)
         local textb = wibox.widget.textbox(text)
         lay:add(textb)
         --lay:add(spr)
         lay:buttons(common.create_buttons(buttons, o))
         -- fixed width
         lay.fit = function(widget, w, h) return 100, h end
         -- w:add(lay)
         table.insert(task_widgets, lay)
         if i < #objects then
             --table.insert(task_widgets, spr)
             table.insert(task_widgets, arrl_ld)
             table.insert(task_widgets, arrl_dl)
         end
     end
     if #task_widgets > 0 then
         --local combined = combine_widgets(task_widgets)
         for i, wid in ipairs(task_widgets) do
            w:add(wid)
         end
     end
     return w
end

tasklist_layout = {}

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widgeat
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)



    -- Create the wibox
    mywiboxtop[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters

    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])


    -- put together all the widgets
    -- (right to left)
    right_widgets = {mylayoutbox[s]}
    if (s == 1) then
        table.insert(right_widgets, mysystray)
    end
    table.insert(right_widgets, mytextclock)
    table.insert(right_widgets, volwidget)
    if show_sysmon_widgets and s == 1 then
        sys_widgets = sysmon.get_widgets(beautiful, true, true, sysmon_update_intervall, net_device)
        for i,v in pairs(sys_widgets) do
            table.insert(right_widgets, v)
        end
    end

    -- add the task list
    tasklist_layout[s] = wibox.layout.fixed.horizontal()
    --table.insert(right_widgets, spr)

    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons, nil, custom_tasklist_update, tasklist_layout[s])

    widgets_layout = combine_widgets(right_widgets)
    right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(combine_widgets({tasklist_layout[s]}))
    right_layout:add(widgets_layout)


    local top_layout = wibox.layout.align.horizontal()
    top_layout:set_left(left_layout)
    -- layout:set_middle(mytasklist[s])
    top_layout:set_right(right_layout)

    mywiboxtop[s]:set_widget(top_layout)

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


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    -- new start up always as slave to other windows on the current screen
    awful.client.setslave(c)

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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}



------------------------------------
--    Autostart applets and apps  --
------------------------------------
require('autostart')


