# Copyright 2022 - Michael De La Rue
# this file may be distributed either under the Artistic License (version 2 or greater)
# or under the GNU General Public License (version 2.0 or greater) at your choice.

DEV_MOUNT := --mount type=bind,source="$(PWD)",target=/code-live

.PHONY: help
help: ## list all goals in makefile with brief docmentation
	@echo Call make with one of these make goals: ; echo
	@grep "##" $(MAKEFILE_LIST) | grep -v '\^grep' | sed 's/:[^#]*##/ - /' | sort

# we export the index to ensure that we match code to be
# committed and not files that might not get committed.
.PHONY: docker-test
docker-test: build-spamgourmet-clone docker-run-test ## run tests in a docker container having checked that's built
	@echo done

.PHONY: docker-run-test
docker-run-test: ## run tests in a docker container - N.B. does not update the container - prefer docker-test if that works
	docker run $(DEV_MOUNT) -i spamgourmet-testenv make -C /code-live full-env-test

.PHONY: docker-run-example
docker-run-example: ## run an example spameater call - N.B. does not update the container - prefer docker-test if that works
	docker run -i spamgourmet-testenv /usr/bin/perl -s code/mailhandler/spameater  -extradebug=5 -debugstderr=5 <   test/fixture/reject_wrong_domain.email


.PHONY: build-spamgourmet-clone
build-spamgourmet-clone: ## build spamgourmet into a docker container image - requires network
	git checkout-index -f -a --prefix=spamgourmet-clone/code-export/
	docker build --tag spamgourmet-testenv spamgourmet-clone
	@RED='\033[0;31m' ; \
	NC='\033[0m' ; \
	test -z "$$(git status --porcelain)" || ( echo "\n  $${RED}UNCLEAN GIT WORKING DIRECTORY UNCLEAN$${NC} \n"; git status )


.PHONY: full-env-test
full-env-test: ## tests which require the full running spamgourmet environemnt - e.g. integration or functional tests
	./test/test-maileater.sh

.PHONY: shell
shell: ## start interactive shell inside docker container
	docker run $(DEV_MOUNT) -w /code-live -ti spamgourmet-testenv /bin/bash
.PHONY: test
test: ## tests which only require local programming environment - e.g. unit tests
	@echo "there are no tests so you can't prove it isn't working"
