/** @type {import('tailwindcss').Config} */
module.exports = {
  // Skanyirayem vse Jinja-shabolony i ekstraktiruyem klassy.
  // Vse kotorye ispol'zuyutsya — popadayut v final'nyy CSS.
  // Vse drugie — udalyayutsya. Eto i est' "tree-shaking" / "purge".
  content: [
    "../../templates/**/*.html",
    "../../static/**/*.js",
  ],
  // No broad safelist. Audited 2026-06-22: every dynamic class in the templates
  // (Alpine `:class="cond ? 'bg-red-500 ...' : '...'"`, the test_done.html Jinja
  // ternary, etc.) is a *contiguous literal string* the content scanner already
  // extracts from the raw file text. There is zero string concatenation
  // (`'bg-' + c`) and no JS/Python emitting color classes. The only
  // scanner-invisible case is the split interpolation in live_history_view.html
  // (`bg-{{ 'emerald' if .. else 'blue' }}-100`), covered by literal copies in
  // templates/_tw_safelist.html. This cut the build from ~220 KB to ~79 KB with
  // no visual regression. To re-add a dynamic class, prefer a literal in
  // _tw_safelist.html over re-broadening this safelist.
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
