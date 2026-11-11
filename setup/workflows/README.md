# Updated deploy workflows, to move into place

These are new versions of the two files in `.github/workflows/`. They add two things to each
deploy: the build is given the forms' spam-check site key, and the enquiry form settings (the
Resend and Turnstile keys) are written into the build before it's uploaded. See "Enquiry forms"
in the main README.

Claude can't change files in `.github/workflows/` (GitHub doesn't allow it from this kind of
session), so they need moving by a person. On your own machine, in the project folder, on the
branch that has this folder (`claude/practical-ptolemy-h113zm`), so the new forms can be tried on
the test copy before anything is merged:

```bash
git fetch origin
```

```bash
git checkout claude/practical-ptolemy-h113zm
```

```bash
git pull
```

```bash
git mv -f setup/workflows/deploy-live.yml .github/workflows/deploy-live.yml
```

```bash
git mv -f setup/workflows/deploy-test.yml .github/workflows/deploy-test.yml
```

```bash
git rm setup/workflows/README.md
```

```bash
git commit -m "Deploy workflows: write the enquiry form settings"
```

```bash
git push
```

Until this is done, deploys are refused with "dist/api/config.php is missing" and the site on the
server stays exactly as it was.
