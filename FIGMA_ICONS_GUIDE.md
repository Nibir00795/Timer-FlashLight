# Figma Icons – Export Guide for Timer FlashLight

Reference: [Figma Design](https://www.figma.com/design/yozbLIHjKMGYfTP5cc1PA3/Untitled?node-id=48-147&m=dev)

## Icons to Export and Replace

Export these from your Figma file and replace the corresponding assets. Use **SVG** or **PDF** for vector icons. For iOS, export at **@1x, @2x, @3x** as PNG if you prefer raster, or use a single SVG (Xcode supports vector assets).

### Bottom controls (node-id=48-147)

| Asset folder | Figma element | Current file | Notes |
|--------------|---------------|--------------|-------|
| `ic_timer.imageset` | Clock icon (Timer Set button) | `Group 882.svg` | 56×56 design. Used in clock button. Needs green stroke (#44D62C) for enabled, grey for disabled (or use template tint). |
| `ic_timer_circle.imageset` | Circle outline in timer pill | `ic_saved_time_circle.svg` | 24×26 design. Simple circle outline for “05:00 Min” pill. |
| `ic_phone.imageset` | Mobile/device icon | `Group 427322761.svg` | 56×56 design. Phone outline. Green stroke when enabled. |

### Brightness slider

| Asset folder | Figma element | Current file | Notes |
|--------------|---------------|--------------|-------|
| `ic_brightness_min.imageset` | Low/min brightness icon | `Group 427322744.svg` | Smaller icon, left of slider. |
| `ic_brightness.imageset` | High/max brightness icon | `ic_brightness.svg` | Larger icon, right of slider. |

### Other icons (verify against Figma)

| Asset folder | Current file | Usage |
|--------------|--------------|-------|
| `ic_power.imageset` | `ic_power.svg` | Flashlight off state |
| `ic_power_on_state.imageset` | `ic_power_on_state.svg` | Flashlight on state |
| `ic_sos.imageset` | `Group 89.svg` | SOS off state |
| `ic_sos_on.imageset` | `Group 427322752.svg` | SOS on state |
| `ic_battery.imageset` | `Vector.png` | Battery indicator |
| `ic_crown.imageset` | `ic_premium.svg` | Upgrade button |
| `ic_menu.imageset` | `Group 8780.svg` | Menu button |

## Export settings

1. In Figma, select the icon/frame.
2. Use **Export** in the right panel.
3. Choose **SVG** (recommended for vectors).
4. Name files to match the asset folder (e.g. `ic_timer.svg`, `ic_timer_circle.svg`).
5. Place in the correct `Timer FlashLight/Assets.xcassets/<imageset>/` folder.
6. Update `Contents.json` if needed (Xcode usually updates it when you drag in new files).

## Color handling

- **Template mode**: Icons using `renderingMode(.template)` are tinted by `foregroundColor`. Export icons as single-color or ensure they work well as templates.
- **Original mode**: Icons with `renderingMode(.original)` keep Figma colors. Export with correct green (#44D62C) and grey (#666666) as needed.
