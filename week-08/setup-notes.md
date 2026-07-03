# Week 8 Setup Notes - CI/CD with GitHub Actions

**Intern:** Renz Kirby Onia
**Date Range:** June 29 – July 3, 2026
**Environment:** Local Arch Linux | VS Code | Node.js 18 | GitHub Actions

---

## Task 1 - Project Creation and Repository Setup

**July 2, 2026**

Initialized the repo locally rather than cloning an empty one from GitHub

```bash
mkdir cloud-ci-cd-demo && cd cloud-ci-cd-demo
code .
git init
```

Wrote four files:

- `app.js` - exports a simple `add(a, b)` function
- `test/app.test.js` - tests `add()` using Node's built-in `node:test`
- `package.json` - sets `"test": "node --test"` as the test script
- `index.html` - static page for the Pages deploy later

```bash
node --test
```

1 test passed locally before touching any CI config. Pushed to GitHub as `cloud-ci-cd-demo` on the `master` branch.

---

## Task 2 - First CI Trigger Workflow

**July 2, 2026**

Created `.github/workflows/main.yml` with just a checkout step and a placeholder run to verify the trigger fired before building out the real steps. Pushed to `master` and checked the Actions tab - green check confirmed the workflow ran.

---

## Task 3 - Build and Test Automation

**July 2, 2026**

Extended the workflow to set up Node 18, install dependencies, and run the actual test suite.

`npm ci` was the first instinct but it requires a `package-lock.json` that didn't exist. Used `npm install` instead.

The Actions log showed `node:test` executing and the `add()` assertion passing - not just an echo, a real test run.

---

## Task 4 - Secrets Management

**July 2, 2026**

Added a repo secret via **GitHub → Settings → Secrets and variables → Actions → New repository secret**, named `API_KEY` with a placeholder value.

Referenced it in a workflow step using `env:`:

```yaml
- name: Check secret
  env:
    API_KEY: ${{ secrets.API_KEY }}
  run: |
    if [ -n "$API_KEY" ]; then
      echo "Secret is present and stored safely"
    fi
```

The log printed the message but never the value - GitHub Actions masks secret values in logs automatically.

---

## Task 5 - Automated Testing and Deployment to GitHub Pages

**July 2, 2026**

Split the workflow into two jobs: `build-and-test` and `deploy`. The deploy job has `needs: build-and-test`, so it only runs if tests pass.

Two things that weren't obvious:

**`GITHUB_TOKEN` is read-only by default** for repos created after February 2026. The `peaceiris/actions-gh-pages` action needs write access to push to the `gh-pages` branch. Fixed by adding at the top of the workflow file:

```yaml
permissions:
  contents: write
```

**The `gh-pages` branch doesn't exist yet.** GitHub Pages settings can't point at a branch that doesn't exist, so there's a chicken-and-egg problem on first setup. The fix: let the deploy job run once first, then go into Settings → Pages and select the `gh-pages` branch.

Used `peaceiris/actions-gh-pages@v4` (not v3 as in the module - v4 is current):

```yaml
- uses: peaceiris/actions-gh-pages@v4
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./
```

Live site confirmed at https://zionabyrke.github.io/cloud-ci-cd-demo/

---

## Task 6 - Documentation and Status Badge

**July 2, 2026**

Added the workflow badge to `README.md`:

```markdown
![CI Status](https://github.com/zionabyrke/cloud-ci-cd-demo/actions/workflows/main.yml/badge.svg)
```

Badge shows passing status on the repo's main page after push.
