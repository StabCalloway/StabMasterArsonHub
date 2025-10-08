#!/usr/bin/env node
import fs from 'fs';
import { execSync } from 'child_process';

const enhancementsDir = './docs/enhancements';
const manifestPath = './docs/manifest.json';
const historyPath = './docs/manifest-history.md';

console.log("🔄 Building manifest...");
const files = fs.readdirSync(enhancementsDir).filter(f => f.endsWith('.json'));
let entries = [];

for (const file of files) {
  try {
    const data = JSON.parse(fs.readFileSync(`${enhancementsDir}/${file}`, 'utf8'));
    entries.push(...data.enhancements);
  } catch (err) {
    console.error(`⚠️ Error parsing ${file}:`, err.message);
  }
}

fs.writeFileSync(manifestPath, JSON.stringify({ updated: new Date(), enhancements: entries }, null, 2));

console.log(`✅ Manifest built with ${entries.length} enhancements.`);

try {
  execSync(`git add ${manifestPath}`);
  execSync(`git commit -m "Auto: Manifest update"`);
  const tag = `manifest-v${new Date().toISOString().slice(0,10)}`;
  execSync(`git tag ${tag}`);
  execSync(`git push && git push --tags`);
  console.log(`🏷️ Pushed tag: ${tag}`);
} catch {
  console.log("⚠️ Git push skipped or not configured.");
}
