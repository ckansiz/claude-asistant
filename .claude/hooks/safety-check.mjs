#!/usr/bin/env node
/**
 * Safety Check Hook — PreToolUse (Claude Code)
 *
 * Bash aracıyla çalıştırılmak istenen komutları kontrol eder.
 * Yıkıcı operasyonlar tespit edildiğinde komutu engeller; kullanıcı onayı gerekir.
 *
 * Generic across the eng-team stacks:
 *   - SQL destructive (drop/delete/truncate)
 *   - File system destructive (rm -rf)
 *   - Git destructive (push --force, reset --hard, clean -fd)
 *   - DB migration rollback/reset (EF Core, Prisma, Drizzle, Strapi)
 *   - Seed / migration scripts
 *   - Docker destructive (volume rm, system prune, down -v)
 *   - Kubernetes destructive (delete namespace/pv)
 *
 * Input: stdin JSON (Claude Code PreToolUse hook input)
 * Output: exit 0 = allow, exit 2 = hard block (stdout → reason)
 */

import { readFileSync } from 'node:fs';

let input;
try {
  input = JSON.parse(readFileSync('/dev/stdin', 'utf-8'));
} catch {
  process.exit(0);
}

const toolName = input?.tool_name || '';
const toolInput = input?.tool_input || {};

if (toolName !== 'Bash') {
  process.exit(0);
}

const command = (toolInput.command || '').toLowerCase();

// SQL destructive
const destructiveSqlPatterns = [
  /\bdrop\s+table\b/,
  /\bdrop\s+column\b/,
  /\bdrop\s+database\b/,
  /\bdrop\s+schema\b/,
  /\bdelete\s+from\b/,
  /\btruncate\b/,
  /\balter\s+table\s+.*\bdrop\b/,
];

// File system destructive
const destructiveFilePatterns = [
  /\brm\s+-rf\b/,
  /\brm\s+-fr\b/,
  /\brm\s+--recursive\b/,
  /\brm\s+-[a-z]*f[a-z]*\s/,
];

// Git destructive
const destructiveGitPatterns = [
  /\bgit\s+push\s+.*--force\b/,
  /\bgit\s+push\s+-f\b/,
  /\bgit\s+reset\s+--hard\b/,
  /\bgit\s+clean\s+-fd\b/,
  /\bgit\s+branch\s+-d\b/,
];

// DB migration rollback / reset
// Covers EF Core, Prisma, Drizzle, Strapi
const destructiveDbPatterns = [
  /\bdotnet\s+ef\s+database\s+drop\b/,
  /\bdotnet\s+ef\s+migrations\s+remove\b/,
  /\bprisma\s+migrate\s+reset\b/,
  /\bprisma\s+db\s+push\s+.*--accept-data-loss\b/,
  /\bdrizzle-kit\s+drop\b/,
  /\bmigrat(e|ion)\s+.*\b(rollback|down|reset|undo)\b/,
  /\b(rollback|down|reset|undo)\s+.*\bmigrat/,
  /\bstrapi\s+.*\breset\b/,
];

// Seed / migration scripts (run-time — require confirmation)
const scriptPatterns = [
  /\byarn\s+seed\b/,
  /\bnpm\s+run\s+seed\b/,
  /\bpnpm\s+seed\b/,
  /\bnode\s+.*seed/,
  /\bnpx\s+.*seed/,
  /\byarn\s+.*migrat/,
  /\bnpm\s+run\s+.*migrat/,
  /\bpnpm\s+.*migrat/,
  /\bdotnet\s+run\s+.*--seed\b/,
  /\bstrapi\s+.*transfer\b/,
  /\bstrapi\s+.*import\b/,
  /\bstrapi\s+.*export\b/,
];

// HTTP delete via curl
const apiDeletePatterns = [
  /\bcurl\s+.*-x\s+delete\b/,
  /\bcurl\s+.*--request\s+delete\b/,
];

// Docker destructive
const destructiveDockerPatterns = [
  /\bdocker-compose\s+down\s+-v\b/,
  /\bdocker\s+compose\s+down\s+-v\b/,
  /\bdocker\s+volume\s+rm\b/,
  /\bdocker\s+volume\s+prune\b/,
  /\bdocker\s+system\s+prune\b/,
  /\bdocker\s+image\s+prune\s+-a\b/,
];

// Kubernetes destructive
const destructiveK8sPatterns = [
  /\bkubectl\s+delete\s+ns\b/,
  /\bkubectl\s+delete\s+namespace\b/,
  /\bkubectl\s+delete\s+pv\b/,
  /\bkubectl\s+delete\s+pvc\b/,
  /\bkubectl\s+delete\s+--all\b/,
  /\bhelm\s+uninstall\b/,
];

// Cloud / deploy destructive
const destructiveCloudPatterns = [
  /\bfly\s+apps\s+destroy\b/,
  /\bvercel\s+remove\s+.*-y\b/,
  /\brailway\s+down\s+-y\b/,
  /\baws\s+s3\s+rb\s+.*--force\b/,
];

const allPatterns = [
  { patterns: destructiveSqlPatterns,    reason: 'Yıkıcı SQL operasyonu (veri/tablo silme)' },
  { patterns: destructiveFilePatterns,   reason: 'Yıkıcı dosya silme operasyonu' },
  { patterns: destructiveGitPatterns,    reason: 'Geri alınamaz Git operasyonu' },
  { patterns: destructiveDbPatterns,     reason: 'Veritabanı migration rollback/reset' },
  { patterns: scriptPatterns,            reason: 'Seed/migration script çalıştırma' },
  { patterns: apiDeletePatterns,         reason: 'API üzerinden veri silme' },
  { patterns: destructiveDockerPatterns, reason: 'Yıkıcı Docker operasyonu (volume/prune)' },
  { patterns: destructiveK8sPatterns,    reason: 'Yıkıcı Kubernetes operasyonu' },
  { patterns: destructiveCloudPatterns,  reason: 'Yıkıcı cloud/deploy operasyonu' },
];

for (const { patterns, reason } of allPatterns) {
  for (const pattern of patterns) {
    if (pattern.test(command)) {
      const message = [
        `⚠️  ENGELLENDİ: ${reason}`,
        `Komut: ${toolInput.command}`,
        ``,
        `Bu operasyon kullanıcı onayı gerektirir.`,
        `Kullanıcıya ne yapmak istediğini açıklayın ve onay isteyin.`,
      ].join('\n');

      process.stdout.write(message);
      process.exit(2); // Claude Code: exit 2 = hard block
    }
  }
}

process.exit(0);
