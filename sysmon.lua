
local vicious = require("vicious")
vicious.contrib = require("vicious/contrib")

local sysmon = {}

local function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function gradient(color, to_color, min, max, value)
    local function color2dec(c)
        return tonumber(c:sub(2,3),16), tonumber(c:sub(4,5),16), tonumber(c:sub(6,7),16)
    end

    local factor = 0
    if (value >= max ) then 
        factor = 1  
    elseif (value > min ) then 
        factor = (value - min) / (max - min)
    end 

    local red, green, blue = color2dec(color) 
    local to_red, to_green, to_blue = color2dec(to_color) 

    red   = red   + (factor * (to_red   - red))
    green = green + (factor * (to_green - green))
    blue  = blue  + (factor * (to_blue  - blue))

    -- dec2color
    return string.format("#%02x%02x%02x", red, green, blue)
end

local function net_string(kb_value)
    local prefixes = {"kbs","Mbs","Gbs","Tbs"}
    local cur_prefix = 1
    local val = tonumber(kb_value)
    while val >= 1000.0 do
        cur_prefix = cur_prefix + 1
        val = val / 1024.0
    end
    val = round(val, 1)
    return string.format("%5.1f " .. prefixes[cur_prefix], val)
end

function sysmon.get_vol_widget(beautiful, use_icon, use_graphs, audio_device)
    -- PulseAudio widget for audio-control
    require("vicious.contrib")

    -- create layout
    local vol_widget_layout = wibox.layout.fixed.horizontal()

    -- add icon
    local vol_icon = nil
    if use_icon then
        vol_icon = wibox.widget.imagebox(beautiful.widget_vol)
        vol_icon:buttons(vol_buttons)
        vol_widget_layout:add(vol_icon)
    end

    -- add text 
    local vol_text = wibox.widget.textbox()
    vol_widget_layout:add(vol_text)

    -- add graph
    local volbarwidget = nil
    if use_graphs then
        volbarwidget = awful.widget.progressbar()
        -- Progressbar properties
        volbarwidget:set_width(4)
        --volbarwidget:set_height(10)
        volbarwidget:set_vertical(true)
        volbarwidget:set_height(beautiful.awful_widget_height)
        volbarwidget:set_max_value(100)
        volbarwidget:set_background_color(beautiful.graph_bg)
        volbarwidget:set_border_color(nil)
        volbarwidget:set_color(beautiful.graph_fg)
        volbarwidget:buttons(vol_buttons)
        vol_widget_layout:add(volbarwidget)
    end


    local function update_vol_widgets(widget, args)
        local vol = tonumber(args[1])

        -- set text
        if use_icon then
            vol_text:set_text(string.format("%3u%% ", vol))
        else
            vol_text:set_text(string.format("vol: %3u%% ", vol))
        end

        -- set icon
        if use_icon then
            if vol == 0 then
                vol_icon:set_image(beautiful.widget_vol_mute)
            elseif vol <= 50 then
                vol_icon:set_image(beautiful.widget_vol_low)
            else
                vol_icon:set_image(beautiful.widget_vol)
            end
        end

        -- set graphs
        if use_graphs then
            -- update all the bars
            volbarwidget:set_value(vol)
        end

        return ""
    end

    -- create mouse buttons
    local vol_buttons = awful.util.table.join(
        awful.button({ }, 1, function () awful.util.spawn(audio_controller) end),
     -- awful.button({ }, 4, function () vicious.contrib.pulse.add(5, audio_device); vicious.force({vol, volbarwidget}) end),
        awful.button({ }, 4,
            function ()
                vicious.contrib.pulse.add(5, audio_device)
                update_vol_widgets(nil, vicious.contrib.pulse())
            end),
        awful.button({ }, 5,
            function ()
                vicious.contrib.pulse.add(-5, audio_device)
                update_vol_widgets(nil, vicious.contrib.pulse())
            end)
         )

    -- add buttons to all widgets
    vol_text:buttons(vol_buttons)
    if use_icon then
        vol_icon:buttons(vol_buttons)
    end
    if use_graphs then
        volbarwidget:buttons(vol_buttons)
    end

    -- create pseudo widget
    local pseudowidget = wibox.widget.textbox()

    -- register pulse audio 
    vicious.register(pseudowidget , vicious.contrib.pulse, update_vol_widgets, 10)

    return vol_widget_layout
