#!/usr/bin/env bash
# ============================================================
# Gabrielle Taylor — Personal Site Rebuild
# GitHub Issues + Project Board Setup Script
#
# Prerequisites:
#   brew install gh        # install GitHub CLI
#   gh auth login          # authenticate
#
# Usage:
#   cd /path/to/your/repo
#   chmod +x setup_github_project.sh
#   ./setup_github_project.sh
# ============================================================

set -e

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
if [ -z "$REPO" ]; then
  echo "Error: couldn't detect repo. Make sure you're in your git repo directory and logged in with 'gh auth login'."
  exit 1
fi

echo "Setting up project for: $REPO"
echo ""

# ------------------------------------------------------------
# 1. Labels
# ------------------------------------------------------------
echo "Creating labels..."

gh label create "content"  --color "FAC775" --description "Copy, bio, project descriptions, assets" --force
gh label create "design"   --color "9FE1CB" --description "Visual design, tokens, typography" --force
gh label create "build"    --color "B5D4F4" --description "HTML, CSS, JS implementation" --force
gh label create "infra"    --color "D3D1C7" --description "Repo setup, tooling, deployment" --force
gh label create "phase-0"  --color "D3D1C7" --description "Phase 0: Foundation" --force
gh label create "phase-1"  --color "9FE1CB" --description "Phase 1: Core pages" --force
gh label create "phase-2"  --color "FAC775" --description "Phase 2: Work & Making" --force
gh label create "phase-3"  --color "B5D4F4" --description "Phase 3: Polish" --force

echo "Labels created."
echo ""

# ------------------------------------------------------------
# 2. Milestones
# ------------------------------------------------------------
echo "Creating milestones..."

gh api repos/$REPO/milestones \
  -f title="Phase 0: Foundation" \
  -f description="Repo setup, design tokens, bio copy — everything else builds on this" \
  -f state="open" > /dev/null

gh api repos/$REPO/milestones \
  -f title="Phase 1: Core pages" \
  -f description="Home, About, Contact — minimum viable site, shippable on its own" \
  -f state="open" > /dev/null

gh api repos/$REPO/milestones \
  -f title="Phase 2: Work & Making" \
  -f description="Portfolio and hobbies pages" \
  -f state="open" > /dev/null

gh api repos/$REPO/milestones \
  -f title="Phase 3: Polish" \
  -f description="Accessibility audit, responsive QA, SEO basics, final review" \
  -f state="open" > /dev/null

echo "Milestones created."
echo ""

# Helper: get milestone number by title
milestone_number() {
  gh api repos/$REPO/milestones --jq ".[] | select(.title == \"$1\") | .number"
}

M0=$(milestone_number "Phase 0: Foundation")
M1=$(milestone_number "Phase 1: Core pages")
M2=$(milestone_number "Phase 2: Work & Making")
M3=$(milestone_number "Phase 3: Polish")

# ------------------------------------------------------------
# 3. Issues
# ------------------------------------------------------------
echo "Creating issues..."

# --- Phase 0 ---

gh issue create \
  --title "Dev environment setup: install & configure GitHub CLI" \
  --body "## Goal
Set up the GitHub CLI so the project board script and future automation can run locally.

