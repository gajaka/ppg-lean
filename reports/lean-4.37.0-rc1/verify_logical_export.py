"""Inventory exported logical roots independently of the external typechecker."""
import collections
import hashlib
import json
from pathlib import Path
import time

STATE = Path(__file__).resolve().parent
ROOT = Path('/Users/gajaka/projects/ppg-lean-v4.37.0-rc1')
started = time.monotonic()
inputs = json.loads((STATE / 'project-logical-closure-inputs.json').read_text())
audit = json.loads((ROOT / 'reports/PPGRAPH_AXIOM_AUDIT.json').read_text())
excluded = inputs['excluded_runtime_declarations']
expected = {n: r for n, r in audit['declarations'].items() if n not in excluded}
assert len(expected) == 6016 and len(excluded) == 57
assert not any(audit['declarations'][n]['explicit_theorem'] for n in excluded)
assert all(('unsafe' in s or 'partial' in s) for s in excluded.values())
names = {0: ''}
found = {}
axioms = []
unsafe = []
kinds = collections.Counter()

def record(kind, declaration):
    name = names[declaration['name']]
    kinds[kind] += 1
    if kind == 'axiom': axioms.append(name)
    if declaration.get('isUnsafe', False) or declaration.get('safety', 'safe') != 'safe':
        unsafe.append(name)
    if name in expected: found[name] = kind

export = STATE / 'project-logical-closure.ndjson'
hasher = hashlib.sha256()
with export.open('rb') as stream:
    for raw in stream:
        hasher.update(raw)
        if raw.startswith(b'{"in":'):
            row = json.loads(raw)
            part = row.get('str', row.get('num'))
            prefix = names[part['pre']]
            suffix = str(part.get('str', part.get('i')))
            names[row['in']] = (prefix + '.' if prefix else '') + suffix
        elif any(raw.startswith(b'{"' + key + b'":') for key in
                 (b'def', b'thm', b'axiom', b'opaque', b'quot', b'inductive')):
            row = json.loads(raw)
            if 'inductive' in row:
                for key, kind in [('types', 'inductive'), ('ctors', 'constructor'), ('recs', 'recursor')]:
                    for declaration in row['inductive'][key]: record(kind, declaration)
            else:
                kind, declaration = next(iter(row.items()))
                record(kind, declaration)
kind_map = {'definition': 'def', 'theorem': 'thm', 'quotient': 'quot'}
missing = sorted(set(expected) - set(found))
mismatches = sorted(n for n, k in found.items() if k != kind_map.get(expected[n]['kind'], expected[n]['kind']))
changed = [n for n, h in {**inputs['source_sha256'], **inputs['included_input_sha256']}.items()
           if hashlib.sha256((ROOT / n).read_bytes()).hexdigest() != h]
result = {
    'status': 'PASS' if not missing and not mismatches and not changed and not unsafe and
              sorted(axioms) == ['Classical.choice', 'Quot.sound', 'propext'] else 'FAIL',
    'logical_project_roots_requested': len(expected), 'logical_project_roots_found': len(found),
    'explicit_theorems_covered': sum(r['explicit_theorem'] for r in expected.values()),
    'excluded_generated_runtime_declarations': excluded,
    'missing_project_roots': missing, 'kind_mismatches': mismatches,
    'exported_declarations': sum(kinds.values()), 'exported_declaration_kinds': dict(kinds),
    'exported_axioms': sorted(axioms), 'unsafe_or_partial_exported_declarations': unsafe,
    'changed_inputs': changed, 'export_sha256': hasher.hexdigest(),
    'elapsed_seconds': round(time.monotonic() - started, 3),
    'scope': 'Membership, declaration kinds, input identity and axiom inventory; proof typechecking is separate. Generated unsafe/partial runtime implementations are excluded, not claimed verified.'
}
(STATE / 'project-logical-closure-inventory.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: v for k, v in result.items() if k != 'excluded_generated_runtime_declarations'}, indent=2))
raise SystemExit(0 if result['status'] == 'PASS' else 1)
