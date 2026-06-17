local terminal    = "alacritty"
local fileManager = "pcmanfm"
local menu        = "rofi -show drun"
local mainMod     = "SUPER"

-- Applications
hl.bind(mainMod .. " + V",             hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + Return",        hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + ALT + C",       hl.dsp.exec_cmd([[alacritty -e bash -c "cd /Asura/Music && cmus"]]))
hl.bind(mainMod .. " + B",             hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + E",             hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Space",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + ALT + R",       hl.dsp.exec_cmd("~/.config/hypr/scripts/randowall.sh"))

-- Launchers
hl.bind(mainMod .. " + W",                hl.dsp.exec_cmd("rofi -show window"))

-- Screenshots
hl.bind("Print",                      hl.dsp.exec_cmd("grim - | tee ~/stuff/screenshots/$(date +%s).png | wl-copy"))
hl.bind(mainMod .. " + SHIFT + S",    hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | tee ~/stuff/screenshots/$(date +%s).png | wl-copy"))

-- Lockscreen
hl.bind(mainMod .. " + SHIFT + X",     hl.dsp.exec_cmd("hyprlock"))

-- Window actions
hl.bind(mainMod .. " + Q",            hl.dsp.window.close())
hl.bind(mainMod .. " + F",            hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + S",            hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P",            hl.dsp.window.pseudo())
hl.bind(mainMod .. " + M",            hl.dsp.layout("togglesplit"))

-- Reload
hl.bind(mainMod .. " + R",            hl.dsp.exec_cmd("hyprctl reload && sleep 1 && ~/.config/hypr/scripts/auto-monitor.sh"))

-- Focus last workspace
hl.bind(mainMod .. " + Tab",          hl.dsp.focus({ workspace = "previous" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + SHIFT + I",    hl.dsp.window.move({ workspace = "special:hidden" }))
hl.bind(mainMod .. " + I",            hl.dsp.workspace.toggle_special("hidden"))

-- Focus (vim-style)
hl.bind(mainMod .. " + H",            hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J",            hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K",            hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L",            hl.dsp.focus({ direction = "right" }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + H",    hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J",    hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L",    hl.dsp.window.move({ direction = "right" }))

-- Resize (super+alt+h/j/k/l)
hl.bind(mainMod .. " + ALT + H",      hl.dsp.exec_cmd("hyprctl dispatch resizeactive -20 0"),  { repeating = true })
hl.bind(mainMod .. " + ALT + J",      hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 20"),   { repeating = true })
hl.bind(mainMod .. " + ALT + K",      hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -20"),  { repeating = true })
hl.bind(mainMod .. " + ALT + L",      hl.dsp.exec_cmd("hyprctl dispatch resizeactive 20 0"),   { repeating = true })

-- Move floating window (super+shift+arrows)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.exec_cmd("hyprctl dispatch moveactive -20 0"),  { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.exec_cmd("hyprctl dispatch moveactive 0 20"),   { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.exec_cmd("hyprctl dispatch moveactive 0 -20"),  { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.exec_cmd("hyprctl dispatch moveactive 20 0"),   { repeating = true })

-- Switch workspaces
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key,            hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key,    hl.dsp.window.move({ workspace = i }))
end

-- Cycle workspaces
hl.bind(mainMod .. " + bracketleft",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + bracketright", hl.dsp.focus({ workspace = "e+1" }))

-- Special workspace (scratchpad - magic)
hl.bind(mainMod .. " + grave",            hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + grave",    hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { mouse = true })
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { mouse = true })

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
