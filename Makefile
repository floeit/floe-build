dev_folder = $(abspath $(CURDIR))

floe_folder = $(dev_folder)/src/floe
customfloe_folder = $(dev_folder)/src/customfloe
public_folder = $(dev_folder)/public

GOPATH=$(dev_folder)

# can pass in the branch and repo owner / fork we want to build - need to have same branch on all repo owners for each repo
BRANCH?=master
REPO?=floeit

all: init release

create:
	@echo $(dev_folder)
	
	mkdir -p $(dev_folder)/src

	git clone git@github.com:$(REPO)/floe.git $(floe_folder)
	git clone git@github.com:$(REPO)/public.git $(public_folder)
	git clone git@github.com:$(REPO)/customfloe.git $(customfloe_folder)
	
	# get dependancies
	cd $(dev_folder); GOPATH=$(GOPATH) go get ./src/...

	# make sure scripts executable
	chmod +x $(dev_folder)/*.sh

switch:
	git --git-dir=$(floe_folder)/.git --work-tree=$(floe_folder) checkout $(BRANCH)
	git --git-dir=$(public_folder)/.git --work-tree=$(public_folder) checkout $(BRANCH)
	git --git-dir=$(custom_floe_folder)/.git --work-tree=$(custom_floe_folder) checkout $(BRANCH)


setup: create switch

build:
	cd $(dev_folder); GOPATH=$(GOPATH) go install ./src/...

test:
	cd $(dev_folder); GOPATH=$(GOPATH) go test ./src/...

package: build
	-rm -rf build/pkg
	-mkdir -p build/pkg/bin

	cp $(dev_folder)/bin/* build/pkg/bin/

	cp -r public build/pkg
	
	-mkdir build/releases
	cd build; tar -czvf releases/pkg.tar pkg/

clean:
	rm -rf $(dev_folder)/pkg
	rm -rf $(dev_folder)/bin

update:
	git --git-dir=$(floe_folder)/.git --work-tree=$(floe_folder) pull
	git --git-dir=$(public_folder)/.git --work-tree=$(public_folder) pull
	git --git-dir=$(custom_floe_folder)/.git --work-tree=$(custom_floe_folder) pull

status:
	git --git-dir=$(floe_folder)/.git --work-tree=$(floe_folder) status
	git --git-dir=$(public_folder)/.git --work-tree=$(public_folder) status
	git --git-dir=$(custom_floe_folder)/.git --work-tree=$(custom_floe_folder) status

show:
	@git --git-dir=$(floe_folder)/.git --work-tree=$(floe_folder) remote show origin | grep Fetch
	@git --git-dir=$(public_folder)/.git --work-tree=$(public_folder) remote show origin | grep Fetch
	@git --git-dir=$(custom_floe_folder)/.git --work-tree=$(custom_floe_folder) remote show origin | grep Fetch




