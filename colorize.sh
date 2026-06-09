#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  Zrec Skin Colorizer — Termux / Linux
# 🎨 Generate colored touchscreen skins for SM64 emulators
# ═══════════════════════════════════════════════════════════════════
set -e

# ─── ANSI Colors ────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'

info()  { echo -e "${CYAN}${BOLD}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}${BOLD}[ OK ]${NC} $1"; }
warn()  { echo -e "${YELLOW}${BOLD}[WARN]${NC} $1"; }
err()   { echo -e "${RED}${BOLD}[ERR ]${NC} $1"; }

# ─── Banner ────────────────────────────────────────────────────────
echo -e "${BLUE}${BOLD}"
echo '╔══════════════════════════════════════════╗'
echo '║     SM64 Touchscreen Colorizer           ║'
echo '║  Generate colored skins for your emulator║'
echo '╚══════════════════════════════════════════╝'
echo -e "${NC}"

# ─── 1. Dependencies ──────────────────────────────────────────────
info "Checking dependencies..."

# Detect OS
OS="linux"
if command -v termux-setup-storage &>/dev/null; then
    OS="termux"
fi

install_pkg() {
    if [ "$OS" = "termux" ]; then
        pkg install -y "$1" 2>/dev/null | tail -1
    else
        if command -v apt &>/dev/null; then
            sudo apt install -y "$1" 2>/dev/null | tail -1
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y "$1" 2>/dev/null | tail -1
        fi
    fi
}

# Python
if ! command -v python3 &>/dev/null; then
    warn "Python3 not found. Installing..."
    install_pkg python3
fi

# Pillow
if ! python3 -c "from PIL import Image; print('ok', end='')" 2>/dev/null; then
    warn "Pillow not found. Installing..."
    if [ "$OS" = "termux" ]; then
        pkg install -y python-pillow 2>/dev/null | tail -1
    else
        pip3 install Pillow --break-system-packages 2>/dev/null | tail -1
    fi
fi

ok "Dependencies OK"

# ─── 2. Base directory ─────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we have touchscreen locally
if [ -d "${SCRIPT_DIR}/touchscreen/Outline" ]; then
    SKIN_DIR="${SCRIPT_DIR}/touchscreen"
elif [ -d "${SCRIPT_DIR}/../touchscreen/Outline" ]; then
    SCRIPT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
    SKIN_DIR="${SCRIPT_DIR}/touchscreen"
else
    warn "touchscreen/ skins not found."
    echo -ne "  Clone from GitHub? [Y/n]: "
    read -r CLONE
    if [[ ! "$CLONE" =~ ^[Nn] ]]; then
        REPO="Zash60/sm64-touchscreen"
        info "Cloning https://github.com/${REPO}.git"
        git clone "https://github.com/${REPO}.git" "${SCRIPT_DIR}/sm64-touchscreen" 2>&1 | tail -3
        SCRIPT_DIR="${SCRIPT_DIR}/sm64-touchscreen"
        SKIN_DIR="${SCRIPT_DIR}/touchscreen"
    else
        err "Need the touchscreen/ folder with skins."
        echo "Place skins in: ${SCRIPT_DIR}/touchscreen/"
        exit 1
    fi
fi

