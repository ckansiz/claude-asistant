#!/usr/bin/env python3
"""
Image Generator - CLI Entry Point
"""

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from config import available_apis, FORMATS
from lib.prompt import generate_prompt
from lib.image import GENERATORS


BANNER = """
+----------------------------------------------+
|      Image Generator                         |
|      AI-Powered Visual Creation              |
+----------------------------------------------+
"""

def print_step(emoji: str, title: str, message: str = ""):
    print(f"\n{emoji}  \033[1m{title}\033[0m")
    if message:
        print(f"   {message}")

def ask(prompt: str, options: dict = None) -> str:
    if options:
        print()
        for key, label in options.items():
            print(f"   [{key}] {label}")
        print()
    value = input(f"   > {prompt} ").strip()
    return value

def ask_platform() -> list:
    print_step("*", "Platform Selection", "Where will this image be used?")
    print()
    print("   [1] Feed (1080x1080 - Instagram/Facebook/X square post)")
    print("   [2] Story / Reels (1080x1920 - vertical)")
    print("   [3] Banner (1920x1080 - website hero)")
    print("   [4] OG Image (1200x630 - social sharing card)")
    print("   [5] Feed + Story (2 images)")
    print()
    choice = input("   > Choice (1/2/3/4/5): ").strip()

    platform_map = {
        "1": ["feed"],
        "2": ["story"],
        "3": ["banner"],
        "4": ["og"],
        "5": ["feed", "story"],
    }
    return platform_map.get(choice, ["feed"])

def ask_api(apis: dict) -> str:
    print_step("~", "API Selection", "Which model to use?")
    choice = ask("Choice:", apis)
    if choice not in apis:
        first = list(apis.keys())[0]
        print(f"   Warning: Invalid choice, using {apis[first]}.")
        return first
    return choice

def main():
    print(BANNER)

    apis = available_apis()
    if not apis:
        print("ERROR: No API keys found!")
        print("   Add at least one API key to .env:")
        print("   OPENAI_API_KEY=sk-...")
        print("   REPLICATE_API_TOKEN=r8_...")
        print("   STABILITY_API_KEY=sk-...")
        sys.exit(1)

    # 1. User request
    print_step("*", "Image Request")
    request = ask("What do you want to see? (Turkish or English):")
    if not request:
        print("   You need to describe something!")
        sys.exit(1)

    extra = ask("Extra context? (brand colors, tone, style - can leave empty):")

    # 2. Overlay text
    print_step("*", "Text Overlay", "Gorusel uzerine yazilacak metin (bos birakabilirsin):")
    overlay_text = ask("Metin (orn: 14 Subat Sevgililer Gununuz Kutlu Olsun):")

    # 3. Platform
    platforms = ask_platform()

    # 4. API selection
    api_key = ask_api(apis)
    api_name = apis[api_key]

    # 5. Prompt generation
    results = []
    for platform in platforms:
        platform_label = FORMATS[platform]["label"]

        print_step(">", f"Generating prompt...", f"Platform: {platform_label}")

        try:
            prompt_data = generate_prompt(
                user_request=request,
                platform=platform,
                extra_context=extra
            )
            print(f"   Prompt ready!")
            print(f"   {prompt_data['positive_prompt'][:80]}...")
            if prompt_data.get("style_notes"):
                print(f"   Style: {prompt_data['style_notes']}")
        except Exception as e:
            print(f"   ERROR: Prompt generation failed: {e}")
            continue

        # 6. Image generation + compositing
        print_step(">", f"Generating image...", f"{api_name} - please wait...")

        try:
            generator = GENERATORS[api_key]
            filepath = generator(
                positive_prompt=prompt_data["positive_prompt"],
                negative_prompt=prompt_data.get("negative_prompt", ""),
                platform=platform,
                overlay_text=overlay_text,
            )
            results.append((platform_label, filepath))
            print(f"   Image ready!")
        except Exception as e:
            print(f"   ERROR: Image generation failed: {e}")
            continue

    # 6. Results
    if results:
        print("\n" + "=" * 50)
        print("Done! Here are your images:\n")
        for label, path in results:
            print(f"   {label}")
            print(f"      {os.path.abspath(path)}\n")
        print("=" * 50)

        again = input("\n   Generate another? (y/n): ").strip().lower()
        if again == "y":
            main()
    else:
        print("\nERROR: No images generated. Check your API keys.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nBye!")
