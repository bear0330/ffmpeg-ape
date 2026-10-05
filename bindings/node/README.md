# ffmpeg-ape for Node.js

`ffmpeg-ape` bundles portable `ffmpeg.com` and `ffprobe.com`. No system
FFmpeg installation is needed.

```js
import { probe, run } from 'ffmpeg-ape';

await run('-i', 'input.wav', '-c:a', 'aac', 'output.mp4');
const info = await probe('output.mp4');
console.log(info.format.duration);
```

Use `ffmpeg([...])` or `ffprobe([...])` for the complete CLI argv escape hatch.
They return APEBind `APEProcessResult` objects and reject on a non-zero exit.

This is a useful media subset, not a claim of a full FFmpeg distribution.
