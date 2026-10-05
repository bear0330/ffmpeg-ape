package apebind.generated.ffmpeg_ape;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Thin conveniences over the bundled FFmpeg and FFprobe command-line tools.
 *
 * <p>The FFmpeg CLI is deliberately kept as the public API: pass ordinary
 * command-line arguments to {@link #ffmpeg(List)} or {@link #ffprobe(List)}.
 * {@link #probe(Path)} only supplies FFprobe's commonly useful JSON flags.</p>
 */
public final class FFmpeg {
    private static final APEClient FFPROBE = new APEClient(
        BinaryResource.resolve("ffprobe.com"),
        Map.of(),
        Map.of()
    );

    private FFmpeg() {}

    public static APEProcessResult ffmpeg(List<?> arguments) {
        return FfmpegAPEBinding.raw(arguments);
    }

    public static APEProcessResult ffprobe(List<?> arguments) {
        return FFPROBE.raw(arguments);
    }

    public static APEProcessResult run(String... arguments) {
        return ffmpeg(List.of(arguments));
    }

    public static Map<String, Object> probe(Path source) {
        return probe(source, List.of());
    }

    public static Map<String, Object> probe(Path source, List<?> extraArguments) {
        List<Object> arguments = new ArrayList<>(List.of(
            "-v", "error",
            "-show_format", "-show_streams",
            "-of", "json"
        ));
        arguments.addAll(extraArguments);
        arguments.add(source.toString());
        return Json.object(Json.parse(ffprobe(arguments).stdout()));
    }
}