end

function sysmon.get_bat_widget(beautiful, use_icon, use_graphs)
    -- create layout
    local bat_widget_layout = wibox.layout.fixed.horizontal()

    -- add icon
    if use_icon then
        bat_icon = wibox.widget.imagebox(beautiful.widget_battery)
        bat_widget_layout:add(bat_icon)
    end

    -- add textual part
    local bat_text = wibox.widget.textbox()
    bat_widget_layout:add(bat_text)

    -- add tooltip
    local bat_tt = awful.tooltip({objects={bat_text},})

    -- create a batory widget for vicious
    -- Initialize widget
    if use_graphs then
        local batwidget = awful.widget.progressbar()
        -- Progressbar properties
        batwidget:set_width(4)
        --batwidget:set_height(10)
        batwidget:set_vertical(true)
        batwidget:set_background_color(beautiful.graph_bg)
        batwidget:set_border_color(nil)
        -- batwidget:set_color(get_default_gradient(40))
        batwidget:set_color(beautiful.graph_fg)
        -- Register widget
        vicious.register(batwidget, vicious.widgets.bat, "$2", update_intervall, "BAT0")
        bat_widget_layout:add(batwidget)
    end

    local pseudowidget = wibox.widget.textbox()

    vicious.register(pseudowidget, vicious.widgets.bat,
        function (widget, args)
            local perc = args[2]
            local time = args[3]
            local status = args[1]
            if use_icon then
                bat_text:set_text(string.format(status .. " %3u%% ", perc))
            else
                bat_text:set_text(string.format("bat: " .. status .. " %3u%% ", perc))
            end
            -- set tooltip to remaining time
            bat_tt:set_text("Time remaining: " .. time)

            -- set icon
            if use_icon then
                if perc < 20 then
                    bat_icon:set_image(beautiful.widget_battery_empty)
                elseif perc <= 50 then
                    bat_icon:set_image(beautiful.widget_battery_low)
                else
                    bat_icon:set_image(beautiful.widget_battery)
                end
            end

            return ""
        end
      , update_intervall, "BAT0")
    return bat_widget_layout
end

function sysmon.get_mem_widget(beautiful, use_icon, use_graphs)
    -- create layout
    local mem_widget_layout = wibox.layout.fixed.horizontal()

    -- add icon
    if use_icon then
        mem_widget_layout:add(wibox.widget.imagebox(beautiful.widget_mem))
    end

    -- add textual part
    local mem_text = wibox.widget.textbox()
    vicious.register(mem_text, vicious.widgets.mem, 
        function (widget, args)
            if use_icon then
                return string.format("%3u%% ", args[1])
            else
                return string.format("mem: %3u%% ", args[1])
            end
        end
      , update_intervall)

    mem_widget_layout:add(mem_text)

    -- create a memory widget for vicious
    -- Initialize widget
    if use_graphs then
        local memwidget = awful.widget.progressbar()
        -- Progressbar properties
        memwidget:set_width(4)
        --memwidget:set_height(10)
        memwidget:set_vertical(true)
        memwidget:set_background_color(beautiful.graph_bg)
        memwidget:set_border_color(nil)
        -- memwidget:set_color(get_default_gradient(40))
        memwidget:set_color(beautiful.graph_fg)
        -- Register widget
        vicious.register(memwidget, vicious.widgets.mem, "$1", update_intervall)
        mem_widget_layout:add(memwidget)
    end

    return mem_widget_layout
end

local mouse=require('mouse')
local tm = require('timer')

-- save the popups once created, so that they don't have to be created
-- from scratch every time it opens
local popups = {}

