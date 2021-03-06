PROJECTNAME=proj
APPNAME=foo
TARGETDIR=out

.PHONY: help
help:
	# -----------------------------------------------------------------------------
	# Targets:
	#
	#	clean 					: rm -rf ./out
	#	help 					: show this message
	#	gen PROJECTNAME=proj APPNAME=foo	: generate project in ./out/PROJECTNAME
	#
	# end.
	# -----------------------------------------------------------------------------

.PHONY: gen
gen: templates selftest

.PHONY: templates
templates:
	mkdir -p $(TARGETDIR)/temp
	mkdir -p $(TARGETDIR)/$(PROJECTNAME)
	APPNAME=$(APPNAME) ./tools/mo templates/RootMakefile > $(TARGETDIR)/$(PROJECTNAME)/Makefile
	APPNAME=$(APPNAME) ./tools/mo templates/Dockerfile > $(TARGETDIR)/$(PROJECTNAME)/Dockerfile
	PROJECTNAME=$(PROJECTNAME) APPNAME=$(APPNAME) ./tools/mo templates/RootREADME.md > $(TARGETDIR)/$(PROJECTNAME)/README.md
	cd  $(TARGETDIR)/$(PROJECTNAME) && rebar3 new release $(APPNAME)
	APPNAME=$(APPNAME) ./tools/mo templates/APPNAME.app.src > $(TARGETDIR)/$(PROJECTNAME)/$(APPNAME)/apps/$(APPNAME)/src/$(APPNAME).app.src
	APPNAME=$(APPNAME) ./tools/mo templates/rebar.config > $(TARGETDIR)/$(PROJECTNAME)/$(APPNAME)/rebar.config
	APPNAME=$(APPNAME) ./tools/mo templates/AppMakefile > $(TARGETDIR)/$(PROJECTNAME)/$(APPNAME)/Makefile
	cd  $(TARGETDIR)/temp && git clone http://github.com/toddg/monitor && cd monitor && git checkout tags/v0.1.0 && $(MAKE) package
	cd $(TARGETDIR)/$(PROJECTNAME) && tar -zxvf ../temp/monitor/monitor.tgz
	APPNAME=$(APPNAME) ./tools/mo templates/docker-compose.yml > $(TARGETDIR)/$(PROJECTNAME)/monitor/docker-compose.yml
	APPNAME=$(APPNAME) ./tools/mo templates/prometheus.yml > $(TARGETDIR)/$(PROJECTNAME)/monitor/config/prometheus.yml

.PHONY: selftest
selftest:
	cd $(TARGETDIR)/$(PROJECTNAME) && $(MAKE) selftest

.PHONY: clean
clean:
	# hardcode to ./out to prevent mistakenly blasting another directory
	rm -rf ./out
