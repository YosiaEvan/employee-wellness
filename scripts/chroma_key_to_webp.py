#!/usr/bin/env python3
"""Convert a green-screen video into a transparent animated WebP.

Requires FFmpeg/ffprobe on PATH and Pillow (`py -3 -m pip install Pillow`).

Example:
  py -3 scripts/chroma_key_to_webp.py assets/videos/keranAir.mp4 \
    --output assets/videos/keranAir-vr.webp --crop 160,70,900,650
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image, features


def parse_crop(value: str) -> tuple[int, int, int, int]:
    try:
        crop = tuple(int(part.strip()) for part in value.split(","))
    except ValueError as error:
        raise argparse.ArgumentTypeError("crop harus berformat x,y,width,height") from error
    if len(crop) != 4 or min(crop) < 0 or crop[2] == 0 or crop[3] == 0:
        raise argparse.ArgumentTypeError("crop harus berformat x,y,width,height yang valid")
    return crop  # type: ignore[return-value]


def read_video_size(ffprobe: str, source: Path) -> tuple[int, int]:
    result = subprocess.run(
        [
            ffprobe,
            "-v",
            "error",
            "-select_streams",
            "v:0",
            "-show_entries",
            "stream=width,height",
            "-of",
            "json",
            str(source),
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    streams = json.loads(result.stdout).get("streams", [])
    if not streams:
        raise ValueError(f"Tidak ditemukan video stream: {source}")
    return int(streams[0]["width"]), int(streams[0]["height"])


def read_exact(stream, byte_count: int) -> bytes:
    chunks = bytearray()
    while len(chunks) < byte_count:
        chunk = stream.read(byte_count - len(chunks))
        if not chunk:
            break
        chunks.extend(chunk)
    return bytes(chunks)


def convert(args: argparse.Namespace) -> int:
    ffmpeg = shutil.which(args.ffmpeg)
    ffprobe = shutil.which(args.ffprobe)
    if not ffmpeg or not ffprobe:
        raise RuntimeError("FFmpeg dan ffprobe harus tersedia di PATH")
    if not features.check("webp"):
        raise RuntimeError("Pillow harus dibangun dengan dukungan WebP")

    source = args.input.resolve()
    if not source.is_file():
        raise FileNotFoundError(f"Video tidak ditemukan: {source}")
    output = (args.output or source.with_name(f"{source.stem}-transparent.webp")).resolve()

    source_width, source_height = read_video_size(ffprobe, source)
    crop = args.crop
    crop_width, crop_height = source_width, source_height
    filters: list[str] = []
    if crop:
        x, y, crop_width, crop_height = crop
        if x + crop_width > source_width or y + crop_height > source_height:
            raise ValueError(
                f"Crop {crop} melewati batas video {source_width}x{source_height}"
            )
        filters.append(f"crop={crop_width}:{crop_height}:{x}:{y}")

    output_height = round(args.width * crop_height / crop_width)
    output_height += output_height % 2
    filters.extend(
        [
            f"fps={args.fps}",
            f"scale={args.width}:{output_height}:flags=lanczos",
            "format=rgba",
            f"chromakey={args.key_color}:{args.similarity}:{args.blend}",
        ]
    )
    command = [
        ffmpeg,
        "-hide_banner",
        "-loglevel",
        "error",
        "-i",
        str(source),
        "-vf",
        ",".join(filters),
        "-an",
        "-sn",
        "-dn",
        "-f",
        "rawvideo",
        "-pix_fmt",
        "rgba",
        "pipe:1",
    ]

    frame_size = args.width * output_height * 4
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    frames: list[Image.Image] = []
    assert process.stdout is not None
    try:
        while True:
            raw_frame = read_exact(process.stdout, frame_size)
            if not raw_frame:
                break
            if len(raw_frame) != frame_size:
                raise RuntimeError("FFmpeg menghasilkan frame RGBA yang terpotong")
            frames.append(Image.frombytes("RGBA", (args.width, output_height), raw_frame))
    finally:
        process.stdout.close()

    stderr = process.stderr.read().decode("utf-8", errors="replace") if process.stderr else ""
    exit_code = process.wait()
    if exit_code != 0:
        raise RuntimeError(stderr or f"FFmpeg berhenti dengan status {exit_code}")
    if len(frames) < 2:
        raise RuntimeError("Video harus memiliki setidaknya dua frame")

    output.parent.mkdir(parents=True, exist_ok=True)
    frames[0].save(
        output,
        format="WEBP",
        save_all=True,
        append_images=frames[1:],
        duration=round(1000 / args.fps),
        loop=0,
        quality=args.quality,
        method=args.method,
        alpha_quality=100,
        exact=True,
    )

    with Image.open(output) as check:
        if not check.is_animated or check.n_frames < 2:
            raise RuntimeError(f"Output tidak berisi animated WebP yang valid: {output}")
        check.seek(0)
        alpha_min, alpha_max = check.convert("RGBA").getchannel("A").getextrema()
        if alpha_min == 255 or alpha_max == 0:
            raise RuntimeError("Output tidak memiliki kombinasi piksel transparan dan objek")

    print(
        f"Berhasil: {output} ({len(frames)} frame, "
        f"{args.width}x{output_height}, transparansi terverifikasi)"
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="Video green-screen sumber")
    parser.add_argument("--output", type=Path, help="Path output animated WebP")
    parser.add_argument("--ffmpeg", default="ffmpeg", help="Executable FFmpeg")
    parser.add_argument("--ffprobe", default="ffprobe", help="Executable ffprobe")
    parser.add_argument("--crop", type=parse_crop, help="Crop video: x,y,width,height")
    parser.add_argument("--width", type=int, default=480, help="Lebar frame output")
    parser.add_argument("--fps", type=int, default=10, help="Frame rate output")
    parser.add_argument("--key-color", default="0x12bd28", help="Warna latar green-screen")
    parser.add_argument("--similarity", type=float, default=0.12, help="Toleransi warna chroma-key")
    parser.add_argument("--blend", type=float, default=0.04, help="Blend tepi chroma-key")
    parser.add_argument("--quality", type=int, default=75, help="Kualitas WebP 0-100")
    parser.add_argument("--method", type=int, default=3, choices=range(7), help="Kecepatan/rasio kompresi WebP")
    args = parser.parse_args()

    if args.width < 2 or args.fps < 1 or not 0 <= args.quality <= 100:
        parser.error("width/fps harus positif dan quality berada di rentang 0-100")
    try:
        return convert(args)
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        print(f"Gagal: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