# ─── 3. Pick base skin ─────────────────────────────────────────────
echo -e "\n${BOLD}AVAILABLE SKINS:${NC}"
SKIN_NAMES=()
i=1
for d in "${SKIN_DIR}"/*/; do
    name=$(basename "$d")
    if [ -f "$d/skin.ini" ]; then
        display=$(grep "^name=" "$d/skin.ini" 2>/dev/null | cut -d= -f2)
        [ -z "$display" ] && display="$name"
        echo -e "  ${i}) ${display}"
        SKIN_NAMES+=("$name")
        i=$((i+1))
    fi
done
echo -ne "\nPick skin (1-$((i-1))): "
read -r SKIN_CHOICE

if [ -z "${SKIN_NAMES[$((SKIN_CHOICE-1))]}" ]; then
    err "Invalid choice"
    exit 1
fi

SELECTED_SKIN="${SKIN_NAMES[$((SKIN_CHOICE-1))]}"
BASE_SKIN="${SKIN_DIR}/${SELECTED_SKIN}"

if [ ! -f "$BASE_SKIN/skin.ini" ]; then
    err "skin.ini not found in $BASE_SKIN"
    exit 1
fi

ok "Base skin: $SELECTED_SKIN"

# ─── Output to Downloads ─────────────────────────────────────────
if command -v termux-setup-storage &>/dev/null; then
    OUTPUT_BASE="${HOME}/storage/downloads/skins"
else
    OUTPUT_BASE="${SCRIPT_DIR}"
fi
mkdir -p "$OUTPUT_BASE"

# ─── 4. Pick color ──────────────────────────────────────────────
echo -e "\n${BOLD}AVAILABLE COLORS:${NC}"
echo -e "  ${RED}1) Red${NC}        ${GREEN}2) Green${NC}      ${BLUE}3) Blue${NC}"
echo -e "  ${MAGENTA}4) Purple${NC}     ${YELLOW}5) Orange${NC}     ${CYAN}6) Cyan${NC}"
echo -e "  ${MAGENTA}7) Pink${NC}       ${YELLOW}8) Yellow${NC}    ${CYAN}9) Teal${NC}"
echo -e "  ${BOLD}10) Custom${NC} (enter a hex like #FF6600)"
echo -ne "\nPick (1-10): "
read -r COLOR_CHOICE

# RGB ratios R:G:B and mask color generators
case "$COLOR_CHOICE" in
    1) # Vermelho
        RR=1.0; GR=0.25; BR=0.20
        MASK_A="C01515"; MASK_B="A10D0D"; MASK_L="FF8282"; MASK_R="FF4444"
        MASK_Z="FF2929"; MASK_S="B30000"; MASK_CU="D94A4A"; MASK_CR="F07E7E"
        MASK_CD="A42E2E"; MASK_CL="8A1B1B"; MASK_SEN="B86464"
        COLOR_NAME="Red"
        ;;
    2) # Green
        RR=0.20; GR=1.0; BR=0.25
        MASK_A="15C015"; MASK_B="0DA10D"; MASK_L="82FF82"; MASK_R="44FF44"
        MASK_Z="29FF29"; MASK_S="00B300"; MASK_CU="4AD94A"; MASK_CR="7EF07E"
        MASK_CD="2EA42E"; MASK_CL="1B8A1B"; MASK_SEN="64B864"
        COLOR_NAME="Green"
        ;;
    3) # Blue
        RR=0.25; GR=0.50; BR=1.0
        MASK_A="1565C0"; MASK_B="0D47A1"; MASK_L="82B1FF"; MASK_R="448AFF"
        MASK_Z="2979FF"; MASK_S="0057B3"; MASK_CU="4A90D9"; MASK_CR="7EB8F0"
        MASK_CD="2E6DA4"; MASK_CL="1B4F8A"; MASK_SEN="6488B8"
        COLOR_NAME="Blue"
        ;;
    4) # Purple
        RR=0.70; GR=0.20; BR=1.0
        MASK_A="7A15C0"; MASK_B="5E0DA1"; MASK_L="B982FF"; MASK_R="8C44FF"
        MASK_Z="7329FF"; MASK_S="4F00B3"; MASK_CU="9B4AD9"; MASK_CR="B97EF0"
        MASK_CD="6E2EA4"; MASK_CL="541B8A"; MASK_SEN="8A64B8"
        COLOR_NAME="Purple"
        ;;
    5) # Orange
        RR=1.0; GR=0.55; BR=0.10
        MASK_A="C07E15"; MASK_B="A1620D"; MASK_L="FFB982"; MASK_R="FF8C44"
        MASK_Z="FF7329"; MASK_S="B35E00"; MASK_CU="D98F4A"; MASK_CR="F0B87E"
        MASK_CD="A4682E"; MASK_CL="8A4F1B"; MASK_SEN="B88A64"
        COLOR_NAME="Orange"
        ;;
    6) # Cyan
        RR=0.10; GR=0.70; BR=1.0
        MASK_A="159EC0"; MASK_B="0D7AA1"; MASK_L="82D4FF"; MASK_R="44BCFF"
        MASK_Z="29A8FF"; MASK_S="008BB3"; MASK_CU="4AB5D9"; MASK_CR="7ED6F0"
        MASK_CD="2E7EA4"; MASK_CL="1B618A"; MASK_SEN="649DB8"
        COLOR_NAME="Cyan"
        ;;
    7) # Pink
        RR=1.0; GR=0.35; BR=0.60
        MASK_A="C01550"; MASK_B="A10D3C"; MASK_L="FF82B0"; MASK_R="FF4488"
        MASK_Z="FF296E"; MASK_S="B3003B"; MASK_CU="D94A7A"; MASK_CR="F07EA8"
        MASK_CD="A42E5A"; MASK_CL="8A1B46"; MASK_SEN="B86484"
        COLOR_NAME="Pink"
        ;;
    8) # Yellow
        RR=1.0; GR=0.85; BR=0.10
        MASK_A="C0A615"; MASK_B="A1890D"; MASK_L="FFE082"; MASK_R="FFD444"
        MASK_Z="FFC429"; MASK_S="B39A00"; MASK_CU="D9C44A"; MASK_CR="F0DD7E"
        MASK_CD="A4932E"; MASK_CL="8A751B"; MASK_SEN="B8A864"
        COLOR_NAME="Yellow"
        ;;
    9) # Teal
        RR=0.10; GR=0.80; BR=0.70
        MASK_A="15C09E"; MASK_B="0DA17A"; MASK_L="82FFD4"; MASK_R="44FFBC"
        MASK_Z="29FFA8"; MASK_S="00B38B"; MASK_CU="4AD9B5"; MASK_CR="7EF0D6"
        MASK_CD="2EA47E"; MASK_CL="1B8A61"; MASK_SEN="64B89D"
        COLOR_NAME="Teal"
        ;;
    10)
        echo -ne "\nEnter HEX color (e.g. #FF6600): "
        read -r CUSTOM_HEX
        CUSTOM_HEX="${CUSTOM_HEX#'#'}"
        if ! [[ "$CUSTOM_HEX" =~ ^[0-9A-Fa-f]{6}$ ]]; then
            err "Invalid format. Use #RRGGBB"
            exit 1
        fi
        R=$(printf "%d" "0x${CUSTOM_HEX:0:2}")
        G=$(printf "%d" "0x${CUSTOM_HEX:2:2}")
        B=$(printf "%d" "0x${CUSTOM_HEX:4:2}")
        RR=$(python3 -c "print($R/255)")
        GR=$(python3 -c "print($G/255)")
        BR=$(python3 -c "print($B/255)")
        # Generate mask tones based on the custom color
        MASK_A="${CUSTOM_HEX}"; MASK_B="${CUSTOM_HEX}"
        MASK_L="${CUSTOM_HEX}"; MASK_R="${CUSTOM_HEX}"; MASK_Z="${CUSTOM_HEX}"
        MASK_S="${CUSTOM_HEX}"; MASK_CU="${CUSTOM_HEX}"; MASK_CR="${CUSTOM_HEX}"
        MASK_CD="${CUSTOM_HEX}"; MASK_CL="${CUSTOM_HEX}"; MASK_SEN="${CUSTOM_HEX}"
        COLOR_NAME="Custom-${CUSTOM_HEX}"
        ;;
    *)
        err "Invalid choice"
        exit 1
        ;;
esac

COLOR_NAME_LOWER=$(echo "$COLOR_NAME" | tr '[:upper:]' '[:lower:]')
OUTPUT_DIR="${OUTPUT_BASE}/${SELECTED_SKIN}-${COLOR_NAME}"

if [ -d "$OUTPUT_DIR" ]; then
    warn "Already exists: $OUTPUT_DIR"
    echo -ne "Overwrite? [y/N]: "
    read -r OVER
    if [[ ! "$OVER" =~ ^[Yy] ]]; then
        err "Cancelled"
        exit 1
    fi
    rm -rf "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"
info "Generating ${COLOR_NAME} theme in ${OUTPUT_DIR}..."

# ─── 5. Process images with Python ─────────────────────────────────
python3 << PYEOF
import os, sys, shutil, re
from PIL import Image

base_skin = "${BASE_SKIN}"
out_dir = "${OUTPUT_DIR}"
rr, gr, br = ${RR}, ${GR}, ${BR}
color_name = "${COLOR_NAME}"
rr_nice = ${RR}
gr_nice = ${GR}
br_nice = ${BR}

# ─── Old mask colors → New mask colors ────────────────────────────
MASK_MAP = {
    # Original hex → New hex
    (0x00,0xE0,0xCA): tuple(bytes.fromhex("${MASK_CU}")),   # Cu
    (0xFF,0x63,0x5C): tuple(bytes.fromhex("${MASK_CR}")),   # Cr
    (0x84,0xA1,0xD5): tuple(bytes.fromhex("${MASK_CD}")),   # Cd
    (0x5A,0x6B,0x1F): tuple(bytes.fromhex("${MASK_CL}")),   # Cl
    (0x00,0x7F,0x46): tuple(bytes.fromhex("${MASK_A}")),    # A
    (0x4B,0x4B,0x4B): tuple(bytes.fromhex("${MASK_B}")),    # B
    (0xFF,0xB4,0x00): tuple(bytes.fromhex("${MASK_L}")),    # L
    (0x6B,0x1F,0x49): tuple(bytes.fromhex("${MASK_R}")),    # R
    (0x42,0xA6,0xEC): tuple(bytes.fromhex("${MASK_Z}")),    # Z
    (0xB4,0x5D,0x5D): tuple(bytes.fromhex("${MASK_S}")),    # S
    (0x88,0x88,0x88): tuple(bytes.fromhex("${MASK_SEN}")),  # Sen
}

# ─── Recolor function ───────────────────────────────────────────
s = rr_nice + gr_nice + br_nice
denom = (0.299*rr_nice + 0.587*gr_nice + 0.114*br_nice) / s if s else 1
scale = 1.0 / denom if denom else 1.0

def recolor_image(img):
    if img.mode != 'RGBA': img = img.convert('RGBA')
    px = img.load()
    out = Image.new('RGBA', img.size)
    opx = out.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if a == 0:
                opx[x, y] = (0, 0, 0, 0)
            else:
                n = (0.299*r + 0.587*g + 0.114*b) / 255.0
                opx[x, y] = (
                    min(255, round(n * scale * rr_nice * 255 / s)),
                    min(255, round(n * scale * gr_nice * 255 / s)),
                    min(255, round(n * scale * br_nice * 255 / s)),
                    a,
                )
    return out

def recolor_mask(img):
    if img.mode != 'RGBA': img = img.convert('RGBA')
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if a == 0: continue
            key = (r, g, b)
            if key in MASK_MAP:
                nr, ng, nb = MASK_MAP[key]
                px[x, y] = (nr, ng, nb, a)
    return img

# ─── Process all PNGs ──────────────────────────────────────────
files = sorted(os.listdir(base_skin))
count = 0
errors = 0
for fname in files:
    if not fname.endswith('.png'):
        if fname == 'skin.ini': continue
        continue

    src = os.path.join(base_skin, fname)
    dst = os.path.join(out_dir, fname)

    try:
        img = Image.open(src)
        is_mask = '-mask.' in fname
        if is_mask:
            img = recolor_mask(img)
        else:
            img = recolor_image(img)
        img.save(dst, format='PNG')
        count += 1
        sys.stdout.write(f'\r  Processed: {count}')
        sys.stdout.flush()
    except Exception as e:
        errors += 1

# ─── Copy and update skin.ini ──────────────────────────────────
ini_src = os.path.join(base_skin, 'skin.ini')
ini_dst = os.path.join(out_dir, 'skin.ini')
if os.path.exists(ini_src):
    with open(ini_src, 'r') as f:
        ini = f.read()

    base_name_match = re.search(r'^name=(.+)', ini, re.MULTILINE)
    base_name = base_name_match.group(1) if base_name_match else 'Skin'
    ini = re.sub(r'^name=.+', f'name={base_name}-{color_name}', ini, flags=re.MULTILINE)

    # Update mask colors
    mask_updates = {
        'Cu': '${MASK_CU}', 'Cr': '${MASK_CR}', 'Cd': '${MASK_CD}', 'Cl': '${MASK_CL}',
        'A': '${MASK_A}', 'B': '${MASK_B}', 'L': '${MASK_L}', 'R': '${MASK_R}',
        'Z': '${MASK_Z}', 'S': '${MASK_S}', 'Sen': '${MASK_SEN}',
    }
    for key, val in mask_updates.items():
        # Find and replace line starting with "key="
        ini = re.sub(rf'^{key}=[0-9A-Fa-f]+', f'{key}={val}', ini, flags=re.MULTILINE)

    with open(ini_dst, 'w') as f:
        f.write(ini)

print(f'\n\n{count} images processed, {errors} errors')
PYEOF

# ─── 6. Done ───────────────────────────────────────────────────────
echo -e "\n${GREEN}${BOLD}══════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ✅ ${COLOR_NAME} theme generated!${NC}"
echo -e "${GREEN}${BOLD}  📁 ${OUTPUT_DIR}${NC}"
echo -e "${GREEN}${BOLD}══════════════════════════════════════════${NC}"
echo
echo "Point your emulator (SM64) to:"
echo -e "  ${CYAN}${OUTPUT_DIR}${NC}"
echo
