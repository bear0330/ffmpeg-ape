"""Small convenience API over the generated APEBind raw-argv client."""

from __future__ import annotations

import json

from collections.abc import Iterable
from pathlib import Path
from typing import Any

from ._generated import raw as _ffmpeg_raw
from ._runtime import APEClient, APEProcessResult


_FFPROBE = APEClient(Path(__file__).parent / 'bin' / 'ffprobe.com', {})


def ffmpeg(arguments: Iterable[object]) -> APEProcessResult:
    """Run bundled ``ffmpeg.com`` with an explicit argv sequence."""
    return _ffmpeg_raw([str(argument) for argument in arguments])


def ffprobe(arguments: Iterable[object]) -> APEProcessResult:
    """Run bundled ``ffprobe.com`` with an explicit argv sequence."""
    return _FFPROBE.raw([str(argument) for argument in arguments])


def run(*arguments: object) -> APEProcessResult:
    """Run FFmpeg, accepting either varargs or one argv sequence."""
    if len(arguments) == 1 and not isinstance(arguments[0], (str, bytes)):
        candidate = arguments[0]
        if isinstance(candidate, Iterable):
            return ffmpeg(candidate)

    return ffmpeg(arguments)


def probe(source: str | Path, *arguments: object) -> dict[str, Any]:
    """Return FFprobe's JSON stream and format description for ``source``.

    Extra arguments are inserted before the source path, allowing callers to
    request additional FFprobe fields without replacing the portable default.
    """
    result = ffprobe([
        '-v', 'error',
        '-show_format',
        '-show_streams',
        '-of', 'json',
        *arguments,
        source,
    ])
    return json.loads(result.stdout)
