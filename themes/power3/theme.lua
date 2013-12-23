--[[                                    ]]--
--                                        -
--    Blackburn Awesome WM 3.5.+ theme    --
--       github.com/copycat-killer        --
--                                        -
--[[                                    ]]--


theme = {}

theme.dir                                   = os.getenv("HOME") .. "/.config/awesome/themes/power3"
theme.wallpaper                             = theme.dir .. "/wall.jpg"

theme.font                                  = "Terminus 8"
theme.taglist_font                          = "Terminus 9"
theme.fg_normal                             = "#D7D7D7"
theme.fg_focus                              = "#62B1D0"
theme.bg_normal                             = "#060606"
theme.bg_focus                              = "#060606"
theme.fg_urgent                             = "#CC9393"
theme.bg_urgent                             = "#2A1F1E"
theme.border_width                          = "1"
theme.border_normal                         = "#0E0E0E"
theme.border_focus                          = "#404040"
theme.graph_bg                              = "#444444"
theme.graph_fg                              = "#CCCCCC"
theme.widgets_bg_2                          = "#313131"

theme.taglist_fg_focus                      = "#62B1D0"
theme.taglist_bg_focus                      = "#060606"
theme.tasklist_fg_focus                     = "#62B1D0"
theme.tasklist_bg_focus                     = "#060606"
theme.textbox_widget_margin_top             = 0
theme.awful_widget_height                   = 18
theme.awful_widget_margin_top               = 0
theme.menu_height                           = "18"
theme.menu_width                            = "160"

theme.menu_submenu_icon                     = theme.dir .. "/icons/submenu.png"

-- additions:
theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"

theme.taglist_squares_sel                   = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                 = theme.dir .. "/icons/square_unsel.png"
theme.arrl_lr_pre                           = theme.dir .. "/icons/arrl_lr_pre.png"
theme.arrl_lr_post                          = theme.dir .. "/icons/arrl_lr_post.png"

theme.layout_tile                           = theme.dir .. "/icons/tile.png"
theme.layout_tilegaps                       = theme.dir .. "/icons/tilegaps.png"
theme.layout_tileleft                       = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom                     = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                        = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                          = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                          = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                         = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                        = theme.dir .. "/icons/dwindle.png"
theme.layout_max                            = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                     = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                      = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                       = theme.dir .. "/icons/floating.png"

theme.arrl                                  = theme.dir .. "/icons/arrl.png"
theme.arrl_dl                               = theme.dir .. "/icons/arrl_dl.png"
theme.arrl_ld                               = theme.dir .. "/icons/arrl_ld.png"

theme.widget_ac                             = theme.dir .. "/icons/ac.png"
theme.widget_battery                        = theme.dir .. "/icons/battery.png"
theme.widget_battery_low                    = theme.dir .. "/icons/battery_low.png"
theme.widget_battery_empty                  = theme.dir .. "/icons/battery_empty.png"
theme.widget_mem                            = theme.dir .. "/icons/mem.png"
theme.widget_cpu                            = theme.dir .. "/icons/cpu.png"
theme.widget_temp                           = theme.dir .. "/icons/temp.png"
theme.widget_net                            = theme.dir .. "/icons/net.png"
theme.widget_net_down                       = theme.dir .. "/icons/net_down.png"
theme.widget_net_up                         = theme.dir .. "/icons/net_up.png"
theme.widget_hdd                            = theme.dir .. "/icons/hdd.png"
theme.widget_music                          = theme.dir .. "/icons/note.png"
theme.widget_music_on                       = theme.dir .. "/icons/note_on.png"
theme.widget_vol                            = theme.dir .. "/icons/vol.png"
theme.widget_vol_low                        = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no                         = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute                       = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail                           = theme.dir .. "/icons/mail.png"
theme.widget_mail_notify                    = theme.dir .. "/icons/mail_notify.png"

theme.tasklist_floating                     = ""
theme.tasklist_maximized_horizontal         = ""
theme.tasklist_maximized_vertical           = ""

theme.widget_mail_notify                    = theme.dir .. "/icons/mail_notify.png"
theme.widget_no_net_notify                  = theme.dir .. "/icons/no_net_notify.png"

return theme
