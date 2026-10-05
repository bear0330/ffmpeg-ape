import type { APEProcessResult, RawOptions } from './_runtime.js';

export function ffmpeg(
  arguments_: readonly unknown[],
  options?: RawOptions,
): Promise<APEProcessResult>;
export function ffprobe(
  arguments_: readonly unknown[],
  options?: RawOptions,
): Promise<APEProcessResult>;
export function run(...arguments_: readonly unknown[]): Promise<APEProcessResult>;
export function probe(
  source: string,
  options?: RawOptions & { arguments?: readonly unknown[] },
): Promise<Record<string, unknown>>;
export {
  createClient,
  type ClientOptions,
  raw,
} from './client.js';
export {
  APEEvent,
  APEEventError,
  type APEEventMap,
  APEProcessError,
  APEProcessResult,
  APETimeoutError,
  ProcessSession,
  type RawOptions,
} from './_runtime.js';
