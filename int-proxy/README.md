# Additional instructions

Sparse checkout the repository:
```bash
mkdir ${CONFIGS_DIR:?}/error-pages
cd ${CONFIGS_DIR:?}/error-pages

git init
git remote add -f origin git@github.com:Pace222/home-error-pages.git

git config core.sparseCheckout true
echo "dist/" >> .git/info/sparse-checkout

git pull origin master
git branch --set-upstream-to=origin/master main
```
