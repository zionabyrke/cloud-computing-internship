# Week 8 - CI/CD with GitHub Actions

**Date Range:** June 29 – July 3, 2026
**Status:** ✅ Done
**Key Deliverable:** Working CI/CD pipeline with automated deployment to GitHub Pages

---

## Overview

Week 8 was GitHub Actions. The module offered a choice between GitHub Actions and Jenkins - GitHub Actions made more sense since the project was already going to live on GitHub and Pages was the deploy target. The pipeline ended up more complete than the module's baseline: real tests using Node's built-in `node:test` instead of an echo, a two-job workflow where deploy only runs if build-and-test passes, and secrets management for an API key.

Two things that weren't in the module: repos created after February 2026 have `GITHUB_TOKEN` set to read-only by default, which broke the Pages deploy until `permissions: contents: write` was added explicitly. The `gh-pages` branch also can't be selected in Pages settings until the deploy job has run at least once and created it.

---

## Tasks

| # | Task | Date | Status |
|---|------|------|--------|
| 1 | Project Creation and Repository Setup | July 2 | ✅ |
| 2 | First CI Trigger Workflow | July 2 | ✅ |
| 3 | Build and Test Automation | July 2 | ✅ |
| 4 | Secrets Management | July 2 | ✅ |
| 5 | Automated Testing and Deployment to GitHub Pages | July 2 | ✅ |
| 6 | Documentation and Status Badge | July 2 | ✅ |

---

## Environment

| | |
|-|-|
| Machine | Local Arch Linux |
| Editor | VS Code |
| Runtime | Node.js 18 |
| CI Platform | GitHub Actions |
| Deploy target | GitHub Pages |

---

## Files

| File | Description |
|------|-------------|
| `README.md` | This file |
| `commands.sh` | Local git and node commands used |
| `setup-notes.md` | Task documentation |
| `cloud-ci-cd-demo/app.js` | Add function |
| `cloud-ci-cd-demo/test/app.test.js` | node:test test file |
| `cloud-ci-cd-demo/package.json` | Node project config |
| `cloud-ci-cd-demo/index.html` | Static page deployed to GitHub Pages |
| `cloud-ci-cd-demo/.github/workflows/main.yml` | Final GitHub Actions workflow |

---

## Live Links

- **Repository:** https://github.com/zionabyrke/cloud-ci-cd-demo
- **Deployed site:** https://zionabyrke.github.io/cloud-ci-cd-demo/

---

## Issues & Resolutions

| Issue | Resolution |
|-------|------------|
| Pages deploy failed with permission denied | `GITHUB_TOKEN` is read-only by default for repos created after Feb 2026 - added `permissions: contents: write` at the workflow level |
| `gh-pages` branch missing from Pages settings dropdown | Branch doesn't exist until the deploy job runs once - ran the workflow first, then configured Pages |
| `npm ci` failed | No `package-lock.json` present - used `npm install` instead |

---

## References

- [GitHub Docs - Automatic Token Authentication](https://docs.github.com/actions/security-guides/automatic-token-authentication)
- [GitHub Docs - Publishing with a Custom GitHub Actions Workflow](https://docs.github.com/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
- [Node.js - Test Runner](https://nodejs.org/api/test.html)
