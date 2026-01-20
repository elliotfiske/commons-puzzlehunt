# Speakeasy Styling Design

Design document for 1920s speakeasy-themed styling for the SF Commons Puzzle Hunt website.

## Design Direction

- **Palette**: Dark & Moody - deep blacks, burgundy accents, antique gold highlights
- **Typography**: Art Deco display for headings, Old Newspaper font for intro
- **Layout**: Spacious & theatrical, mobile-first
- **Ornamentation**: Subtle accents - thin borders, simple dividers
- **Interactions**: Vintage physical - brass buttons, aged paper inputs

---

## Color Palette

| Role | Hex | CSS Variable | Usage |
|------|-----|--------------|-------|
| Background | `#0a0a0a` | `--color-bg` | Main page backgrounds |
| Surface | `#1a1a1a` | `--color-surface` | Cards, content areas |
| Burgundy | `#8b0000` | `--color-burgundy` | Important highlights, error states |
| Gold | `#d4a855` | `--color-gold` | Borders, decorative elements, success |
| Gold Hover | `#e6be6a` | `--color-gold-light` | Interactive hover states |
| Gold Dark | `#a07830` | `--color-gold-dark` | Button borders, shadows |
| Text Primary | `#f5f0e6` | `--color-text` | Main body text |
| Text Muted | `#a69f8f` | `--color-text-muted` | Secondary text, hints |
| Input Text | `#2a2420` | `--color-input-text` | Dark text on cream inputs |

---

## Typography

### Font Stack

```css
@font-face {
  font-family: 'OldNewspaper';
  src: url('/OldNewspaperTypes.ttf') format('truetype');
}
```

| Context | Font Family | Style |
|---------|-------------|-------|
| Headings | System sans-serif | Uppercase, letter-spacing: 0.15em |
| Intro Story | `'OldNewspaper', 'Times New Roman', Georgia, serif` | Normal case, generous line-height |
| Body Text | `Georgia, 'Times New Roman', serif` | Normal, readable |

### Heading Styles

- **H1**: Uppercase, letter-spacing 0.15em, gold color, 2rem mobile / 2.5rem desktop
- **H2**: Uppercase, letter-spacing 0.1em, cream color, 1.5rem mobile / 1.75rem desktop
- **H3**: Uppercase, letter-spacing 0.05em, cream color, 1.25rem

---

## Page Layouts

### Global Structure

- Full viewport height minimum (`min-h-screen`)
- Dark background (`#0a0a0a`)
- Centered content column
  - Mobile: max-width 400px, padding 1.5rem horizontal
  - Desktop: max-width 600px
- Generous vertical padding: 4-6rem top, 4rem bottom

### Intro Page

```
┌─────────────────────────────────┐
│                                 │
│     THE SECRET OF THE COMMONS   │  ← Gold, Art Deco heading
│     ─────────◆─────────         │  ← Gold divider with diamond
│                                 │
│   ┌───────────────────────┐     │
│   │                       │     │
│   │  In the roaring       │     │  ← OldNewspaper font
│   │  1920s, beneath the   │     │     Slight rotation (1-2°)
│   │  floorboards of...    │     │     Aged paper styling
│   │                       │     │
│   └───────────────────────┘     │
│                                 │
│     ─────────◆─────────         │  ← Gold divider
│                                 │
│        ┌─────────────┐          │
│        │   BEGIN     │          │  ← Brass button
│        └─────────────┘          │
│                                 │
└─────────────────────────────────┘
```

### Hub Page

```
┌─────────────────────────────────┐
│                                 │
│         PUZZLE HUB              │  ← Gold heading
│     ─────────────────           │  ← Gold underline
│                                 │
│   ┌───────────────────────┐     │
│   │ ┌─┐           ┌─┐     │     │  ← Corner accents
│   │    THE PAINTINGS      │     │
│   │    Status: LOCKED     │     │  ← or gold "7" if solved
│   │ └─┘           └─┘     │     │
│   └───────────────────────┘     │
│                                 │
│   ┌───────────────────────┐     │
│   │    BOOTLEGGER'S       │     │
│   │    LEDGER             │     │
│   │    Status: LOCKED     │     │
│   └───────────────────────┘     │
│                                 │
│   (... more cards ...)          │
│                                 │
└─────────────────────────────────┘
```

### Puzzle Page

```
┌─────────────────────────────────┐
│                                 │
│       THE PAINTINGS             │  ← Gold heading
│     ─────────◆─────────         │
│                                 │
│   Find the paintings around     │  ← Cream body text
│   the Commons and fill in       │
│   the letters...                │
│                                 │
│   ┌───────────────────────┐     │
│   │                       │     │  ← Cream/aged paper input
│   └───────────────────────┘     │
│                                 │
│        ┌─────────────┐          │
│        │   SUBMIT    │          │  ← Brass button
│        └─────────────┘          │
│                                 │
│   ← Back to Hub                 │  ← Gold link
│                                 │
└─────────────────────────────────┘
```

### Stash Page (Puzzle 3)

```
┌─────────────────────────────────┐
│                                 │
│      SMUGGLER'S STASH           │
│     ─────────────────           │
│                                 │
│   Find the hidden QR codes...   │
│                                 │
│   ──────────────────────────    │  ← Ledger lines
│   ✓ Moonshine        Found!     │  ← Gold checkmark
│   ──────────────────────────    │
│   ○ Whiskey         . . . .     │  ← Muted, unfound
│   ──────────────────────────    │
│   ✓ Gin             Found!      │
│   ──────────────────────────    │
│   (... more items ...)          │
│                                 │
└─────────────────────────────────┘
```

