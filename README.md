# Daniel Park's Blog

Personal study log for Reinforcement Learning and Competitive Programming, built with [Jekyll](https://jekyllrb.com/) and the [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) theme.

---

## Running the Site Locally

**Prerequisites**: [rbenv](https://github.com/rbenv/rbenv) and Ruby 3.3.11 must be installed (already done if you set this up with the initial guide). Run once if starting fresh:

```bash
gem install bundler
bundle install
```

**Start the local server:**

```bash
eval "$(rbenv init -)"
RACK_ENV=development bundle exec jekyll serve --no-watch
```

Open `http://localhost:4000` in your browser. Restart the server to pick up any changes.

> - `RACK_ENV=development` is required for the admin panel at `http://localhost:4000/admin`.
> - `--no-watch` is required for the admin's **Create** button to work. With watch mode on, Jekyll skips rebuilding after the admin writes a new file, so the post can't be found and you get "could not update the doc".

---

## Writing a New Post

### Via the admin panel (recommended)

With the server running, open `http://localhost:4000/admin` in your browser.

1. Click **Posts** in the left sidebar, then click **New Post**.
2. Fill in the title, date, and body using the editor.
3. Set **categories** and **tags** in the front matter fields on the right. Use the category reference below.
4. Click **Save** — the post file is created automatically in `_posts/`.
5. Commit and push to deploy.

> The admin panel is only available locally. It is not published to GitHub Pages.

### Category reference

| Category (top-level) | Sub-category | Use for |
|---|---|---|
| Reinforcement Learning | Concepts | Core RL theory notes |
| Reinforcement Learning | Paper Review | Paper summaries |
| Reinforcement Learning | TIL | Short daily notes |
| Competitive Programming | Algorithm | Algorithm concepts |
| Competitive Programming | Problem Solving | Individual problem write-ups |
| Competitive Programming | TIL | Short daily notes |

### Alternative: create the file manually

Create a file in `_posts/` named exactly `YYYY-MM-DD-your-post-title.md` and add front matter at the top:

**Reinforcement Learning post:**
```markdown
---
title: "What is Policy Gradient?"
date: 2026-06-16 00:00:00 +0900
categories: [Reinforcement Learning, Concepts]
tags: [policy-gradient, beginner]
---
```

**Competitive Programming post:**
```markdown
---
title: "BOJ 1234 - Problem Name"
date: 2026-06-16 00:00:00 +0900
categories: [Competitive Programming, Problem Solving]
tags: [dp, boj]
---
```

Write your content in Markdown below the front matter, then commit and push to deploy.

### Post status

Every post has a `status` field, set automatically to `draft` when created. It must be one of:

| Status | Meaning |
|---|---|
| `draft` | Just created, not yet written |
| `in progress` | Currently being written, not finished |
| `completed` | Finished and ready to publish |

Only posts with `status: completed` are shown when the site is deployed (built with `JEKYLL_ENV=production`). `draft` and `in progress` posts are visible locally so you can preview them while writing.

A build-time check rejects any other value for `status` (e.g. a typo like `compelted`) with an error telling you which post and which value is invalid.

### Inserting and sizing images

Place image files in `assets/img/posts/<your-post-slug>/` and embed them with a Liquid path so relative URLs work on both local and deployed builds:

```markdown
![]({{ 'assets/img/posts/DUSDi/my-figure.png' | relative_url }})
```

This renders the image at its natural size (up to the content column width). To control the size, append a Kramdown inline-attribute block `{: ...}` immediately after the closing `)` — no space:

**Fixed pixel width** (height scales automatically to preserve aspect ratio):
```markdown
![]({{ 'assets/img/posts/DUSDi/my-figure.png' | relative_url }}){: width="400"}
```

**Percentage of the content column width:**
```markdown
![]({{ 'assets/img/posts/DUSDi/my-figure.png' | relative_url }}){: style="width: 60%"}
```

**Both width and height** (can distort the image if the ratio doesn't match):
```markdown
![]({{ 'assets/img/posts/DUSDi/my-figure.png' | relative_url }}){: width="400" height="300"}
```

**Centering** — add `style="display:block; margin:auto;"` to the same attribute block. You can combine it with a width in one go:
```markdown
![]({{ 'assets/img/posts/DUSDi/my-figure.png' | relative_url }}){: width="400" style="display:block; margin:auto;"}
```

If you just want to center without fixing the width (image fills the column but is centered):
```markdown
![]({{ 'assets/img/posts/DUSDi/my-figure.png' | relative_url }}){: style="display:block; margin:auto;"}
```

If you need more control (e.g. a caption, or complex layout), use a raw `<img>` tag instead — Kramdown passes HTML through unchanged:

```html
<img src="{{ 'assets/img/posts/DUSDi/my-figure.png' | relative_url }}" width="400" alt="Figure 1" style="display:block; margin:auto;">
```

> Liquid processes the `{{ ... | relative_url }}` part first, then Kramdown parses the resulting Markdown (including the `{: ...}` attributes), so this syntax works exactly as it looks.

### Things to watch for when writing a post

- **Screenshot filenames from macOS are a trap.** macOS inserts an invisible *narrow no-break space* (U+202F, not a regular space) between the time and AM/PM in screenshot filenames, e.g. `Screenshot 2026-06-17 at 5.32.06 PM.png`. It's indistinguishable from a normal space when you look at it, but if you ever retype that filename in a Markdown image link — instead of letting it autocomplete or copy-pasting it — your keyboard produces a *regular* space, and the link silently stops matching the real file (no build error, the image just doesn't show). This bit `_posts/2026-06-17-DUSDi-kor.md` twice in this project. Safest fix: rename screenshot files yourself before adding them — replace the space before AM/PM with a regular one (or strip spaces entirely) — so there's no invisible character left to mismatch.
- **Headings don't leak into previews, but the paragraph right after one does.** The home page cards and search index strip out heading text (`## Summary` etc. won't show up glued to the next sentence), but whatever text immediately follows your first heading becomes the actual preview/excerpt readers see — write that opening paragraph with that in mind.
- **`status` gates visibility** (see above) — a post won't appear on the deployed site until it's `completed`.
- **Categories and tags are always plain English strings** in front matter, even on Korean posts — see "Translating category/tag names" below for how their *displayed* Korean names work without touching post front matter.

### Site language structure (`/en/` and `/ko/`)

The whole site is split by language in the URL:

- Posts live at `/en/posts/<ref>/` or `/ko/posts/<ref>/` (e.g. `/en/posts/DUSDi/`, `/ko/posts/DUSDi/`) — same slug, different language prefix.
- The home page (post listing) exists twice: `/en/` and `/ko/`.
- The bare `/` is not a real page — it's a small redirect script. It sends visitors to `/ko/` if they previously clicked **KO** on this site (remembered via `localStorage`) or their browser is set to Korean; otherwise to `/en/`.
- Tabs (About, Archives, Categories, Tags) are also split: `/en/about/`, `/ko/about/`, `/en/archives/`, `/ko/archives/`, etc. The Korean tab pages show the same content as the English ones (About isn't actually translated) — only the surrounding UI chrome (labels, breadcrumb) is localized.
- Individual category/tag pages (e.g. `/en/categories/reinforcement-learning/`, `/ko/tags/dp/`) are split too — generated bilingually by `_plugins/lang_archives.rb` instead of the `jekyll-archives` gem, since that gem only supports one global URL per archive. On the Korean version, any post that has a Korean translation links to that translation instead of the English post.

A small **EN / KO** toggle button lives in the top bar on every page. On a post with a translation, it jumps straight to that translation; on the home page, it jumps between `/en/` and `/ko/`. Clicking it also updates the remembered preference used by the `/` redirect.

### Korean translations (EN/KO toggle)

Every post is written in English by default. To add a Korean translation:

1. Write the English post first (e.g. `_posts/2026-06-17-DUSDi.md`). It auto-gets a `ref` field (defaults to its slug, e.g. `ref: DUSDi`) and a `permalink: /en/posts/DUSDi/` — both injected automatically on the next build by `_plugins/auto_front_matter.rb`.
2. Create a second post file for the Korean version (e.g. `_posts/2026-06-17-DUSDi-kor.md`) with:
   ```yaml
   ---
   title: "DUSDi (분리된 비지도 스킬 발견)"
   lang: ko-KR
   ref: DUSDi   # must match the English post's ref exactly
   ---
   ```
3. Write the Korean body content below the front matter.

On the next build, the Korean post auto-gets `permalink: /ko/posts/DUSDi/` (same `ref` slug, `ko` prefix instead of `en` — that pairing is exactly what makes the EN/KO toggle find it). Setting `lang: ko-KR` also switches Chirpy's own UI text (e.g. "Posted:", "Table of Contents") to Korean automatically — this is a built-in Chirpy feature, not something this site adds.

The two posts are independent files — content isn't synced automatically, so edit each language separately. If you ever need to override the generated permalink, just set `permalink:` yourself in the front matter — the generator only fills it in when it's missing.

### Prompt for translating a post to Korean

When asking for a Korean translation of an existing post, a prompt along these lines has produced results consistent with the rest of the site:

> Translate `_posts/<date>-<slug>.md` into Korean and save it as `_posts/<date>-<slug>-kor.md`, with `lang: ko-KR` and the same `ref: <slug>` as the English post. Use formal, polite Korean (하십시오체 — statements ending in `-습니다`/`-입니다`, questions in `-일까요?`), not casual speech. Don't convert every `-다` you see: leave conditional forms (`-다면`, "if...") and embedded quotative forms (`-다는`, "...that...") alone — only the ones that actually end a sentence change. Keep all Markdown formatting, LaTeX math (`$...$`, `$$...$$`), image embeds, and links exactly as in the English version — translate prose only, nothing else. Keep `categories:`/`tags:` in English (see "Translating category/tag names" below if you also want their displayed Korean names). Keep the front matter `title:` in English exactly as it appears — do not translate it. Keep all headings (`##`, `###`, etc.) in English exactly as they appear — do not translate them. Keep technical jargon in English as-is within the Korean prose (e.g. oracle policy, student policy, policy distillation, command space, reward, penalty, regularization, proprioception state, goal state, DAgger, PPO, masking, dataset, baseline, tracking error, embodiment).

`_posts/2026-06-17-DUSDi-kor.md` is a worked example of this — both the initial translation and a later pass to make every sentence ending consistently formal.

### Translating category/tag names

Write categories and tags in posts exactly as before — plain English strings, e.g. `categories: [Reinforcement Learning]`. Don't write both languages in a post's front matter; that would mean retyping (and risking a typo in) the same Korean translation on every post that reuses a category.

Instead, add the Korean name once to `_data/term_translations.yml`:

```yaml
categories:
  Reinforcement Learning: 강화학습
tags:
  disentanglement: 분리
```

This affects only what's *displayed* on `/ko/` pages (category/tag pages, post footer badges, the trending-tags panel, search) — the URL slug is always derived from the English term, so `/ko/categories/reinforcement-learning/` stays the same and still pairs with its `/en/` counterpart via the language toggle. Anything not listed here just shows the English term untranslated on `/ko/` pages too, so forgetting to add a new term doesn't break anything — it's just not translated yet.

---

## Updating the Site

### Config or layout changes

Edit `_config.yml` (title, timezone, social links, etc.) or any `_tabs/*.md` file (About page, etc.), then restart the local server to see changes. For deployment, commit and push:

```bash
git add <changed-files>
git commit -m "describe your change"
git push origin main
```

GitHub Actions will rebuild and redeploy automatically.

### Updating the About page

The About page content lives in `_tabs/about.md` — edit the Markdown below the front matter and that updates `/en/about/`.

There's also `_tabs/about-kor.md`, which serves `/ko/about/` — a real Korean translation, not a mirror of the English text. The two files are independent and nothing keeps them in sync automatically, so when you update `about.md`, update the translation in `about-kor.md` too (or ask for help translating it).

### Updating fonts or accent color

Custom styles are in `assets/css/jekyll-theme-chirpy.scss`. The section below the `@use 'main...'` line is yours to edit — current customizations are Inter (body font), JetBrains Mono (code font), and indigo `#6366f1` (link/accent color).

### Adding or changing the photo

The profile photo lives in the left sidebar, just below the site title (`_includes/sidebar.html`, rendered via the `.sidebar-avatar` class — a small circle, ~6.5–7rem depending on screen width).

1. Save your photo at the path set by `avatar:` in `_config.yml` (currently `assets/img/profile.png`), overwriting it if you're replacing an existing one. A square image works best — `object-fit: cover` crops non-square photos to a circle, currently nudged slightly below dead-center via `object-position` in `assets/css/jekyll-theme-chirpy.scss` to keep faces framed properly.
2. Using a different filename or format? Update the `avatar:` line in `_config.yml` to match — the sidebar references it via `{{ site.avatar | relative_url }}`.
3. Restart the local server and check any page — the sidebar is shared across the whole site.

### Visitor counter (GoatCounter)

The right-hand panel can show a "Today" / "This week" visitor count, powered by [GoatCounter](https://www.goatcounter.com) (free). It's currently **off** — `_includes/visitor-count.html` only renders once both config values below are filled in, so leaving them blank is a safe no-op.

**Setup:**

1. Create a free account at [goatcounter.com](https://www.goatcounter.com) and create a site. Note the site code (the part before `.goatcounter.com` in the URL it gives you).
2. In `_config.yml`, set:
   ```yaml
   analytics:
     goatcounter:
       id: your-site-code
   ```
   This alone turns on basic pageview tracking (Chirpy's built-in `analytics/goatcounter.html` snippet) and the existing per-post pageview count — both only load when `JEKYLL_ENV=production`, so you won't see tracking hits while developing locally.
3. In GoatCounter, click your **username in the top menu → API** (not Settings), create a new token, and check only **Read statistics** (leave Record pageviews, Export, and the Sites permissions unchecked). This token ends up in the page's HTML source since the site is fully static with no backend — scoping it to read-only stats is what makes that acceptable.
4. Paste the token into `_config.yml`:
   ```yaml
   goatcounter_api_token: your-token-here
   ```
5. Commit and push (or rebuild locally) — the widget now calls GoatCounter's Stats API directly from the browser to show today's and this week's visitor counts.

**Testing it:**

- Locally: fill in both config values, run `bundle exec jekyll serve`, and open the home page. The widget should appear in the right panel under "Visitors" and fill in real numbers within a second or two (open the browser console if it stays stuck at "–" — a 401 means the token is wrong/missing scope, a CORS or network error means the site code is wrong).
- To confirm it's really hidden when unconfigured: blank out either `analytics.goatcounter.id` or `goatcounter_api_token`, rebuild, and check the widget doesn't render at all (no broken/empty box) — `grep -c "visitor-count" _site/en/index.html` should print `0`.
- After deploying, visit the live site once or twice, wait a minute, then reload — "Today" should reflect those visits (GoatCounter counts itself within seconds, but a stale browser cache of the page can delay what you see).

---

## Deploying to GitHub Pages

The site deploys automatically via GitHub Actions whenever you push to `main`. Make sure the repository is named `danielredglasses.github.io` and Pages is set to use **GitHub Actions** as the source (Settings → Pages).