## Steps
- [ ] Install GitHub CLI: \`brew install gh\` (or https://cli.github.com for other platforms)
- [ ] Authenticate: \`gh auth login\`
- [ ] Verify: \`gh repo view\` returns this repo
- [ ] Re-run \`setup_github_project.sh\` to confirm it works end to end

## Notes
This is a one-time setup step. Once done, \`gh\` can be used for creating PRs, checking CI status, etc. from the terminal." \
  --label "infra,phase-0" \
  --milestone "$M0"

gh issue create \
  --title "Set up redesign branch and folder structure" \
  --body "## Goal
Establish the working branch and clean file structure for the rebuild.

## Steps
- [ ] Create branch: \`git checkout -b redesign\`
- [ ] Plan folder structure:
  \`\`\`
  /
  ├── index.html
  ├── about.html (or single-page sections)
  ├── work.html
  ├── making.html
  ├── css/
  │   ├── tokens.css
  │   ├── base.css
  │   └── components.css
  ├── js/
  │   └── main.js
  ├── img/
  └── resume/current.pdf
  \`\`\`
- [ ] Remove Bootstrap, jQuery, Tether dependencies from HTML
- [ ] Commit clean starting point" \
  --label "infra,phase-0" \
  --milestone "$M0"

gh issue create \
  --title "Build CSS design tokens file (tokens.css)" \
  --body "## Goal
Create a single source of truth for all brand colors, fonts, and spacing. Every other CSS file imports this.

## Tokens to define
\`\`\`css
:root {
  /* Cool palette */
  --color-teal-dark:  #075459;
  --color-teal-mid:   #5DCDBF;
  --color-blue-pale:  #C8EBFF;

  /* Warm palette */
  --color-coral:      #E45454;
  --color-terra:      #E8642C;
  --color-berry:      #820649;

  /* Neutrals */
  --color-white:      #ffffff;
  --color-off-white:  #f8f8f8;
  --color-text:       #1a1a1a;
  --color-text-muted: #666666;
  --color-border:     #e7e7e7;

  /* Fonts */
  --font-display: 'Bebas Neue', sans-serif;
  --font-accent:  'Satisfy', cursive;
  --font-body:    'Lato', sans-serif;

  /* Spacing scale */
  --space-xs:  0.25rem;
  --space-sm:  0.5rem;
  --space-md:  1rem;
  --space-lg:  2rem;
  --space-xl:  4rem;

  /* Layout */
  --max-width: 1100px;
  --nav-height: 60px;
}
\`\`\`

## Notes
Source: Gabrielle_Taylor_Brand_Style_Guide_2022.pdf" \
  --label "design,phase-0" \
  --milestone "$M0"

gh issue create \
  --title "Set up base.css: resets, typography defaults, Google Fonts" \
  --body "## Goal
Establish consistent baseline styles across all pages.

## Steps
- [ ] Add Google Fonts import: Lato (300, 400, 700) + Satisfy
- [ ] CSS reset (box-sizing, margin/padding, etc.)
- [ ] Base typography: body, h1–h4, p, a, ul defaults using token variables
- [ ] Utility classes: .container (max-width centered), .sr-only (screen reader)

## Notes
No Bootstrap. Pure CSS using custom properties from tokens.css." \
  --label "design,phase-0" \
  --milestone "$M0"

gh issue create \
  --title "Write updated bio and About copy" \
  --body "## Goal
Replace the stale student bio with a current, on-brand version that reflects your actual career.

## Inputs
- Brand Style Guide bio (page 3) — good starting point, fill in Columbia focus area
- current.pdf resume — use for accuracy on roles, dates, current employer (Gusto)

## Content to produce
- [ ] Short bio (~100 words) — for hero/homepage
- [ ] Full bio (~250 words) — for About page
- [ ] Three brand values blurbs (Creative Exploration / Technical Curiosity / Building Equity) — from brand guide page 11
- [ ] Update email: me@gabriellet.com (remove old columbia address)

## Notes
Check: Columbia focus area 'XX' placeholder needs to be filled in." \
  --label "content,phase-0" \
  --milestone "$M0"

# --- Phase 1 ---

gh issue create \
  --title "Design and build hero / homepage" \
  --body "## Goal
New homepage with brand-aligned hero section. First page visitors see — should immediately communicate who Gabrielle is.

## Design spec
- Banner: use Website Banner 2 (terra cotta) or Banner 1 (teal) as hero background
- Display name in Bebas Neue (or similar display font)
- Tagline in Satisfy: 'Maker. Explorer. Developer.'
- CTA links: About, Work, Resume

## Steps
- [ ] Implement hero section with banner background
- [ ] Display name + tagline typography
- [ ] Social links row (GitHub, LinkedIn, Instagram, Email)
- [ ] Responsive: works at 375px, 768px, 1280px" \
  --label "design,build,phase-1" \
  --milestone "$M1"

gh issue create \
  --title "Build navigation component" \
  --body "## Goal
Fixed top nav, mobile-responsive, no Bootstrap.

## Spec
- Links: About / Work / Making / Resume (external, opens PDF) / Contact
- Fixed to top, slight background blur or solid on scroll
- Mobile: hamburger toggle, pure CSS + minimal JS
- Smooth scroll to sections (vanilla JS, replaces jQuery scroll.js)

## Steps
- [ ] HTML nav structure
- [ ] CSS: fixed top, height from --nav-height token
- [ ] Mobile hamburger (CSS checkbox hack or minimal JS)
- [ ] Smooth scroll: replace scroll.js with native scroll-behavior or ~10 lines of JS
- [ ] Keyboard accessible (focus styles, aria labels)" \
  --label "build,phase-1" \
  --milestone "$M1"

gh issue create \
  --title "Build About page / section" \
  --body "## Goal
Replace the stale student bio sections with a single, current About section.

## Content (from Phase 0 writing task)
- Updated bio copy
- Headshot photo (img/headshot-small.jpg — may need a newer photo)
- Three brand values cards

## Steps
- [ ] Two-column layout: photo + bio text
- [ ] Brand values: three cards with icon/color accent (use brand palette)
- [ ] Responsive stacking on mobile" \
  --label "build,content,phase-1" \
  --milestone "$M1"

gh issue create \
  --title "Build Contact section and update Footer" \
  --body "## Goal
Clean contact links and an updated footer.

## Steps
- [ ] Contact section: me@gabriellet.com, GitHub, LinkedIn, Instagram
- [ ] Remove Twitter if no longer active (check)
- [ ] Footer: updated copyright year (2025), name, nav links
- [ ] Remove all references to old Columbia email" \
  --label "build,phase-1" \
  --milestone "$M1"

# --- Phase 2 ---

gh issue create \
  --title "Write project descriptions for Work / Portfolio page" \
  --body "## Goal
Produce 4–6 project write-ups drawn from the resume for the portfolio page.

## Candidate projects (from current.pdf)
- [ ] Gusto — time-off, kiosk, accessibility workgroup
- [ ] Carbon Five — fintech iOS digital wallet
- [ ] Carbon Five — HIPAA mental health platform (iOS)
- [ ] Carbon Five — React Native cooking device app
- [ ] Carbon Five — CRM platform (React, Next.js, MongoDB)
- [ ] Columbia — Hatespotting (Google Places + Maps)
- [ ] Columbia Senior Project — Sphero robotics path planning

## For each project write:
- Title + employer/context
- 1-sentence summary
- Tech stack tags (2–5 tags)
- 2–3 sentence description
- Link (GitHub or live) if available" \
  --label "content,phase-2" \
  --milestone "$M2"

gh issue create \
  --title "Build Work / Portfolio page" \
  --body "## Goal
A clean portfolio page using CSS Grid project cards. No Bootstrap.

## Steps
- [ ] Project card component: title, context, tech stack tags, description, optional link
- [ ] CSS Grid layout: 1 col mobile, 2 col desktop
- [ ] Tech stack tag styling using brand palette
- [ ] Page header with banner background (Banner 1 teal works well here)" \
  --label "build,phase-2" \
  --milestone "$M2"

gh issue create \
  --title "Gather assets for Making page" \
  --body "## Goal
Collect and prepare all photos and media for the Making / hobbies page.

## Asset checklist
- [ ] Laser-cut jewelry photos (brand guide has some — download originals if higher res available)
- [ ] Crafts / making photos
- [ ] RC airplane photo (img/plane-me.jpg exists — keep?)
- [ ] Music: is Soundcloud profile still active? Confirm link.
- [ ] Gardening / other hobby photos if available

## Notes
Aim for 6–9 photos total. Consistent aspect ratio (square or 4:3) will make the grid much cleaner. Resize/compress for web before committing." \
  --label "content,phase-2" \
  --milestone "$M2"

gh issue create \
  --title "Build Making / Hobbies page" \
  --body "## Goal
A visually engaging page for Gabrielle's creative and hobby work. This is a key differentiator — treat it as a showcase, not an afterthought.

## Suggested sections
- Making: laser-cut jewelry, crafts, 3D/laser work
- Music: oboe, jazz, classical — Soundcloud embed or link
- Outdoors / other: RC planes, birding, gardening

## Steps
- [ ] Photo grid (CSS Grid, consistent aspect ratio, hover effect)
- [ ] Section headers with brand palette accents
- [ ] Soundcloud link / embed
- [ ] Responsive: 1 col mobile, 3 col desktop" \
  --label "build,phase-2" \
  --milestone "$M2"

# --- Phase 3 ---

gh issue create \
  --title "Accessibility audit" \
  --body "## Goal
Ensure the site meets WCAG AA. Given that Gabrielle co-leads an accessibility workgroup, the bar here is high.

## Checklist
- [ ] Run Lighthouse accessibility audit on each page (score ≥ 90)
- [ ] Run axe DevTools browser extension
- [ ] All images have descriptive alt text
- [ ] Color contrast: text on all backgrounds passes 4.5:1 (AA) — especially teal-dark + white, terra cotta + white
- [ ] Keyboard navigation: tab through all interactive elements in logical order
- [ ] Focus styles visible on all focusable elements
- [ ] Nav hamburger operable by keyboard
- [ ] Semantic HTML: proper heading hierarchy (h1 → h2 → h3), landmark regions (nav, main, footer)
- [ ] Links have descriptive text (no bare 'click here')" \
  --label "build,phase-3" \
  --milestone "$M3"

gh issue create \
  --title "Responsive QA across breakpoints" \
  --body "## Goal
Verify layout is solid at all common viewport sizes.

## Breakpoints to test
- [ ] 375px — iPhone SE (smallest common mobile)
- [ ] 430px — iPhone 15 Pro Max
- [ ] 768px — iPad portrait
- [ ] 1024px — iPad landscape / small laptop
- [ ] 1280px — standard desktop
- [ ] 1440px — large desktop

## What to check at each size
- [ ] Nav: hamburger appears/disappears at right breakpoint
- [ ] Hero text: doesn't overflow or wrap awkwardly
- [ ] Photo grids: reflow to fewer columns cleanly
- [ ] Cards: readable at all sizes, no horizontal scroll
- [ ] Footer: stacks correctly on mobile" \
  --label "build,phase-3" \
  --milestone "$M3"

gh issue create \
  --title "SEO basics: meta tags and Open Graph" \
  --body "## Goal
Make sure the site shows up correctly in search results and link previews.

## Steps
- [ ] \`<meta name='description'>\` on each page (1–2 sentence summary)
- [ ] \`<title>\` tags: descriptive and unique per page
- [ ] Open Graph tags: og:title, og:description, og:image (use a headshot or banner)
- [ ] Canonical URL: verify gabrielleataylor.com is canonical (not gabriellet.github.io)
- [ ] robots.txt: confirm not blocking indexing
- [ ] Verify CNAME file is correct for custom domain" \
  --label "build,phase-3" \
  --milestone "$M3"

gh issue create \
  --title "Final content review and launch checklist" \
  --body "## Goal
A final pass before considering the site 'done.'

## Checklist
- [ ] Read every page aloud — does it sound like Gabrielle?
- [ ] All links work (no 404s, no broken anchors)
- [ ] Resume PDF is current
- [ ] No placeholder copy ('Lorem ipsum', 'XX', 'Your Name')
- [ ] Copyright year is correct
- [ ] Social links all go to the right profiles
- [ ] Test contact email link opens mail client correctly
- [ ] Test on a real mobile device (not just browser DevTools)
- [ ] Merge redesign branch to main
- [ ] Verify live site at gabrielleataylor.com after deploy" \
  --label "content,phase-3" \
  --milestone "$M3"

# ------------------------------------------------------------
# 4. Create GitHub Project board
# ------------------------------------------------------------
echo "Creating GitHub Project board..."

PROJECT_URL=$(gh project create \
  --owner "${REPO%%/*}" \
  --title "gabrielleataylor.com redesign" \
  --format json 2>/dev/null | grep -o '"url":"[^"]*"' | cut -d'"' -f4 || echo "")

if [ -n "$PROJECT_URL" ]; then
  echo "Project board created: $PROJECT_URL"
else
  echo "Note: Project board creation requires org-level permissions in some cases."
  echo "Create it manually at: https://github.com/${REPO}/projects"
fi

echo ""
echo "============================================================"
echo "Done! Issues and milestones created for: $REPO"
echo ""
echo "Next steps:"
echo "  1. Go to https://github.com/$REPO/issues to see all issues"
echo "  2. Go to https://github.com/$REPO/milestones to see phases"
echo "  3. Create a Project board and add the issues to it"
echo "  4. Start with Phase 0 — first issue: install GitHub CLI :)"
echo "============================================================"
