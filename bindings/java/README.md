# ffmpeg-ape

Dependency-free Java 17 binding around bundled `ffmpeg.com` and `ffprobe.com`.
It keeps FFmpeg's CLI as the API rather than recreating it in Java.

Both APEs are bundled under `src/main/resources/apebind/` and extracted to
temporary executable files on first use.

```java
import apebind.generated.ffmpeg_ape.FFmpeg;
import java.nio.file.Path;
import java.util.Map;

FFmpeg.run("-i", "input.wav", "-c:a", "aac", "output.mp4");
Map<String, Object> info = FFmpeg.probe(Path.of("output.mp4"));
```

For arbitrary CLI arguments, use `FFmpeg.ffmpeg(List.of(...))` and
`FFmpeg.ffprobe(List.of(...))`; both return `APEProcessResult`.

The FFmpeg LGPL-2.1-or-later text and third-party notices are bundled as
resources under `licenses/`.

Build with Maven:

```bash
mvn package
```

## WSL2

If an operation fails with `TLSError([0x6300])`, WSL may be routing the bundled
`.com` APE through Windows interop. Run the following in WSL, then restart the
WSL session:

```bash
sudo sh -c 'echo -1 > /proc/sys/fs/binfmt_misc/WSLInterop'
```
