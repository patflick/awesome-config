
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
    -- formated output, pad with spaces for equal space use
    -- indepependent of quantity
    local floatstr = string.format("%.1f " .. prefixes[cur_prefix], val)
    return string.format("%9s", floatstr)
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
    local mem_widget = wibox.layout.fixed.horizontal()

    -- add icon
    if use_icon then
        mem_widget:add(wibox.widget.imagebox(beautiful.widget_mem))
    end

    -- add textual part
    local mem_text = wibox.widget.textbox()
    mem_widget:add(mem_text)

    -- create a memory widget for vicious
    -- Initialize widget
    if use_graphs then
        local graph = awful.widget.progressbar()
        -- Progressbar properties
        graph:set_width(4)
        --graph:set_height(10)
        graph:set_vertical(true)
        graph:set_max_value(100)
        graph:set_background_color(beautiful.graph_bg)
        graph:set_border_color(nil)
        -- graph:set_color(get_default_gradient(40))
        graph:set_color(beautiful.graph_fg)
        mem_widget:add(graph)
        mem_widget.graph = graph
    end

    -- create popup
    mem_widget.popup = sysmon.create_popup(mem_widget, {
            stats_cmd = "/bin/ps --sort=-%mem -eo fname,%mem | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}' | sort -nk2r | column -t | head -n 6",
--            stats_cmd = "/bin/ps --sort=-%mem -eo fname,%mem | head -n 6",
            stack = true,
            title = 'RAM',
            number_graphs = 2,
            max_value = 100
             })

    mem_widget.update = function()
        local args = vicious.widgets.mem()
        -- use percentage of buffered+used memory instead of used
        --local membuf = math.floor(args[9] * 100.0 / args[3])
        local memuse = math.floor(args[2] * 100.0 / args[3])
        local membufuse = math.floor((args[9] - args[2]) * 100.0 / args[3])
        local membuf = memuse + membufuse
        if use_icon then
            mem_text:set_text(string.format("%3u%% ", membuf))
        else
            mem_text:set_text(string.format("mem: %3u%% ", membuf))
        end
        if use_graphs then
            mem_widget.graph:set_value(membuf)
        end
        mem_widget.popup.update({memuse, membufuse})
    end

    -- create timer
    local tm = timer({ timeout = 5 })
    if tm.connect_signal then
        tm:connect_signal("timeout", mem_widget.update)
    else
        tm:add_signal("timeout", mem_widget.update)
    end
    mem_widget.timer = tm
    mem_widget.timer:start()

    -- return widget
    return mem_widget
end

local mouse=require('mouse')
local tm = require('timer')

-- save the popups once created, so that they don't have to be created
-- from scratch every time it opens
local popups = {}


