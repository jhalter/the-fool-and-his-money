.PHONY: deploy

deploy:
	./scripts/build-pages.sh
	git add docs/
	git commit -m "Deploy to GitHub Pages"
	git push origin master
