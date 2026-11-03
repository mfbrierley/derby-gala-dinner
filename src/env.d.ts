// Build-time environment. Vercel sets VERCEL=1 during its builds (used to keep previews out of search engines).
declare const process: { env: Record<string, string | undefined> };
