// Build-time environment. Vercel sets VERCEL=1 during its builds (used to keep previews out of search engines).
declare const process: { env: Record<string, string | undefined> };

// The two Node file functions astro.config.mjs uses (Node's full type definitions aren't installed).
declare module 'node:fs/promises' {
  export function readFile(path: URL | string, encoding: 'utf8'): Promise<string>;
  export function writeFile(path: URL | string, data: string): Promise<void>;
}
