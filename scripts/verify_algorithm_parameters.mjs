// Check the task wizard's actual parser against the live algorithm registry.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const frontendRequire = createRequire(path.join(root, 'frontend', 'package.json'));
const { parse: parseVue } = frontendRequire('@vue/compiler-sfc');
const { parse: parseJs } = frontendRequire('@babel/parser');
const file = path.join(root, 'frontend', 'src', 'views', 'task', 'task', 'index.vue');
const { descriptor, errors } = parseVue(fs.readFileSync(file, 'utf8'));
assert.equal(errors.length, 0, 'Vue file failed parsing');
const source = descriptor.scriptSetup.content;
const ast = parseJs(source, { sourceType: 'module' });
const declaration = ast.program.body.find(node => node.type === 'FunctionDeclaration'
  && node.id.name === 'validateAndProcessAlgorithmParams');
assert.ok(declaration, 'Task wizard parameter parser not found');
const parseParameters = vm.runInNewContext(`(${source.slice(declaration.start, declaration.end)})`, { console });
const response = await fetch('http://127.0.0.1:8000/list');
assert.ok(response.ok, 'Algorithm registry unavailable');
const registry = await response.json();
const tested = [];
for (const [name, info] of Object.entries(registry)) {
  const result = parseParameters(info);
  // JSON-normalize VM objects so realm-specific prototypes do not affect equality.
  assert.deepEqual(JSON.parse(JSON.stringify(result.parameters)), JSON.parse(info.args), `${name}: defaults mismatch`);
  assert.deepEqual(JSON.parse(JSON.stringify(result.parameters_intro)), JSON.parse(info.args_intro), `${name}: parameter descriptions mismatch`);
  assert.equal(result.hasValidParams, true, `${name}: parameters unexpectedly rejected`);
  tested.push(name);
}
const legacy = parseParameters({ args: '{"input_conf":0.5}', intro: 'Legacy description' });
assert.equal(legacy.parameters_intro.input_conf, 'Legacy description', 'Legacy description fallback failed');
const report = { checked_at: new Date().toISOString(), passed: true, algorithms: tested, legacy_fallback: true };
const output = path.join(root, 'tmp', 'algorithm-import-20261014', 'verification', 'frontend-parameters.json');
fs.mkdirSync(path.dirname(output), { recursive: true });
fs.writeFileSync(output, JSON.stringify(report, null, 2) + '\n');
console.log(`Verified defaults and descriptions for ${tested.length} algorithms; legacy fallback passed.`);
