WORKDIR = $(abspath .)

DEVTMPDIR = $(WORKDIR)/dev-tmp
MAINDIR = $(WORKDIR)/main
BUILDERDIR = $(WORKDIR)/universeBuilder
DOCKERFILEDIR = $(WORKDIR)/dockerfiles

$(shell mkdir -p $(DEVTMPDIR))

BUILDSRC = $(shell find $(BUILDERDIR) -name "*.go")
MAINSRC = $(shell find $(MAINDIR) -name "*.go")
BUILDDOCKERFILE = $(DOCKERFILEDIR)/universeBuilder_dev.Dockerfile
MAINDOCKERFILE = $(DOCKERFILEDIR)/main_dev.Dockerfile

BUILDTAR = $(DEVTMPDIR)/builder-dev.tar
MAINTAR = $(DEVTMPDIR)/main-dev.tar

GO = go
DOCKER = docker
SSH = ssh
CAT = cat

build: $(BUILDSRC)
	$(GO) build $^ -o $(DEVTMPDIR)/main
	$(DOCKER) build -t builder-dev -f $(BUILDDOCKERFILE) $(WORKDIR)
	$(DOCKER) save builder-dev -o $(BUILDTAR)

main: $(MAINSRC)
	$(GO) build $^ -o $(DEVTMPDIR)/main
	$(DOCKER) build -t main-dev -f $(MAINDOCKERFILE) $(WORKDIR)
	$(DOCKER) save main-dev -o $(MAINTAR)

bscp: $(BUILDTAR)
	$(CAT) $^ | $(SSH) 192.168.79.12 'cd /home/node & docker load'
	$(CAT) $^ | $(SSH) 192.168.79.13 'cd /home/node & docker load'

mscp: $(MAINTAR)
	$(CAT) $^ | $(SSH) 192.168.79.12 'cd /home/node & docker load'
	$(CAT) $^ | $(SSH) 192.168.79.13 'cd /home/node & docker load'

.PHONY: build main bscp mscp
