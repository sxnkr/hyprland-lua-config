hl.config({
  input = {
    kb_layout  = "us",
    follow_mouse = 1,
    sensitivity   = 0.3,
    accel_profile = "flat",
    touchpad = {
      natural_scroll        = true,
      tap_to_click          = true,
      drag_lock             = true,
      disable_while_typing  = true,
      clickfinger_behavior  = true,
      middle_button_emulation = true,
    },
  },
})

hl.gesture({
  fingers   = 3,
  direction = "horizontal",
  action    = "workspace",
})

hl.device({
  name        = "epic-mouse-v1",
  sensitivity = -0.5,
})
