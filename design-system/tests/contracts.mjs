import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
const root = new URL("../", import.meta.url);
const data = JSON.parse(readFileSync(new URL("tokens/tokens.json", root)));
const rgb = (hex) =>
  hex
    .slice(1)
    .match(/../g)
    .map((x) => parseInt(x, 16) / 255)
    .map((x) => (x <= 0.04045 ? x / 12.92 : ((x + 0.055) / 1.055) ** 2.4));
const lum = (hex) =>
  rgb(hex).reduce((s, x, i) => s + x * [0.2126, 0.7152, 0.0722][i], 0);
const contrast = (a, b) => {
  const x = lum(a),
    y = lum(b);
  return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05);
};
for (const [name, t] of Object.entries(data.themes)) {
  for (const bg of ["canvas", "surface", "card", "raised"])
    for (const fg of ["text", "muted", "danger", "success"])
      assert.ok(contrast(t[fg], t[bg]) >= 4.5, `${name}: ${fg}/${bg}`);
  for (const bg of ["accent", "accent-hover"])
    assert.ok(contrast(t["on-accent"], t[bg]) >= 4.5, `${name}: button/${bg}`);
  for (const bg of ["card", "raised"])
    assert.ok(
      contrast(t["control-border"], t[bg]) >= 3,
      `${name}: strong-boundary/${bg}`,
    );
  assert.equal(Object.keys(t).length, 14);
}
const html = readFileSync(new URL("examples/index.html", root), "utf8");
for (const [, ref] of html.matchAll(/(?:href|src)="([^"]+)"/g)) {
  if (/^(?:[a-z][a-z\d+.-]*:|#|\/)/i.test(ref)) continue;
  const path = ref.split(/[?#]/)[0];
  if (path)
    assert.ok(
      readFileSync(new URL(path, new URL("examples/", root))).length,
      ref,
    );
}
assert.ok(!/<script[^>]+src="https?:/.test(html));
console.log(
  "contracts ok: 4 themes, 64 text pairs, 8 button pairs, 8 strong/focus boundary pairs, local example assets",
);
