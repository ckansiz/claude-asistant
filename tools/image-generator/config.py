import os
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env"))

BASE_PICS_DIR = os.path.join(os.path.dirname(__file__), "base-pics")

# API Keys
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
REPLICATE_API_TOKEN = os.getenv("REPLICATE_API_TOKEN")
STABILITY_API_KEY = os.getenv("STABILITY_API_KEY")

# Platform formatları
FORMATS = {
    "feed": {"width": 1024, "height": 1024, "label": "Feed (1080x1080)"},
    "story": {"width": 1024, "height": 1792, "label": "Story / Reels (1080x1920)"},
    "banner": {"width": 1792, "height": 1024, "label": "Banner (1920x1080)"},
    "og": {"width": 1200, "height": 630, "label": "Open Graph / Twitter Card"},
}

# Desteklenen API'ler (key varsa aktif)
def available_apis():
    apis = {}
    if OPENAI_API_KEY:
        apis["1"] = "DALL-E 3 (OpenAI)"
    if REPLICATE_API_TOKEN:
        apis["2"] = "FLUX 1.1 Pro (Replicate)"
    if STABILITY_API_KEY:
        apis["3"] = "Stable Image Core (Stability AI)"
    return apis

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "outputs")
os.makedirs(OUTPUT_DIR, exist_ok=True)

BRANDING = {
    "logo_light": os.path.join(BASE_PICS_DIR, "wesoco-logo-beyaz.svg"),    # koyu arkaplan icin
    "logo_dark":  os.path.join(BASE_PICS_DIR, "wesoco-logo-lacivert.svg"), # acik arkaplan icin
    "logo_scale": 0.22,          # logo genisligini image.width'in %22'si yap
    "logo_margin_bottom": 0.04,  # logonun alttan boslugu (image.height'in %4'u)
    "font_path": os.path.join(BASE_PICS_DIR, "Montserrat-Bold.ttf"),
    "font_url": "https://github.com/JulietaUla/Montserrat/raw/master/fonts/ttf/Montserrat-Bold.ttf",
    "text_size_ratio": 0.065,    # font boyutu = image.width * text_size_ratio
    "text_color_on_dark":  (255, 255, 255),  # koyu bg -> beyaz yazi
    "text_color_on_light": (12, 23, 39),     # acik bg -> lacivert yazi (#0c1727)
    "text_shadow": True,
    "text_top_ratio": 0.12,      # metin blogunun ust kenari (image.height * ratio)
}
