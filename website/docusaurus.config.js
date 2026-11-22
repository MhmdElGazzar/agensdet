// Playwright SDET docs site. The content is the repo's docs/ folder; nothing is copied.
// @ts-check

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Playwright SDET',
  tagline: 'Start test automation with Claude, Playwright and Azure Pipelines',
  url: 'https://agentic-testers.github.io',
  baseUrl: '/playwright-sdet/',
  organizationName: 'agentic-testers',
  projectName: 'playwright-sdet',
  trailingSlash: true,
  onBrokenLinks: 'warn',
  // .md files are plain Markdown (our generated blocks use HTML comments, which MDX rejects).
  markdown: { format: 'detect', hooks: { onBrokenMarkdownLinks: 'warn' } },
  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          path: '../docs',
          routeBasePath: '/',
          sidebarPath: require.resolve('./sidebars.js'),
          exclude: ['adr/0000-template.md', 'snapshots/**'],
        },
        blog: false,
        theme: { customCss: require.resolve('./src/css/custom.css') },
      }),
    ],
  ],
  themeConfig: {
    navbar: {
      title: 'Playwright SDET',
      items: [{ href: 'https://github.com/agentic-testers/playwright-sdet', label: 'GitHub', position: 'right' }],
    },
    colorMode: { respectPrefersColorScheme: true },
  },
};

module.exports = config;