function sysmon.create_popup(widget, args)
    --local values = args.values or nil
    local graph_width = args.graph_width or 200
    local graph_height = args.graph_height or 100
    local stats_cmd = args.stats_cmd or nil
    local title = args.title or ''
    local max_value = args.max_value
    local scale = args.scale or false
    local stack = args.stack or false
    local popup = {}

    -- save some parameters
    popup.stack = stack
    popup.graph_width = graph_width
    popup.stats_cmd = stats_cmd
    popup.ng = args.number_graphs or 0
    -- inititalize value buffers
    popup.value_buffer = {}
    popup.value_buffer.groups = {}
    for i = 1, popup.ng do
        popup.value_buffer.groups[i] = {}
    end

    popup.update = function(update_data)
        -- update graph data
        local data = update_data
        if data ~= nil then
            if type(data) ~= "table" then
                data = {data}
            end
            -- save data into local buffer
            for i = 1, popup.ng do
                table.insert(popup.value_buffer.groups[i], data[i])
                -- remove from front if full
                while #popup.value_buffer.groups[i] > popup.graph_width do
                    table.remove(popup.value_buffer.groups[i], 1)
                end
            end
            -- update graphs in popup if its currently active
            if popup.box.visible then
                if #data > 1 and stack then
                    for i = 1, #data do
                        popup.graphs[1]:add_value(data[i],i)
                    end
                else
                    for i = 1, #data do
                        popup.graphs[i]:add_value(data[i])
                    end
                end
            end
        end
        -- update stats
        if stats_cmd and popup.stats and popup.box.visible then
            -- get new stats and assign to textbox
            local stats = awful.util.pread(stats_cmd)
            if stats:sub(-1) == '\n' then
                stats = stats:sub(1,-2) -- trim trailing character
            end
            popup.stats:set_markup(stats)
        end
    end

    -- default max
    if max_value == nil and scale == false and stack then
        max_value = 100*popup.ng
    elseif scale == false then
        max_value = 100
    end

    -- get number of data rows (i.e., number of stacks or number of graphs)
    if popups[widget] == nil then
        -- create wibox
        popup.box = wibox({fg = beautiful.fg_normal, bg=beautiful.bg_normal, type="notification"})
        popup.box.ontop = true

        -- create graph(s)
        popup.graphs = {}
        if popup.ng > 1 and stack then
            -- create single stack graph
            local graph =  awful.widget.graph()
            graph:set_width(graph_width)
            graph:set_height(graph_height)
            if scale then
                graph:set_scale(scale)
            else
                graph:set_max_value(max_value)
            end
            graph:set_background_color(beautiful.background_normal)
            graph:set_stack(true)
            -- generate colors based on color gradient
            local stack_colors = {}
            for i = 1, popup.ng do
                table.insert(stack_colors, gradient(beautiful.bg_normal, beautiful.fg_focus, 0, popup.ng+3, i+2))
            end
            graph:set_stack_colors(stack_colors);
            graph:set_border_color(beautiful.fg_focus)
            popup.graphs[1] = graph
        else
            assert(not stack, "can't stack 1 graph")
            for i = 1, popup.ng do
                local graph = awful.widget.graph()
                graph:set_width(graph_width)
                graph:set_height(graph_height)
                if scale then
                    graph:set_scale(scale)
                else
                    graph:set_max_value(max_value)
                end
                graph:set_background_color(beautiful.bg_normal)
                graph:set_color(gradient(beautiful.bg_normal, beautiful.fg_focus, 0, 2, 1))
                graph:set_border_color(beautiful.fg_focus)
                popup.graphs[i] = graph
            end
        end

        -- add graphs to popup
        popup.lay = wibox.layout.fixed.vertical()
        for i = 1, #popup.graphs do
            local graph_marg = wibox.layout.margin()
            graph_marg:set_widget(popup.graphs[i])
            graph_marg:set_margins(5)
            local graph_title
            if type(title) == "table" then
                graph_title = title[i]
            else
                graph_title = title
                if #popup.graphs > 1 then
                    graph_title = " " .. i
                end
            end
            popup.lay:add(wibox.widget.textbox("<span color='" .. beautiful.fg_focus .. "'><b> " .. graph_title .. "</b></span>"))
            popup.lay:add(graph_marg)
        end

        -- add stats part below graph
        if stats_cmd then
            popup.stats = wibox.widget.textbox()
            local stats_marg = wibox.layout.margin()
            stats_marg:set_widget(popup.stats)
            stats_marg:set_margins(3)
            popup.lay:add(stats_marg)
        end

        -- add popup to wibox with another margin
        popup.mar = wibox.layout.margin()
        popup.mar:set_margins(2)
        popup.mar:set_widget(popup.lay)
        popup.box:set_widget(popup.mar)


        -- connect mouse signals
        widget:connect_signal('mouse::enter', function ()
                -- open popup
                sysmon.open_popup(popup)
            end)
        widget:connect_signal('mouse::leave', function ()
            sysmon.close_popup(popup)
        end)

        -- set reference
        popup.parent_widget = widget

        -- cache the popup wibox and widgets
        popups[widget] = popup
    else
        popup = popups[widget]
    end

    return popup
end

