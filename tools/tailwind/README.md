# Tailwind CSS Build

Folder kept here (NOT in project root) so Railway/Nixpacks doesn't
treat the project as a Node.js app. Project is Python — Node is only
used as a local CSS build tool.

## When templates change — rebuild the CSS

```bash
cd tools/tailwind
npm install        # one-time
npm run build:css  # generates ../../static/tailwind.css
```

Then commit the updated `static/tailwind.css` and push.

## Why not auto-build on Railway?

Putting `package.json` at project root confuses Nixpacks — it then
tries to run as a Node app and skips Python install. Keeping the
build files here, with the generated CSS committed, makes the deploy
deterministic and fast.
