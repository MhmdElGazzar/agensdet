#!/usr/bin/env node
// Syncs the features in registry.json to the GitHub Project board.
// registry.json stays the source; the board is a view of it. Edit the registry, then run:
//
//   node scripts/project-sync.mjs
//
// Needs the GitHub CLI (gh) and a classic token with the `project` and `repo` scopes,
// taken from PROJECT_TOKEN, or from CLASSIC_GH_TOKEN in .env. The token is never printed.
//
// Per feature it keeps one issue (label `feature`, title "<id> <name>") and sets the board fields:
//   Status   the current stage: Backlog (nothing started), Problem … Release, or Ready
//   State    Not started / Draft for the current stage; Approved when Ready
//   Release, Component (the feature's type), Journey (the journey stage that uses it), Problems

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const OWNER = 'agentic-testers';
const REPO = 'playwright-sdet';
const TITLE = 'Playwright SDET';
const SITE = `https://${OWNER}.github.io/${REPO}`;
const STAGES = ['problem', 'workflow', 'design', 'spec', 'evals', 'build', 'release'];
const cap = (s) => s[0].toUpperCase() + s.slice(1);

function token() {
  if (process.env.PROJECT_TOKEN) return process.env.PROJECT_TOKEN;
  const env = path.join(ROOT, '.env');
  const line = fs.existsSync(env) && fs.readFileSync(env, 'utf8').split('\n').find((l) => l.startsWith('CLASSIC_GH_TOKEN='));
  if (!line) throw new Error('No token: set PROJECT_TOKEN or CLASSIC_GH_TOKEN in .env');
  return line.slice(line.indexOf('=') + 1).trim().replace(/^["']|["']$/g, '');
}
const ENV = { ...process.env, GH_TOKEN: token() };

function gh(args, input) {
  return execFileSync('gh', args, { env: ENV, input, encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] });
}
function gql(query, variables = {}) {
  const res = JSON.parse(gh(['api', 'graphql', '--input', '-'], JSON.stringify({ query, variables })));
  if (res.errors) throw new Error(res.errors.map((e) => e.message).join('; '));
  return res.data;
}

// ---- what the board should show, from the registry ----
const reg = JSON.parse(fs.readFileSync(path.join(ROOT, 'registry.json'), 'utf8'));
const journey = reg.workflows?.[0]?.stages ?? [];
const journeyOf = (id) => journey.find((s) => s.steps.some((st) => st.feature === id))?.name ?? '';

function current(f) {
  const st = f.stages ?? {};
  if (!Object.keys(st).length) return { status: 'Backlog', state: 'Not started' };
  const next = STAGES.find((s) => !String(st[s] ?? '').startsWith('approved'));
  if (!next) return { status: 'Ready', state: 'Approved' };
  return { status: cap(next), state: st[next] === 'draft' ? 'Draft' : 'Not started' };
}

function summary(f) {
  const doc = f.doc && path.join(ROOT, f.doc);
  const line = doc && fs.existsSync(doc) && fs.readFileSync(doc, 'utf8').split('\n').find((l) => l.startsWith('> '));
  return line ? line.slice(2).trim() : '';
}

function body(f) {
  const steps = journey.flatMap((s) => s.steps).filter((st) => st.feature === f.id).map((st) => st.step);
  const links = f.doc
    ? [`- Doc: https://github.com/${OWNER}/${REPO}/blob/main/${f.doc}`, `- Site: ${SITE}/features/${path.basename(path.dirname(f.doc))}/`]
    : ['No doc yet; the Problem stage creates it.'];
  return [
    summary(f),
    steps.length ? `Journey steps: ${steps.join(', ')}.` : '',
    '',
    ...links,
    '',
    'The board fields come from `registry.json` (`node scripts/project-sync.mjs`). Change the registry, not the board.',
  ].join('\n');
}

const COLORS = ['GRAY', 'BLUE', 'GREEN', 'YELLOW', 'ORANGE', 'RED', 'PINK', 'PURPLE'];
const order = (vals, known) => [...new Set([...known.filter((k) => vals.includes(k)), ...vals])];
const FIELDS = {
  Status: { options: ['Backlog', ...STAGES.map(cap), 'Ready'], colors: ['GRAY', 'BLUE', 'BLUE', 'PURPLE', 'PURPLE', 'YELLOW', 'ORANGE', 'ORANGE', 'GREEN'] },
  State: { options: ['Not started', 'Draft', 'Approved'], colors: ['GRAY', 'YELLOW', 'GREEN'] },
  Release: { options: order(reg.features.map((f) => f.release ?? 'TBD'), ['v0.1', 'v0.2', 'v1.0', 'TBD']) },
  Component: { options: order(reg.features.map((f) => f.type ?? 'TBD'), ['command', 'skill', 'agent', 'hook', 'mcp', 'TBD']) },
  Journey: { options: [...new Set(reg.features.map((f) => journeyOf(f.id)).filter(Boolean))].sort((a, b) => journey.findIndex((s) => s.name === a) - journey.findIndex((s) => s.name === b)) },
};
const TEXT_FIELDS = ['Problems'];

// ---- GitHub side ----
const { organization: org, repository: repo } = gql(
  `query($o:String!,$r:String!){ organization(login:$o){ id projectsV2(first:50){ nodes{ id number title url } } } repository(owner:$o,name:$r){ id } }`,
  { o: OWNER, r: REPO });

let project = org.projectsV2.nodes.find((p) => p.title === TITLE);
if (!project) {
  project = gql(`mutation($o:ID!,$t:String!,$r:ID!){ createProjectV2(input:{ownerId:$o,title:$t,repositoryId:$r}){ projectV2{ id number title url } } }`,
    { o: org.id, t: TITLE, r: repo.id }).createProjectV2.projectV2;
  gql(`mutation($p:ID!){ updateProjectV2(input:{projectId:$p, public:true, shortDescription:"Feature stages of Playwright SDET, synced from registry.json"}){ projectV2{ id } } }`, { p: project.id });
  console.log(`Created project ${project.url}`);
}

const FIELDS_Q = `query($p:ID!){ node(id:$p){ ... on ProjectV2 {
  fields(first:50){ nodes{ ... on ProjectV2FieldCommon{ id name dataType } ... on ProjectV2SingleSelectField{ options{ id name } } } }
  views(first:20){ nodes{ id name layout } } } } }`;
let meta = gql(FIELDS_Q, { p: project.id }).node;
const field = (name) => meta.fields.nodes.find((f) => f.name === name);

for (const [name, spec] of Object.entries(FIELDS)) {
  const opts = spec.options.map((n, i) => ({ name: n, color: spec.colors?.[i] ?? COLORS[i % COLORS.length], description: '' }));
  const f = field(name);
  if (!f) {
    gql(`mutation($p:ID!,$n:String!,$o:[ProjectV2SingleSelectFieldOptionInput!]){ createProjectV2Field(input:{projectId:$p,dataType:SINGLE_SELECT,name:$n,singleSelectOptions:$o}){ clientMutationId } }`,
      { p: project.id, n: name, o: opts });
  } else if (f.options.map((o) => o.name).join('|') !== spec.options.join('|')) {
    const keep = opts.map((o) => ({ ...o, ...(f.options.find((x) => x.name === o.name) ? { id: f.options.find((x) => x.name === o.name).id } : {}) }));
    gql(`mutation($f:ID!,$o:[ProjectV2SingleSelectFieldOptionInput!]){ updateProjectV2Field(input:{fieldId:$f,singleSelectOptions:$o}){ clientMutationId } }`,
      { f: f.id, o: keep });
  }
}
for (const name of TEXT_FIELDS) {
  if (!field(name)) gql(`mutation($p:ID!,$n:String!){ createProjectV2Field(input:{projectId:$p,dataType:TEXT,name:$n}){ clientMutationId } }`, { p: project.id, n: name });
}
meta = gql(FIELDS_Q, { p: project.id }).node;

// Views: a board (columns = Status) and the default table.
if (!meta.views.nodes.some((v) => v.layout === 'BOARD_LAYOUT')) {
  gql(`mutation($p:ID!){ createProjectV2View(input:{projectId:$p,name:"Board",layout:BOARD_LAYOUT}){ clientMutationId } }`, { p: project.id });
}
const table = meta.views.nodes.find((v) => v.layout === 'TABLE_LAYOUT' && v.name === 'View 1');
if (table) gql(`mutation($v:ID!){ updateProjectV2View(input:{viewId:$v,name:"Table"}){ clientMutationId } }`, { v: table.id });

// Issues: one per feature.
try { gh(['label', 'create', 'feature', '--repo', `${OWNER}/${REPO}`, '--color', '1D76DB', '--description', 'A Playwright SDET feature; fields synced from registry.json']); } catch { /* exists */ }
const issues = JSON.parse(gh(['issue', 'list', '--repo', `${OWNER}/${REPO}`, '--label', 'feature', '--state', 'all', '--limit', '200', '--json', 'number,title,state,id,body']));

for (const f of reg.features) {
  const title = `${f.id} ${f.name}`;
  let issue = issues.find((i) => i.title.split(' ')[0] === f.id);
  if (!issue) {
    const url = gh(['issue', 'create', '--repo', `${OWNER}/${REPO}`, '--title', title, '--label', 'feature', '--body-file', '-'], body(f)).trim();
    issue = JSON.parse(gh(['issue', 'view', url, '--json', 'number,title,state,id,body']));
    console.log(`Created issue #${issue.number} ${title}`);
  } else if (issue.title !== title || issue.body.trim() !== body(f).trim()) {
    gh(['issue', 'edit', String(issue.number), '--repo', `${OWNER}/${REPO}`, '--title', title, '--body-file', '-'], body(f));
  }

  const item = gql(`mutation($p:ID!,$c:ID!){ addProjectV2ItemById(input:{projectId:$p,contentId:$c}){ item{ id } } }`, { p: project.id, c: issue.id }).addProjectV2ItemById.item.id;
  const { status, state } = current(f);
  const values = { Status: status, State: state, Release: f.release ?? 'TBD', Component: f.type ?? 'TBD', Journey: journeyOf(f.id) };
  for (const [name, val] of Object.entries(values)) {
    const fl = field(name);
    if (!val) { gql(`mutation($p:ID!,$i:ID!,$f:ID!){ clearProjectV2ItemFieldValue(input:{projectId:$p,itemId:$i,fieldId:$f}){ clientMutationId } }`, { p: project.id, i: item, f: fl.id }); continue; }
    const opt = fl.options.find((o) => o.name === val).id;
    gql(`mutation($p:ID!,$i:ID!,$f:ID!,$o:String!){ updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$i,fieldId:$f,value:{singleSelectOptionId:$o}}){ clientMutationId } }`,
      { p: project.id, i: item, f: fl.id, o: opt });
  }
  gql(`mutation($p:ID!,$i:ID!,$f:ID!,$t:String!){ updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$i,fieldId:$f,value:{text:$t}}){ clientMutationId } }`,
    { p: project.id, i: item, f: field('Problems').id, t: (f.problems ?? []).join(', ') });

  const ready = status === 'Ready';
  if (ready && issue.state === 'OPEN') gh(['issue', 'close', String(issue.number), '--repo', `${OWNER}/${REPO}`, '--reason', 'completed']);
  if (!ready && issue.state === 'CLOSED') gh(['issue', 'reopen', String(issue.number), '--repo', `${OWNER}/${REPO}`]);
  console.log(`${f.id.padEnd(6)} #${String(issue.number).padEnd(4)} ${status} (${state})`);
}
console.log(`Board: ${project.url}`);