function sysmon.open_popup(popup)
    local values = popup.value_buffer

    -- prefill graph with zeros if not full
    if popup.ng > 0 then
        if #values.groups[1] < popup.graph_width then
            for g = 1, popup.ng do
                for i = #values.groups[g]+1, popup.graph_width do
                    table.insert(values.groups[g],0,1)
                end
            end
        end
    end

    -- get new stats and assign to textbox
    if stats_cmd then 
        local stats = awful.util.pread(popup.stats_cmd)
        if stats:sub(-1) == '\n' then
            stats = stats:sub(1,-2) -- trim trailing character
        end
        popup.stats:set_markup(stats)
    end

    -- figure out how big the widget is
    local w, h = wibox.layout.base.fit_widget(popup.mar,1000,1000)
    -- set the wibox size accordingly
    popup.box:geometry({width=w,height=h,x=mouse.coords().x,y=beautiful.awful_widget_height})


    -- fill graph
    if values.groups ~= nil and popup.stack then
        for i = 1, #values.groups[1] do
            for g = 1, popup.ng do
                assert(values.groups[g][i] ~= nil, "ups")
                popup.graphs[1]:add_value(values.groups[g][i], g)
            end
        end
    else
        for g = 1, popup.ng do
            for i = 1, #values.groups[g] do
                popup.graphs[g]:add_value(values.groups[g][i])
            end
        end
    end
    popup.box.visible = true
end

function sysmon.close_popup(popup)
    popup.box.visible = false
end


function sysmon.get_cpu_widget(beautiful, use_icon, use_graphs, graph_vertical)
    vicious.cache(vicious.widgets.cpu)
    -- create layout
    local cpu_widget = wibox.layout.fixed.horizontal()

    -- get number of CPUs
    local n_cpus = #vicious.widgets.cpu()-1

    if use_icon then
        cpu_widget:add(wibox.widget.imagebox(beautiful.widget_cpu))
    end

    -- create cpu text widget
    cpu_text = wibox.widget.textbox()
    cpu_widget:add(cpu_text)

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
        cpu_widget:add(cpu_bars)
    end


    cpu_widget.popup = sysmon.create_popup(cpu_widget, {
        stats_cmd = '/bin/ps --sort=-%cpu,-%mem -eo fname,%cpu,%mem | head -n 6',
        stack = true,
        title = 'CPU',
        number_graphs = n_cpus
    })


    -- register cpuwidgets
    cpu_widget.update = function ()
        -- use vicious to get current CPU info
        local args = vicious.widgets.cpu()
        -- display the total cpu consumption sum in text field
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

        -- update the popup
        table.remove(args, 1)
        cpu_widget.popup.update(args)
    end

    -- create timer
    local tm = timer({ timeout = 1 })
    if tm.connect_signal then
        tm:connect_signal("timeout", cpu_widget.update)
    else
        tm:add_signal("timeout", cpu_widget.update)
    end
    cpu_widget.timer = tm
    cpu_widget.timer:start()

    return cpu_widget
end


function sysmon.get_net_widgets(beautiful, use_icon, use_graphs, net_device)
    -- enable caching for netwidgets
    --vicious.cache(vicious.widgets.net)


    -- create the horizontal layout for the network widgets
    --local netwidgets = {}

    -- create layout
    local net_widget = wibox.layout.fixed.horizontal()

    if use_icon then
        net_widget:add(wibox.widget.imagebox(beautiful.widget_net))
    end

    -- create cpu text widget
    net_text = wibox.widget.textbox()
    net_widget:add(net_text)

    net_widget.popup = sysmon.create_popup(net_widget, {
        --stats_cmd = '/bin/ps --sort=-%cpu,-%mem -eo fname,%cpu,%mem | head -n 6',
        stack = false,
        scale = true,
        title = 'NET',
        number_graphs = 2
    })

