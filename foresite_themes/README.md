# ForeSITE themes

Official ForeSITE brand and ready-to-use themes for **pkgdown sites** and
**Quarto reports** (HTML and PDF). Everything is driven by a single
[`_brand.yml`](https://posit-dev.github.io/brand-yml/) file, so websites,
reports, Shiny apps, and ggplot2 figures share the same colors, fonts, and
logos.

```
foresite_themes/
├── _brand.yml          # Canonical ForeSITE brand (colors, typography, logos)
├── _quarto.yml         # Quarto project settings for the report theme
├── assets/
│   └── logos/          # Primary, secondary, single-color, and icon logos (PNG)
├── pkgdown/
│   └── _pkgdown.yml    # pkgdown theme settings to merge into your package
└── reports/
    ├── foresite.scss   # Extra report styles (title banner, headings)
    └── template.qmd    # Example report (HTML + PDF via Typst)
```

## Brand summary

Source: *ForeSITE Usage Guidelines* (WSU Design and Printing Services,
N12526.4.24). The guidelines are not distributed in this repository. For the
full details, check the ForeSITE shared folders or ask your supervisor or
brand manager.

| Color     | Hex       | PMS    | Role in themes                    | Contrast on white |
|-----------|-----------|--------|-----------------------------------|-------------------|
| Crimson   | `#A60F2D` | 201 C  | `primary`, links, title banner    | 7.70:1 (AAA)      |
| Gold      | `#FDB921` | 1235 C | Accents, borders, focus ring      | 1.73:1 (**not for text**) |
| Dark Gray | `#4E4E4E` | 7540 C | Body text (`foreground`)          | 8.32:1 (AAA)      |

- The guidelines list the dark gray hex as `9A5107`, which is a typo. The
  RGB (78, 78, 78) and PMS values correspond to `#4E4E4E`.
- **Gold is an accent color only.** Never use it for text on light
  backgrounds. Dark gray (4.81:1) and black (12.1:1) text are fine on gold.
- **Typography.** The logo uses Proxima Nova Semibold, a commercial font.
  The themes use [Montserrat](https://fonts.google.com/specimen/Montserrat)
  for headings as the closest open alternative. Body text uses Open Sans and
  code uses IBM Plex Mono. All three load from Google Fonts.

### Logo rules (from the guidelines)

- Never alter, recolor, or recreate the logo. Always use the provided files
  and keep the proportions when resizing.
- Don't use it narrower than 0.75 inch. Keep clear space equal to the height
  of the "ForeSITE" wordmark on every side.
- Use `foresite-white.png` on dark backgrounds. Single-color crimson and gold
  versions need approval from your supervisor or brand manager.
- Web-ready PNGs are in `assets/logos/`. Vector (EPS/PDF) and CMYK originals
  are in the ForeSITE shared folders.

## Copy bundled with rbranding

`inst/brand_files/` holds a copy of `_brand.yml` and `assets/logos/`, used by
the package vignettes. After editing the brand here, run `make sync-brand`.

## pkgdown theme

Requires pkgdown ≥ 2.1.0 and the [brand.yml](https://posit-dev.github.io/brand-yml/pkg/r/)
R package.

1. Copy `_brand.yml` and `assets/` into your package, for example into
   `pkgdown/brand/`. `pkgdown/` is usually already in `.Rbuildignore`.
2. Merge [`pkgdown/_pkgdown.yml`](pkgdown/_pkgdown.yml) into your package's
   `_pkgdown.yml`, and point `template.bslib.brand` at the copied file.
3. Add `any::brand.yml` to `extra-packages` in your pkgdown GitHub workflow,
   or `Config/Needs/website: brand.yml` in `DESCRIPTION`.
4. Run `pkgdown::build_site()`.

The theme uses a white navbar with a gold accent and crimson headings and
links. It also adds a footer with the CDC cooperative agreement
acknowledgment. The rbranding website itself uses this theme; see the
repository's `_pkgdown.yml`.

Alternatively, you can download the brand file with rbranding:

```r
rbranding::brand_init(
  brand_url = "https://raw.githubusercontent.com/EpiForeSITE/rbranding/main/foresite_themes/_brand.yml"
)
rbranding::get_brand_public(run_interactive = FALSE)
```

This downloads only `_brand.yml`. Copy the `assets/logos/` folder as well if
you use the logos.

## Quarto report theme

Requires Quarto ≥ 1.6. This folder is a Quarto project, so `_brand.yml` is
applied automatically. The shared settings in `_quarto.yml` produce:

- **HTML:** a crimson title banner with a gold rule, a table of contents on
  the left, numbered sections, and a self-contained file (`embed-resources`).
- **PDF (Typst):** the ForeSITE logo, fonts, and colors, US Letter with
  1-inch margins, and no LaTeX installation required.

To start a new report:

1. Copy this whole folder (or keep it in your project) and duplicate
   `reports/template.qmd`.
2. Render it:

```sh
quarto render reports/my-report.qmd              # HTML and PDF
quarto render reports/my-report.qmd --to typst   # PDF only
```

The template shows how to reuse brand colors in R code by reading
`_brand.yml` with `yaml::read_yaml()`. It also ends with the standard funding
acknowledgment.

## Funding acknowledgment

Materials produced with cooperative agreement funding must carry this
disclaimer:

> This [publication/project] was made possible by cooperative agreement
> CDC-RFA-FT-23-0069 from the CDC's Center for Forecasting and Outbreak
> Analytics. Its contents are solely the responsibility of the authors and do
> not necessarily represent the official views of the Centers for Disease
> Control and Prevention.

The CDC logo **cannot** be used to co-brand with the University without prior
approval from CDC/HHS.
