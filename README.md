# 🎮 SM64 Touchscreen Skins

Touchscreen overlay skins for **Super Mario 64** emulators on Android.

## 📂 Base Skins

| Folder | Description |
|--------|-------------|
| Outline | Outlined buttons (best for colorization) |
| Flat | Flat/minimal design |
| 3DSXL | 3DS XL style |
| Black | Wii U V2 Black |
| Colored | Wii U V2 Colored |
| GameCube | GameCube style |
| Hires | High resolution V3 |
| JoshaGibs | JoshaGibs theme |
| Newd | Newd V2 |
| Shaded | Shaded buttons |
| Switch | Switch V3 style |
| White | Wii U V2 White |
| WiiU | Wii U V2 Default |

## 🎨 Colorizer Script

Generate any skin in any color:

```bash
# On Termux:
pkg install git python-pillow
git clone https://github.com/Zash60/sm64-touchscreen.git
cd sm64-touchscreen
bash colorize.sh
```

The script will:
1. Check/install Python + Pillow
2. Let you pick a base skin from the list
3. Let you pick a color (9 presets or custom hex)
4. Output the colored skin to `~/storage/downloads/skins/`

## 📜 Credits

- Outline, Shaded: contributors unknown
- 3DSXL, Flat, Newd, Switch, WiiU: Juan Jesus Tovar
- Black, Colored, White: Henry Mora
- GameCube: KRAID FFF
- JoshaGibs: JoshaGibs
- Hires: Based on Nerrel's Majora's Mask texture pack
