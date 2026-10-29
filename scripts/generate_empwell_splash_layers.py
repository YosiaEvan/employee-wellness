#!/usr/bin/env python3
"""Split the EmpWell logo raster into antialiased semantic splash layers."""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from PIL import Image


PALETTE = {
    "blue": (10, 112, 222),
    "orange": (255, 120, 5),
    "green": (7, 152, 85),
    "wordmark": (4, 25, 69),
}


def create_layer(rgb: np.ndarray, hsv: np.ndarray, name: str) -> Image.Image:
    height, width, _ = rgb.shape
    hue, saturation, value = (hsv[:, :, index] for index in range(3))
    upper = np.indices((height, width))[0] < 800
    lower = ~upper

    if name == "blue":
        mask = upper & (hue >= 135) & (hue <= 175) & (saturation > 16)
    elif name == "orange":
        mask = upper & (hue >= 5) & (hue <= 35) & (saturation > 18)
    elif name == "green":
        mask = upper & (hue >= 80) & (hue <= 130) & (saturation > 16)
    else:
        mask = lower & (hue >= 135) & (hue <= 180) & (saturation > 12) & (value < 245)

    # Estimate edge alpha by unmixing each JPEG pixel against its flat logo color
    # and the near-white background. This keeps the antialiased edges smooth.
    foreground = np.asarray(PALETTE[name], dtype=np.float32)
    background = np.full(3, 255, dtype=np.float32)
    direction = background - foreground
    source = rgb.astype(np.float32)
    alpha = np.sum((background - source) * direction, axis=2) / np.sum(direction**2)
    alpha = np.clip(alpha, 0.0, 1.0)
    alpha[~mask] = 0.0
    alpha[alpha < 0.025] = 0.0

    rgba = np.empty((height, width, 4), dtype=np.uint8)
    rgba[:, :, :3] = foreground.astype(np.uint8)
    rgba[:, :, 3] = np.round(alpha * 255).astype(np.uint8)
    return Image.fromarray(rgba, "RGBA")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source",
        type=Path,
        default=Path("assets/img/logoapk-employeewellness.jpeg"),
    )
    parser.add_argument("--output-dir", type=Path, default=Path("assets/img"))
    args = parser.parse_args()

    source = Image.open(args.source).convert("RGB")
    rgb = np.asarray(source)
    hsv = np.asarray(source.convert("HSV"))

    for name in PALETTE:
        layer = create_layer(rgb, hsv, name)
        output = args.output_dir / f"empwell_splash_{name}.png"
        layer.save(output, format="PNG", optimize=True)
        print(f"{output}: {source.width}x{source.height}")

    android_splash = source.resize((256, 256), Image.Resampling.LANCZOS)
    android_path = Path("android/app/src/main/res/drawable/launch_image.png")
    android_splash.save(android_path, format="PNG", optimize=True)
    print(f"{android_path}: {android_splash.width}x{android_splash.height}")

    ios_sizes = {
        "LaunchImage.png": 168,
        "LaunchImage@2x.png": 336,
        "LaunchImage@3x.png": 504,
    }
    ios_dir = Path("ios/Runner/Assets.xcassets/LaunchImage.imageset")
    for filename, width in ios_sizes.items():
        launch_image = source.resize((width, width), Image.Resampling.LANCZOS)
        launch_image.save(ios_dir / filename, format="PNG", optimize=True)
        print(f"{ios_dir / filename}: {width}x{width}")


if __name__ == "__main__":
    main()
