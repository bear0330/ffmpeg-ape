# ffmpeg-ape for Python

`ffmpeg-ape` bundles the same portable `ffmpeg.com` and `ffprobe.com` used by
this repository. No system FFmpeg installation is needed.

```python
from ffmpeg_ape import probe, run

run('-i', 'input.wav', '-c:a', 'aac', 'output.mp4')
info = probe('output.mp4')
print(info['format']['duration'])
```

For the complete CLI surface, use explicit argv:

```python
from ffmpeg_ape import ffmpeg, ffprobe

ffmpeg(['-i', 'input.wav', '-c:a', 'flac', 'output.flac'])
result = ffprobe(['-v', 'error', '-show_format', '-of', 'json', 'output.flac'])
```

`probe()` is the JSON convenience function. `ffmpeg()` and `ffprobe()` return
an APEBind `APEProcessResult` and raise `APEProcessError` for a non-zero exit.

This is a useful media subset, not a claim of a full FFmpeg distribution.
