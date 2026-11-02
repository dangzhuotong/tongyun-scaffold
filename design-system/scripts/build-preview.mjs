// Dependencies stay outside the scaffold; see adapters/README.md.
import { createRequire } from "node:module";
import { dirname, resolve, join } from "node:path";
import { readFileSync, existsSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
const root = fileURLToPath(new URL("../", import.meta.url));
const deps = process.argv[2];
if (!deps)
  throw Error(
    "Usage: node design-system/scripts/build-preview.mjs /absolute/dependency-directory",
  );
const require = createRequire(join(resolve(deps), "package.json"));
const { build } = require("esbuild");
const result = await build({
  entryPoints: [join(root, "examples/select-preview.tsx")],
  outfile: join(root, "examples/select-preview.js"),
  bundle: true,
  minify: true,
  format: "iife",
  jsx: "automatic",
  target: ["es2020"],
  define: { "process.env.NODE_ENV": '"production"' },
  nodePaths: [join(resolve(deps), "node_modules")],
  metafile: true,
  legalComments: "none",
});
const seen = new Set();
const notices = [];
for (const input of Object.keys(result.metafile.inputs)) {
  if (!input.includes("node_modules")) continue;
  let dir = dirname(resolve(input));
  while (!existsSync(join(dir, "package.json")) && dirname(dir) !== dir)
    dir = dirname(dir);
  const pkg = JSON.parse(readFileSync(join(dir, "package.json"), "utf8"));
  if (seen.has(pkg.name)) continue;
  seen.add(pkg.name);
  const license = [
    "LICENSE",
    "LICENSE.md",
    "LICENSE.txt",
    "license",
    "LICENSE.MIT",
  ]
    .map((x) => join(dir, x))
    .find(existsSync);
  const fallback = join(
    root,
    "scripts/licenses",
    pkg.name.replaceAll("/", "_") + ".txt",
  );
  if (!license && !existsSync(fallback))
    throw Error(`Missing license text: ${pkg.name}`);
  notices.push(
    `${pkg.name} ${pkg.version} (${pkg.license})\n${readFileSync(license ?? fallback, "utf8")}`,
  );
}
writeFileSync(
  join(root, "examples/SELECT-NOTICES.txt"),
  "Bundled select preview dependencies; application source remains in select-preview.tsx.\n\n" +
    notices.join("\n\n---\n\n"),
);
console.log(`Select preview built; ${seen.size} dependency notices recorded.`);
