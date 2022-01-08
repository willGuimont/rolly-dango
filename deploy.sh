nimble rel
w4 bundle --html build/html/index.html --title Dango --description "Rolling puzzle game" --icon-file "assets/sprites/dangoBeeg.png" build/cart.wasm
git add -f build/html && git commit -m "Deploy"
git push origin `git subtree split --prefix build/html`:gh-pages --force
