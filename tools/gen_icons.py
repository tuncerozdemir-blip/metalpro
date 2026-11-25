"""MetalPro PWA ve iOS ikonlarını üretir (harici görsel aracı gerekmez)."""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
WEB_ICONS = ROOT / "web" / "icons"
IOS_ICONS = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"

BG = (9, 20, 32)
GRID = (20, 44, 65)
FRAME = (42, 100, 150)
CYAN = (125, 211, 252)
STEEL = (38, 104, 152)
MUTED = (120, 145, 166)


def load_font(size: int, bold: bool = True) -> ImageFont.FreeTypeFont:
    name = "consolab.ttf" if bold else "segoeui.ttf"
    candidate = Path("C:/Windows/Fonts") / name
    if candidate.exists():
        return ImageFont.truetype(str(candidate), size)
    return ImageFont.load_default(size=size)


def background(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), BG)
    d = ImageDraw.Draw(img)
    step = max(6, round(size / 16))
    for i in range(step, size, step):
        d.line([(i, 0), (i, size)], fill=GRID, width=1)
        d.line([(0, i), (size, i)], fill=GRID, width=1)
    m = max(1, round(size * 0.012))
    d.rectangle([m, m, size - m - 1, size - m - 1], outline=FRAME, width=m)
    return img


def glyph(size: int, label: bool = True) -> Image.Image:
    s = max(64, min(size, 1024))
    r = s / 512
    layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)

    def scaled(points):
        return [(round(x * r), round(y * r)) for x, y in points]

    profile = scaled([
        (150, 120), (362, 120), (362, 152), (276, 152),
        (276, 300), (362, 300), (362, 332), (150, 332),
        (150, 300), (236, 300), (236, 152), (150, 152),
    ])
    d.polygon(profile, fill=STEEL + (255,))
    d.line(profile + [profile[0]], fill=CYAN + (255,),
           width=max(1, round(3 * r)), joint="curve")

    axis_x = round(256 * r)
    for y in range(round(98 * r), round(352 * r), max(3, round(18 * r))):
        d.line([(axis_x, y), (axis_x, y + max(2, round(9 * r)))],
               fill=MUTED + (220,), width=max(1, round(2 * r)))

    for a, b in [((150, 104), (362, 104)), ((150, 98), (150, 110)), ((362, 98), (362, 110))]:
        x1, y1 = scaled([a])[0]
        x2, y2 = scaled([b])[0]
        d.line([(x1, y1), (x2, y2)], fill=CYAN + (190,), width=max(1, round(2 * r)))

    if label:
        d.text((axis_x, round(378 * r)), "METALPRO",
               font=load_font(max(9, round(46 * r)), True),
               fill=CYAN + (255,), anchor="mm")
        d.text((axis_x, round(432 * r)), "AĞIRLIK HESAPLAYICI",
               font=load_font(max(7, round(19 * r)), False),
               fill=MUTED + (255,), anchor="mm")

    return layer if s == size else layer.resize((size, size), Image.Resampling.LANCZOS)


def compose(size: int, maskable: bool = False, label: bool = True) -> Image.Image:
    img = background(size)
    inner = int(size * (0.72 if maskable else 1))
    layer = glyph(inner, label)
    offset = (size - inner) // 2
    img.paste(layer, (offset, offset), layer)
    return img


def save() -> None:
    WEB_ICONS.mkdir(parents=True, exist_ok=True)
    web_targets = {
        "Icon-192.png": (192, False),
        "Icon-512.png": (512, False),
        "Icon-180.png": (180, False),
        "Icon-maskable-192.png": (192, True),
        "Icon-maskable-512.png": (512, True),
    }
    for name, (size, maskable) in web_targets.items():
        compose(size, maskable).save(WEB_ICONS / name, optimize=True)
    compose(64).save(ROOT / "web" / "favicon.png", optimize=True)
    print("PWA ikonlari: 180 / 192 / 512 + maskable + favicon")

    if IOS_ICONS.exists():
        ios_targets = {
            "Icon-App-20x20@2x.png": 40,
            "Icon-App-20x20@3x.png": 60,
            "Icon-App-29x29@1x.png": 29,
            "Icon-App-29x29@2x.png": 58,
            "Icon-App-29x29@3x.png": 87,
            "Icon-App-40x40@1x.png": 40,
            "Icon-App-40x40@2x.png": 80,
            "Icon-App-40x40@3x.png": 120,
            "Icon-App-60x60@2x.png": 120,
            "Icon-App-60x60@3x.png": 180,
            "Icon-App-20x20@1x.png": 20,
            "Icon-App-76x76@1x.png": 76,
            "Icon-App-76x76@2x.png": 152,
            "Icon-App-83.5x83.5@2x.png": 167,
            "Icon-App-1024x1024@1x.png": 1024,
        }
        for name, size in ios_targets.items():
            compose(size, label=size >= 100).save(IOS_ICONS / name, optimize=True)
        print(f"iOS ikonlari: {len(ios_targets)} dosya")
    else:
        print("iOS klasoru yok; iOS ikonlari atlandi")


if __name__ == "__main__":
    save()