--    local net_texts = {nil, nil}

    -- register cpuwidgets
    net_widget.update = function ()
        -- use vicious to get current CPU info
        local args = vicious.widgets.net()
        -- detect correct device:
        local netif_cmd = "netstat -nr | grep '^0.0.0.0' | awk '{ print $8 }' | head -n 1"
        local cur_netif = awful.util.pread(netif_cmd)
        if cur_netif:sub(-1) == '\n' then
            cur_netif = cur_netif:sub(1,-2) -- trim trailing character
        end
        -- display the total cpu consumption sum in text field
        local kb_down = 0
        local kb_up = 0
        if cur_netif == "" then
            net_text:set_text("No Connection")
        else
            kb_down = args["{" .. cur_netif .. " down_kb}"]
            kb_up = args["{" .. cur_netif .. " up_kb}"]
            net_text:set_text("▼" .. net_string(kb_down) .. " ▲" .. net_string(kb_up))
        end
        --net_texts[2]:set_text(net_string(kb_up))

        --if use_icon then
        --    cpu_text:set_text(string.format("%3u%% ", cpu_sum))
        --else
        --    cpu_text:set_text(string.format("cpus: %3u%% ", cpu_sum))
        --end


        -- update the popup
        --table.remove(args, 1)
        net_widget.popup.update({kb_down, kb_up})
    end

    -- create timer
    local tm = timer({ timeout = 3 })
    if tm.connect_signal then
        tm:connect_signal("timeout", net_widget.update)
    else
        tm:add_signal("timeout", net_widget.update)
    end
    net_widget.timer = tm
    net_widget.timer:start()

    --for i,up_down in pairs({"down", "up"}) do


    --    net_texts[i] = wibox.widget.textbox()
    --    local netwidget_layout = wibox.layout.fixed.horizontal()

    --    if use_icon then
    --        if up_down == "up" then
    --            net_icon = wibox.widget.imagebox(beautiful.widget_net_up)
    --        else
    --            net_icon = wibox.widget.imagebox(beautiful.widget_net_down)
    --        end
    --        netwidget_layout:add(net_icon)
    --    end
    --    netwidget_layout:add(net_texts[i])
    --    if use_graphs then
    --        netwidget = awful.widget.graph()
    --        -- Graph properties
    --        netwidget:set_width(50)
    --        -- netwidget_down:set_background_color("#494B4F")
    --        netwidget:set_background_color("#333333")
    --        netwidget:set_color("#CC33FF")
    --        netwidget:set_scale(true)
    --        --netwidget_down:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
    --        -- Register widget
    --        vicious.register(netwidget, vicious.widgets.net, "${" .. net_device .. " " .. up_down .. "_kb}", update_intervall)
    --        netwidget_layout:add(netwidget)
    --    end

    --    table.insert(netwidgets, netwidget_layout)
    --end

    --local pseudo_widget = wibox.widget.textbox()
    --vicious.register(pseudo_widget, vicious.widgets.net,
    --    function (widget, args)
    --        local kb_down = args["{" .. net_device .. " down_kb}"]
    --        local kb_up = args["{" .. net_device .. " up_kb}"]
    --        net_texts[1]:set_text(net_string(kb_down))
    --        net_texts[2]:set_text(net_string(kb_up))
    --        return ""
    --    end
    --    , update_intervall)

    --return netwidgets[1], netwidgets[2]
    return net_widget
end


function sysmon.get_widgets(beautiful, use_icon, use_graphs, update_intervall, net_device)

    -- get CPU widget
    local cpuwidget = sysmon.get_cpu_widget(beautiful, use_icon, true, true)

    -- get mem widget
    local memwidget = sysmon.get_mem_widget(beautiful, use_icon, true)

    -- get network widget
    local netwidget = sysmon.get_net_widgets(beautiful, use_icon, true, net_device)

    -- get battery widget but only if there is a battery
    if (vicious.widgets.bat("", "BAT0")[2] > 0) then
        batwidget = sysmon.get_bat_widget(beautiful, use_icon, true)
    end

    return {netwidget, memwidget, cpuwidget, batwidget}
end

return sysmon
