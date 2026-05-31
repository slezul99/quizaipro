/** @type {import('tailwindcss').Config} */
module.exports = {
  // Skanyirayem vse Jinja-shabolony i ekstraktiruyem klassy.
  // Vse kotorye ispol'zuyutsya — popadayut v final'nyy CSS.
  // Vse drugie — udalyayutsya. Eto i est' "tree-shaking" / "purge".
  content: [
    "../../templates/**/*.html",
    "../../static/**/*.js",
  ],
  // Polnyy spektr klassov ispol'zuyetsya v inline x-bind / dynamic strings —
  // safelist ohranyaet ot ploxhego purge.
  safelist: [
    // Color classes which appear via Alpine x-bind / inline style logic
    { pattern: /^(bg|text|border|from|to|via|ring)-(red|orange|amber|yellow|green|emerald|teal|cyan|blue|indigo|violet|purple|fuchsia|pink|rose|slate|gray|zinc|neutral|stone)-(50|100|200|300|400|500|600|700|800|900)$/ },
    // Common dark variants
    { pattern: /^dark:(bg|text|border)-(slate|gray|indigo|emerald|red|amber)-(100|200|300|400|500|600|700|800|900)$/ },
    // Width / height percentages (used in progress bars)
    { pattern: /^w-(1\/2|1\/3|2\/3|1\/4|3\/4|full|screen|0|1|2|4|6|8|10|12|16|20|24|32)$/ },
    // Animation classes referenced by Alpine
    "animate-bounce", "animate-pulse", "animate-spin", "animate-ping",
    // Display classes used dynamically
    "hidden", "block", "flex", "grid", "inline-block",
    // Common opacity
    "opacity-0", "opacity-50", "opacity-100",
    // Accessibility helpers
    "sr-only", "not-sr-only",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  // V production rezhime nuzhno chtoby `dark:` rabotal cherez .dark class na <html>
  darkMode: 'class',
  plugins: [],
}
