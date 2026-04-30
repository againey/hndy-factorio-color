# hndy-factorio-color

## Overview

A utility library for *Factorio* mods providing classes and functions for working with various color spaces and color values.

## Color Spaces

- [RGB](https://en.wikipedia.org/wiki/RGB_color_model) (red, green, blue)
- [sRGB](https://en.wikipedia.org/wiki/SRGB) (gamma-corrected RGB)
- [HSV](https://en.wikipedia.org/wiki/HSL_and_HSV) (hue, saturation, value)
- [HSL](https://en.wikipedia.org/wiki/HSL_and_HSV) (hue, saturation, lightness)
- [HWB](https://en.wikipedia.org/wiki/HWB_color_model) (hue, whiteness, blackness)
- [CIELAB](https://en.wikipedia.org/wiki/CIELAB_color_space) (lightness, green-to-red, blue-to-yellow)
- [CIELCh](https://en.wikipedia.org/wiki/CIELAB_color_space#Cylindrical_model) (lightness, chroma, hue)
- [Oklab](https://en.wikipedia.org/wiki/Oklab_color_space) (lightness, green-to-red, blue-to-yellow)
- [Oklch](https://en.wikipedia.org/wiki/Oklab_color_space#Coordinates) (lightness, chroma, hue)

Game colors are in the sRGB color space, so favor the `ColorSrgb` class for directly working in the native color space.

For constructing hue-based colors based on intuitive input components, consider using `ColorHsl`, `ColorHsv`, or `ColorHwb`.
However, if you are doing more advanced calculations, especially if you are interpolating between colors and want the
intermediate colors to maintain consistent brightness and vibrancy relative to their source and target, `ColorOklch` is the
recommended choice.

## Operations

- Conversion between color spaces
- Conversion to and from game color
- Conversion to and from CSS-compatible components
- Gamut clamping and component normalization
- Clone with mutation
- Interpolation between two colors

## Usage

Here is an example of smoothly changing the player's color randomly over time.

```lua
--control.lua

local ColorOklch = require("__hndy-color__.oklch")

local player = nil
local lerp_start
local lerp_end
local lerp_source
local lerp_target

script.on_event(defines.events.on_tick, function(event)
	if player == nil or player.valid == false then
		player = game.get_player(1)
		if player.valid == true then
			--Initialize process for a newly chosen player.
			lerp_start = event.tick
			lerp_end = lerp_start + math.random(30, 120)

			--Convert the player's color into the Oklch color space, making sure that it is fully opaque.
			lerp_source = ColorOklch.from_game_color(player.color):with_alpha(1.0)
			--Select a random target in the Oklch color space; lightness and hue can be anything,
			--but chroma is restricted to the range [0.5, 1.0) to ensure more vibrant colors are chosen.
			lerp_target = ColorOklch.new(math.random(), math.random() * 0.5 + 0.5, math.random())
		else
			player = nil
		end
	end

	if player ~= nil and event.tick > lerp_start then
		if event.tick < lerp_end then
			--Determine the correct lerp proportion between the initial tick and final tick.
			local t = (event.tick - lerp_start) / (lerp_end - lerp_start)
			--Perform the interpolation, prefering to shift the hue in whichever direction is a shorter
			--path between source and target, making sure that the result can be displayed reliably.
			local lerp_color = lerp_source:interpolate_shorter_hue(lerp_target, t):clamp_to_safe_gamut()
			--Convert the interpolated color back to the game's format and assign to the player.
			player.color = lerp_color:to_game_color()
		else
			--The previous interpolation cycle completed, so select a new target and duration.
			lerp_start = event.tick
			lerp_end = lerp_start + math.random(30, 120)
			lerp_source = lerp_target:clamp_to_safe_gamut()
			lerp_target = ColorOklch.new(math.random(), math.random(), math.random())
			player.color = lerp_source:to_game_color()
		end
	end
end)
```
