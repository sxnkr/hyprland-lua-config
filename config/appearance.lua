hl.config({
  general = {
    gaps_in  = 5,
    gaps_out = 20,
    border_size = 2,
    col = {
      active_border   = { colors = {"rgba(3a4550ff)", "rgba(505c68ff)"}, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding       = 0,
    rounding_power = 0,
    active_opacity   = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled      = true,
      range        = 4,
      render_power = 3,
      color        = 0xee1a1a1a,
    },
    blur = {
      enabled  = true,
      size     = 3,
      passes   = 1,
      vibrancy = 0.1696,
    },
  },
})

hl.config({
  dwindle = {
    preserve_split = true,
  },
  master = {
    new_status = "master",
  },
})

hl.config({
  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo   = true,
  },
})