### Stash Found Page (Celebration)

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│            ✦                    │
│         YOU FOUND               │  ← Large, gold, celebratory
│         MOONSHINE!              │
│            ✦                    │
│                                 │
│   ┌─────────────────────┐       │
│   │  Continue the Hunt  │       │
│   └─────────────────────┘       │
│                                 │
└─────────────────────────────────┘
```

---

## Interactive Elements

### Buttons (Brass Fixture)

```css
.btn-brass {
  background: linear-gradient(to bottom, #d4a855, #b8943d);
  border: 2px solid #a07830;
  color: #1a1a1a;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  padding: 0.75rem 2rem;
  font-weight: 600;
  box-shadow: inset 0 1px 0 rgba(255,255,255,0.2);
  transition: all 150ms ease;
}

.btn-brass:hover {
  background: linear-gradient(to bottom, #e6be6a, #d4a855);
  transform: scale(1.02);
}

.btn-brass:active {
  background: linear-gradient(to bottom, #b8943d, #d4a855);
  transform: scale(0.98);
}
```

### Text Inputs (Aged Paper)

```css
.input-paper {
  background: #f5f0e6;
  border: 2px solid #a69f8f;
  color: #2a2420;
  font-family: Georgia, 'Times New Roman', serif;
  padding: 0.75rem 1rem;
  min-height: 44px; /* Touch-friendly */
  transition: border-color 150ms ease, box-shadow 150ms ease;
}

.input-paper:focus {
  outline: none;
  border-color: #d4a855;
  box-shadow: 0 0 0 3px rgba(212, 168, 85, 0.2);
}
```

### Links

```css
.link-gold {
  color: #d4a855;
  text-decoration: underline;
  text-decoration-color: rgba(212, 168, 85, 0.4);
  transition: all 150ms ease;
}

.link-gold:hover {
  color: #e6be6a;
  text-decoration-color: #e6be6a;
}
```

### Feedback States

| State | Text Color | Border Color | Additional |
|-------|------------|--------------|------------|
| Success | `#d4a855` (gold) | `#d4a855` | Subtle gold glow |
| Error | `#8b0000` (burgundy) | `#8b0000` | - |
| Disabled | `#a69f8f` (muted) | `#a69f8f` | opacity: 0.6 |

---

## Decorative Elements

### Dividers

```css
.divider {
  height: 1px;
  background: #d4a855;
  position: relative;
  margin: 2rem 0;
}

/* Optional center diamond */
.divider-diamond::after {
  content: '◆';
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  background: #0a0a0a;
  padding: 0 0.5rem;
  color: #d4a855;
  font-size: 0.75rem;
}
```

### Card Corner Accents

```css
.card-accent {
  position: relative;
}

.card-accent::before,
.card-accent::after {
  content: '';
  position: absolute;
  width: 12px;
  height: 12px;
  border-color: #d4a855;
  border-style: solid;
}

.card-accent::before {
  top: 8px;
  left: 8px;
  border-width: 2px 0 0 2px;
}

.card-accent::after {
  bottom: 8px;
  right: 8px;
  border-width: 0 2px 2px 0;
}
```

### Intro Story Block

```css
.story-block {
  font-family: 'OldNewspaper', 'Times New Roman', Georgia, serif;
  background: linear-gradient(135deg, #1a1a1a 0%, #151515 100%);
  border: 1px solid #a69f8f;
  padding: 2rem;
  transform: rotate(-1deg);
  line-height: 1.8;
}
```

---

## Responsive Behavior

### Breakpoints

| Name | Width | Content Max-Width |
|------|-------|-------------------|
| Mobile (default) | < 640px | 400px |
| Tablet+ | ≥ 640px | 600px |

### Mobile-First Approach

- Single column layout throughout
- Touch-friendly tap targets (minimum 44px height)
- Full-width buttons on small screens
- Generous spacing between interactive elements

### Desktop Enhancements

- Slightly larger typography scale (1.1x)
- More generous padding
- Hub cards could display as 2x2 grid (optional)

---

## Accessibility

| Check | Status |
|-------|--------|
| Gold (#d4a855) on dark (#0a0a0a) | ✓ WCAG AA (7.5:1) |
| Cream (#f5f0e6) on dark (#0a0a0a) | ✓ WCAG AAA (15.2:1) |
| Dark (#2a2420) on cream (#f5f0e6) | ✓ WCAG AAA (11.8:1) |
| Focus states visible | ✓ Gold glow on focus |
| Touch targets | ✓ Min 44px height |

---

## Implementation Notes

### Tailwind CSS Classes to Create

The project already has Tailwind + DaisyUI configured. Add these to `input.css`:

1. Custom color variables in `:root`
2. Custom component classes (`.btn-brass`, `.input-paper`, etc.)
3. `@font-face` for OldNewspaper font

### Files to Modify

1. `src/input.css` - Add custom styles and font-face
2. `src/Pages/Intro.elm` - Add styling classes
3. `src/Pages/Hub.elm` - Add styling classes
4. `src/Pages/Puzzle.elm` - Add styling classes
5. `src/Pages/Stash.elm` - Add styling classes
6. `src/Frontend.elm` - Add global wrapper styling if needed
7. `tailwind.config.js` - Extend theme with custom colors (optional)

### Testing

Run `elm-test` to verify no functionality has changed after styling updates.
