import fs from 'fs';
import path from 'path';
import { resolve } from 'path';
import { marked } from 'marked';

import { fileURLToPath } from 'url';
const __dirname = path.dirname(fileURLToPath(import.meta.url));

const DOCS_DIR = path.resolve(__dirname, '../../../planifest-docs');
const OUT_DIR = path.resolve(__dirname, '../docs');
const TEMPLATE_FILE = path.resolve(__dirname, '../doc-template.html');

if (!fs.existsSync(OUT_DIR)) {
  fs.mkdirSync(OUT_DIR, { recursive: true });
}

const template = fs.existsSync(TEMPLATE_FILE)
  ? fs.readFileSync(TEMPLATE_FILE, 'utf-8')
  : `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{{TITLE}} - Planifest Docs</title>
    <!-- We reference main CSS here; Vite will resolve and built it -->
    <link rel="stylesheet" href="../src/style.css">
    <script type="module" src="../src/main.ts"></script>
  </head>
  <body>
    <div id="app">
      <nav class="glass-nav">
        <div class="nav-content">
          <a href="../index.html" class="logo">Planifest</a>
          <button id="theme-toggle" class="theme-toggle" aria-label="Toggle theme">
            <svg class="sun-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
            <svg class="moon-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
          </button>
        </div>
      </nav>
      <main class="doc-container glass-panel">
        {{CONTENT}}
      </main>
    </div>
  </body>
</html>`;

const renderer = new marked.Renderer();
renderer.code = function({text, lang, escaped}) {
  if (lang === 'mermaid') {
    return `<pre class="mermaid">${text}</pre>`;
  }
  return `<pre><code class="language-${lang}">${escaped ? text : text}</code></pre>`;
};

marked.use({ renderer });

function stripMetadata(markdown) {
  // Strip lines starting with `> Planifest - ` to remove raw file IDs/redundant doc titles if heavily present
  // Also strip the Version Log table strictly
  const versionLogRegex = /## Version Log[\s\S]*?(?=\n---|\n##)/;
  let cleaned = markdown.replace(versionLogRegex, '');
  
  // Replace .md cross-references with .html references
  cleaned = cleaned.replace(/href="([^"]+)\.md"/g, 'href="$1.html"');
  cleaned = cleaned.replace(/\]\(([^)]+)\.md\)/g, ']($1.html)');
  
  return cleaned;
}

const files = fs.readdirSync(DOCS_DIR).filter(file => file.endsWith('.md'));

files.forEach(file => {
  const mdPath = path.join(DOCS_DIR, file);
  const rawMarkdown = fs.readFileSync(mdPath, 'utf-8');
  const cleanedMarkdown = stripMetadata(rawMarkdown);
  const htmlContent = marked.parse(cleanedMarkdown);

  const titleMatch = cleanedMarkdown.match(/^#\s+(.+)$/m);
  const title = titleMatch ? titleMatch[1] : file.replace('.md', '');

  const finalHtml = template
    .replace('{{TITLE}}', title)
    .replace('{{CONTENT}}', htmlContent);

  const outHtmlPath = path.join(OUT_DIR, file.replace('.md', '.html'));
  fs.writeFileSync(outHtmlPath, finalHtml, 'utf-8');
  console.log(`Generated: ${outHtmlPath}`);
});
