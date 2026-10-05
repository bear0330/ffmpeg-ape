import { APEClient } from './_runtime.js';
import { fileURLToPath } from 'node:url';

import { raw as ffmpegRaw } from './client.js';

const ffprobeClient = new APEClient(
  fileURLToPath(new URL('./bin/ffprobe.com', import.meta.url)),
  {},
);

/** Run bundled ffmpeg.com with an explicit argv array. */
export async function ffmpeg(arguments_, options = {}) {
  return ffmpegRaw(arguments_, options);
}

/** Run bundled ffprobe.com with an explicit argv array. */
export async function ffprobe(arguments_, options = {}) {
  return ffprobeClient.raw(arguments_, options);
}

/** Run FFmpeg with varargs, or with one argv array. */
export async function run(...arguments_) {
  const argv = arguments_.length === 1 && Array.isArray(arguments_[0])
    ? arguments_[0]
    : arguments_;
  return ffmpeg(argv);
}

/** Return FFprobe's JSON stream and format description for a media file. */
export async function probe(source, { arguments: extraArguments = [], ...options } = {}) {
  const result = await ffprobe([
    '-v', 'error',
    '-show_format',
    '-show_streams',
    '-of', 'json',
    ...extraArguments,
    source,
  ], options);
  return JSON.parse(result.stdout);
}

export {
  createClient,
  raw,
} from './client.js';
export {
  APEEvent,
  APEEventError,
  APEProcessError,
  APEProcessResult,
  APETimeoutError,
  ProcessSession,
} from './_runtime.js';
