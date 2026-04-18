"""
Compositor - Post-generation image compositing
Adds text overlay and Wesoco logo to AI-generated images.
"""

import os
import sys
import textwrap
import urllib.request

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from config import BRANDING, OUTPUT_DIR


def detect_bg_brightness(image: Image.Image, region: str = "bottom") -> str:
    """
    Analyse average luminance of a region to decide logo/text color.
    Returns 'dark' (use white assets) or 'light' (use dark assets).
    """
    w, h = image.size
    if region == "bottom":
        crop = image.crop((0, int(h * 0.70), w, h))
    elif region == "top":
        crop = image.crop((0, 0, w, int(h * 0.30)))
    else:
        crop = image

    rgb = crop.convert("RGB")
    pixels = list(rgb.getdata())
    avg_luminance = sum(0.299 * r + 0.587 * g + 0.114 * b for r, g, b in pixels) / len(pixels)
    return "dark" if avg_luminance < 128 else "light"


def rasterize_svg(svg_path: str, target_width_px: int) -> Image.Image:
    """Convert SVG to PIL Image at target width, preserving aspect ratio."""
    import cairosvg
    import io

    png_bytes = cairosvg.svg2png(url=svg_path, output_width=target_width_px)
    return Image.open(io.BytesIO(png_bytes)).convert("RGBA")


def _ensure_font() -> str:
    """Download Montserrat-Bold if not present. Returns path."""
    font_path = BRANDING["font_path"]
    if not os.path.exists(font_path):
        print(f"   Downloading font to {font_path}...")
        urllib.request.urlretrieve(BRANDING["font_url"], font_path)
    return font_path


def composite_logo(image: Image.Image) -> Image.Image:
    """Paste the correct Wesoco logo at the bottom-center of the image."""
    bg_tone = detect_bg_brightness(image, region="bottom")
    svg_path = BRANDING["logo_light"] if bg_tone == "dark" else BRANDING["logo_dark"]

    logo_width = int(image.width * BRANDING["logo_scale"])
    logo = rasterize_svg(svg_path, logo_width)

    margin_bottom = int(image.height * BRANDING["logo_margin_bottom"])
    x = (image.width - logo.width) // 2
    y = image.height - logo.height - margin_bottom

    result = image.copy().convert("RGBA")
    result.paste(logo, (x, y), mask=logo)
    return result


def composite_text(image: Image.Image, text: str) -> Image.Image:
    """Render Turkish text overlay at the top area of the image."""
    if not text:
        return image

    bg_tone = detect_bg_brightness(image, region="top")
    text_color = BRANDING["text_color_on_dark"] if bg_tone == "dark" else BRANDING["text_color_on_light"]

    font_size = int(image.width * BRANDING["text_size_ratio"])
    font_path = _ensure_font()

    try:
        font = ImageFont.truetype(font_path, font_size)
    except (IOError, OSError):
        font = ImageFont.load_default()

    result = image.copy().convert("RGBA")
    draw = ImageDraw.Draw(result)

    # Word-wrap: ~20 chars per line → 2 clean lines for typical greetings
    max_chars = max(10, int(image.width / (font_size * 0.75)))
    lines = textwrap.wrap(text, width=max_chars)

    line_height = font_size + int(font_size * 0.35)
    total_text_height = len(lines) * line_height

    start_y = int(image.height * BRANDING["text_top_ratio"])

    for i, line in enumerate(lines):
        bbox = draw.textbbox((0, 0), line, font=font)
        text_w = bbox[2] - bbox[0]
        x = (image.width - text_w) // 2
        y = start_y + i * line_height

        if BRANDING.get("text_shadow"):
            shadow_offset = max(2, font_size // 20)
            draw.text((x + shadow_offset, y + shadow_offset), line, font=font, fill=(0, 0, 0, 140))

        draw.text((x, y), line, font=font, fill=(*text_color, 255))

    return result


def finalize_image(image_path: str, overlay_text: str, platform: str) -> str:
    """
    Composite text overlay and logo onto the generated image.
    Saves result as {original_name}_final.png and returns the new path.
    """
    image = Image.open(image_path).convert("RGBA")

    if overlay_text:
        image = composite_text(image, overlay_text)

    image = composite_logo(image)

    base = os.path.splitext(os.path.basename(image_path))[0]
    output_path = os.path.join(OUTPUT_DIR, f"{base}_final.png")
    image.convert("RGB").save(output_path, "PNG")

    return output_path
