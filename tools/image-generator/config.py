import os
from dotenv import load_dotenv

load_dotenv()

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
