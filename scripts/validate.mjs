import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { createRequire } from "node:module";

const root = path.resolve(import.meta.dirname, "..");
const tocPath = path.join(root, "ForeverExpeditionPlanner.toc");
const errors = [];
let luaParser = null;
const require = createRequire(import.meta.url);
const parserCandidates = [
  path.join(process.env.APPDATA || "", "npm", "node_modules", "luaparse"),
  "luaparse",
];
for (const candidate of parserCandidates) {
  try { luaParser = require(candidate); break; } catch { /* structural fallback below */ }
}
const toc = fs.readFileSync(tocPath, "utf8");

if (!/^## Interface: 16001$/m.test(toc)) errors.push("TOC Interface must be 16001");
if (!/^## SavedVariables: ForeverExpeditionPlannerDB$/m.test(toc)) errors.push("SavedVariables declaration missing");
if (!/^## IconTexture: Interface\\AddOns\\ForeverExpeditionPlanner\\Media\\Icon$/m.test(toc)) errors.push("Bundled icon metadata missing");
const iconPath = path.join(root, "Media", "Icon.tga");
if (!fs.existsSync(iconPath) || fs.statSync(iconPath).size !== 16402) errors.push("Bundled 64x64 32-bit TGA icon missing or malformed");

const entries = toc.split(/\r?\n/).map((line) => line.trim()).filter((line) => line && !line.startsWith("##"));
for (const entry of entries) {
  const file = path.join(root, entry.replaceAll("\\", path.sep));
  if (!fs.existsSync(file)) errors.push(`TOC entry missing: ${entry}`);
}

const luaFiles = [];
function walk(dir) {
  for (const item of fs.readdirSync(dir, { withFileTypes: true })) {
    if ([".git", "dist"].includes(item.name)) continue;
    const full = path.join(dir, item.name);
    if (item.isDirectory()) walk(full);
    else if (item.name.endsWith(".lua")) luaFiles.push(full);
  }
}
walk(root);

for (const file of luaFiles) {
  const source = fs.readFileSync(file, "utf8");
  if (!source.endsWith("\n")) errors.push(`${path.relative(root, file)}: missing final newline`);
  if (/\b(?:CombatLogGetCurrentEventInfo|CastSpellByName|RunMacroText|SecureActionButtonTemplate)\b/.test(source)) {
    errors.push(`${path.relative(root, file)}: forbidden combat/protected API reference`);
  }
  if (luaParser) {
    try { luaParser.parse(source, { luaVersion: "5.1" }); }
    catch (error) { errors.push(`${path.relative(root, file)}: Lua 5.1 parse failed: ${error.message}`); }
  }
  const stripped = source
    .replace(/--\[\[[\s\S]*?\]\]/g, "")
    .replace(/--[^\n]*/g, "")
    .replace(/"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'/g, "");
  const pairs = { "(": ")", "[": "]", "{": "}" };
  const stack = [];
  for (const char of stripped) {
    if (pairs[char]) stack.push(pairs[char]);
    else if ([")", "]", "}"].includes(char) && stack.pop() !== char) {
      errors.push(`${path.relative(root, file)}: unbalanced delimiter near ${char}`);
      break;
    }
  }
  if (stack.length) errors.push(`${path.relative(root, file)}: unclosed delimiter`);
}

for (const required of ["README.md", "PLAN.md", "PREFLIGHT.md", "LICENSE"]) {
  if (!fs.existsSync(path.join(root, required))) errors.push(`Missing ${required}`);
}

if (errors.length) {
  console.error(errors.map((error) => `ERROR: ${error}`).join("\n"));
  process.exit(1);
}
console.log(`PASS: ${luaFiles.length} Lua files, ${entries.length} TOC entries, metadata and restricted-API checks${luaParser ? ", Lua 5.1 parse" : " (structural parser fallback)"}.`);