function sysmon.cpu_popup(args)
    local values = args.values
    local cpupopup
    local graph_width = 200
    local graph_height = 100
    local stats_cmd = '/bin/ps --sort=-%cpu,-%mem -eo fname,%cpu,%mem | head -n 6'
    local title = 'CPU'
    local max_value = 400

    local max_val = max_value or 100

    local function update()
        -- update graph data
        local data = vicious.widgets.cpu()
        if #data > 1 then
            for i = 1, #data do
                cpupopup.graph:add_value(data[i],i)
            end
        else
            cpupopup.graph:add_value(data)
        end
        -- update stats
        if stats_cmd then
            -- get new stats and assign to textbox
            local stats = awful.util.pread(stats_cmd)
            if stats:sub(-1) == '\n' then
                stats = stats:sub(1,-2) -- trim trailing character
            end
            cpupopup.stats:set_markup(stats)
        end
    end

    if not popups.cpu then
        cpupopup = {}
        -- create wibox
        cpupopup.box = wibox({fg = beautiful.fg_normal, bg=beautiful.bg_normal, type="notification"})
        cpupopup.box.ontop = true

        -- create graph(s)
        if args.values.groups then
            cpupopup.graph = awful.widget.graph()
            cpupopup.graph:set_width(graph_width)
            cpupopup.graph:set_height(graph_height)
            cpupopup.graph:set_background_color(beautiful.background_normal)
            cpupopup.graph:set_stack(true)
            -- generate colors based on color gradient
            local stack_colors = {}
            for i = 1, #values.groups do
                table.insert(stack_colors, gradient(beautiful.bg_normal, beautiful.fg_focus, 0, #values.groups+3, i+2))
            end
            cpupopup.graph:set_stack_colors(stack_colors);
            cpupopup.graph:set_max_value(max_val)
            cpupopup.graph:set_border_color(beautiful.fg_focus)
        else
            cpupopup.graph = awful.widget.graph()
            cpupopup.graph:set_width(graph_width)
            cpupopup.graph:set_height(graph_height)
            cpupopup.graph:set_background_color(beautiful.bg_normal)
            cpupopup.graph:set_color(gradient(beautiful.bg_normal, beautiful.fg_focus, 0, 3, 2))
            cpupopup.graph:set_max_value(max_val)
            cpupopup.graph:set_border_color(beautiful.fg_focus)
        end

        cpupopup.stats = wibox.widget.textbox()
        local stats_marg = wibox.layout.margin()
        stats_marg:set_widget(cpupopup.stats)
        stats_marg:set_margins(3)
        local graph_marg = wibox.layout.margin()
        graph_marg:set_widget(cpupopup.graph)
        graph_marg:set_margins(5)
        cpupopup.lay = wibox.layout.fixed.vertical()
        cpupopup.lay:add(wibox.widget.textbox("<span color='" .. beautiful.fg_focus .. "'><b> " .. title .. "</b></span>"))
        cpupopup.lay:add(graph_marg)
        cpupopup.lay:add(stats_marg)

        cpupopup.mar = wibox.layout.margin()
        cpupopup.mar:set_margins(2)
        cpupopup.mar:set_widget(cpupopup.lay)
        -- add cpupopup to wibox
        cpupopup.box:set_widget(cpupopup.mar)


        -- create timer
        -- TODO: only one timer per system component (cpu,mem)
        --       otherwise the measurement data interferes with each other
        local tm = timer({ timeout = 1 })
        if tm.connect_signal then
            tm:connect_signal("timeout", update)
        else
            tm:add_signal("timeout", update)
        end
        cpupopup.timer = tm

        -- cache the popup wibox and widgets
        popups.cpu = cpupopup
    else
        -- retrieve cached widget
        cpupopup = popups.cpu

        -- prefill graph with zeros if not full
        if args.values.groups then
            if #values.groups[1] < graph_width then
                for i = #values.groups[1]+1, graph_width do
                    for g = 1, #values.groups do
                        cpupopup.graph:add_value(0, g)
                    end
                end
            end
        else
            if #values < graph_width then
                for i = #values+1, graph_width do
                    cpupopup.graph:add_value(0)
                end
            end
        end
    end

    -- get new stats and assign to textbox
    local stats = awful.util.pread(stats_cmd)
    if stats:sub(-1) == '\n' then
        stats = stats:sub(1,-2) -- trim trailing character
    end
    cpupopup.stats:set_markup(stats)

    -- figure out how big the widget is
    local w, h = wibox.layout.base.fit_widget(cpupopup.mar,1000,1000)
    -- set the wibox size accordingly
    cpupopup.box:geometry({width=w,height=h,x=mouse.coords().x,y=beautiful.awful_widget_height})
    -- fill graph
    if args.values.groups then
        for i = 1, #values.groups[1] do
            for g = 1, #values.groups do
                cpupopup.graph:add_value(values.groups[g][i], g)
            end
        end
    else
        for i = 1, #values do
            cpupopup.graph:add_value(values[i])
        end
    end
    cpupopup.box.visible = true
    cpupopup.timer:start()
    return cpupopup
end

function sysmon.close_popup(popup)
    popup.timer:stop()
    popup.box.visible = false
end

function sysmon.get_cpu_widget(beautiful, use_icon, use_graphs, graph_vertical)
    vicious.cache(vicious.widgets.cpu)
    -- create layout
    local cpu_widget_layout = wibox.layout.fixed.horizontal()

    -- get number of CPUs
    local n_cpus = #vicious.widgets.cpu()-1

    if use_icon then
        cpu_widget_layout:add(wibox.widget.imagebox(beautiful.widget_cpu))
    end

    -- create cpu text widget
    cpu_text = wibox.widget.textbox()
    cpu_widget_layout:add(cpu_text)

    -- add graphs
    if use_graphs then
        cpu_bars_widgets = {}
        local cpu_bars = nil
        if graph_vertical then
            cpu_bars = wibox.layout.fixed.horizontal()
            for i = 1, n_cpus do
                -- create n bar widgets
                cpu_bars_widgets[i] = awful.widget.progressbar()
                cpu_bars_widgets[i]:set_width(4)
                cpu_bars_widgets[i]:set_max_value(100)
                cpu_bars_widgets[i]:set_background_color(beautiful.graph_bg)
                cpu_bars_widgets[i]:set_color(beautiful.graph_fg)
                cpu_bars_widgets[i]:set_height(beautiful.awful_widget_height)
                cpu_bars_widgets[i]:set_vertical(true)
                cpu_bars:add(cpu_bars_widgets[i])
            end
        else
            cpu_bars = wibox.layout.flex.vertical()

            for i = 1, n_cpus do
                -- create n bar widgets

                local height_per_bar = math.floor((beautiful.awful_widget_height-n_cpus) / n_cpus)
                cpu_bars_widgets[i] = awful.widget.progressbar()
                cpu_bars_widgets[i]:set_width(40)
                cpu_bars_widgets[i]:set_max_value(100)
                cpu_bars_widgets[i]:set_background_color(beautiful.graph_bg)
                cpu_bars_widgets[i]:set_color(beautiful.graph_fg)
                cpu_bars_widgets[i]:set_height(height_per_bar)
                cpu_bars_widgets[i]:set_vertical(false)
                cpu_bars:add(cpu_bars_widgets[i])
            end
        end
        cpu_widget_layout:add(cpu_bars)
    end


    -- create pseudo widget
    local cpu_pseudowidget = wibox.widget.textbox()
    cpu_pseudowidget.values = {}

    if n_cpus > 1 then
        cpu_pseudowidget.values.groups = {}
        for i = 1, n_cpus do
            cpu_pseudowidget.values.groups[i] = {}
        end
    end

    local popup = {}

    -- register cpuwidgets
    vicious.register(cpu_pseudowidget , vicious.widgets.cpu,
        function (widget, args)
            -- display the total cpu consumption sum in text field
            -- -- TODO: variable!
            local cpu_sum = 0
            for i = 1, n_cpus do
                cpu_sum = cpu_sum + args[i+1]
            end
            if use_icon then
                cpu_text:set_text(string.format("%3u%% ", cpu_sum))
            else
                cpu_text:set_text(string.format("cpus: %3u%% ", cpu_sum))
            end

            if use_graphs then
                -- update all the bars
                for i = 1, n_cpus do
                    cpu_bars_widgets[i]:set_value(args[i+1])
                end
            end
            -- add total value to value memory
            -- TODO: impelement as circular buffer for efficiency
            if n_cpus > 1 then
                for i = 1, n_cpus do
                    table.insert(cpu_pseudowidget.values.groups[i], args[i+1])
                end
            else
                table.insert(cpu_pseudowidget.values, cpu_sum)
            end
            -- TODO: clear old values
            return ""
        end
        , 1)

    cpu_widget_layout:connect_signal('mouse::enter', function ()
        popup = sysmon.cpu_popup({values = cpu_pseudowidget.values})
    end)
    cpu_widget_layout:connect_signal('mouse::leave', function ()
        sysmon.close_popup(popup)
    end)

    return cpu_widget_layout
end


function sysmon.get_net_widgets(beautiful, use_icon, use_graphs, net_device)

    -- enable caching for netwidgets
    vicious.cache(vicious.widgets.net)

    -- create the horizontal layout for the network widgets
    local netwidgets = {}

    local net_texts = {nil, nil}

    for i,up_down in pairs({"down", "up"}) do


        net_texts[i] = wibox.widget.textbox()
        local netwidget_layout = wibox.layout.fixed.horizontal()

        if use_icon then
            if up_down == "up" then
                net_icon = wibox.widget.imagebox(beautiful.widget_net_up)
            else
                net_icon = wibox.widget.imagebox(beautiful.widget_net_down)
            end
            netwidget_layout:add(net_icon)
        end
        netwidget_layout:add(net_texts[i])
        if use_graphs then
            netwidget = awful.widget.graph()
            -- Graph properties
            netwidget:set_width(50)
            -- netwidget_down:set_background_color("#494B4F")
            netwidget:set_background_color("#333333")
            netwidget:set_color("#CC33FF")
            netwidget:set_scale(true)
            --netwidget_down:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
            -- Register widget
            vicious.register(netwidget, vicious.widgets.net, "${" .. net_device .. " " .. up_down .. "_kb}", update_intervall)
            netwidget_layout:add(netwidget)
        end

        table.insert(netwidgets, netwidget_layout)
    end

    local pseudo_widget = wibox.widget.textbox()
    vicious.register(pseudo_widget, vicious.widgets.net,
        function (widget, args)
            local kb_down = args["{" .. net_device .. " down_kb}"]
            local kb_up = args["{" .. net_device .. " up_kb}"]
            net_texts[1]:set_text(net_string(kb_down))
            net_texts[2]:set_text(net_string(kb_up))
            return ""
        end
        , update_intervall)

    return netwidgets[1], netwidgets[2]
end


function sysmon.get_widgets(beautiful, use_icon, use_graphs, update_intervall, net_device)

    -- get CPU widget
    local cpuwidget = sysmon.get_cpu_widget(beautiful, use_icon, true, true)

    -- get mem widget
    local memwidget = sysmon.get_mem_widget(beautiful, use_icon, true)

    -- get network widget
    local netwidget1, netwidget2 = sysmon.get_net_widgets(beautiful, use_icon, true, net_device)

    -- get battery widget but only if there is a battery
    if (vicious.widgets.bat("", "BAT0")[2] > 0) then
        batwidget = sysmon.get_bat_widget(beautiful, use_icon, true)
    end

    return {netwidget1, netwidget2, memwidget, cpuwidget, batwidget}
end

return sysmon
