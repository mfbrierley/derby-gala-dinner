# Deploy workflows (to move into place)

These two files belong in `.github/workflows/`. They're parked here because the Claude session
that wrote them isn't allowed to add workflow files to GitHub; your own push is. From the project
folder:

    git pull
    mkdir -p .github/workflows
    git mv setup/workflows/deploy-test.yml setup/workflows/deploy-live.yml .github/workflows/
    git rm -q setup/workflows/README.md
    git commit -m "Add the deploy workflows"
    git push

Then add the three IONOS secrets (see "Deploying to IONOS" in the main README).
