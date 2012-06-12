SUBDIRS = deps/jemalloc deps/ruby

bin_SCRIPTS = td
sbin_SCRIPTS = td-agent

MOSTLYCLEANFILES = $(sbin_SCRIPTS)

unexport GEM_HOME
unexport GEM_PATH
DEST_RUBY = $(DESTDIR)$(RUBY_BINDIR)/ruby
DEST_GEM = $(DEST_RUBY) -rrubygems -rrubygems/gem_runner -rrubygems/exceptions -rrubygems/installer -e 'class Gem::Installer; def shebang(bin_file_name) "\#\!$(RUBY_BINDIR)/ruby" end; end; Gem::GemRunner.new.run ARGV'
DEST_RAKE = $(DEST_RUBY) -rrake -e 'Rake.application.run'
DEST_RUBY_LIBDIR = $(DESTDIR)$(RUBY_LIBDIR)/ruby
PLUGINS = \
  td-0.10.25.gem fluent-plugin-td-0.10.7.gem \
  thrift-0.8.0.gem fluent-plugin-scribe-0.10.9.gem \
  fluent-plugin-flume-0.1.1.gem \
  bson-1.6.4.gem bson_ext-1.6.4.gem mongo-1.6.4.gem fluent-plugin-mongo-0.6.7.gem \
  fluent-plugin-s3-0.2.2.gem

td: plugins
	echo `#!/bin/sh` > $@
	echo '$(RUBY_BINDIR)/td' >> $@
	chmod 755 $@

td-agent: plugins
	echo '#!$(RUBY_BINDIR)/ruby' > $@
	echo 'ENV["FLUENT_CONF"]="$(sysconfdir)/td-agent/td-agent.conf"' >> $@
	echo 'ENV["FLUENT_PLUGIN"]="$(sysconfdir)/td-agent/plugin"' >> $@
	echo 'ENV["FLUENT_SOCKET"]="$(localstatedir)/run/td-agent/td-agent.sock"' >> $@
	echo 'load "$(RUBY_BINDIR)/fluentd"' >> $@
	chmod 755 $@

plugins:
	mkdir -p "$(srcdir)/plugins/"
	for gem in $(PLUGINS); do \
		if [ ! -f "$(srcdir)/plugins/$$gem" ]; then \
			wget "http://rubygems.org/downloads/$$gem" -O "$(srcdir)/plugins/$$gem"; \
		fi; \
	done

install: install-recursive
	for gem in $(srcdir)/deps/*.gem; do \
		RUBYLIB="$(DEST_RUBY_LIBDIR)/1.9.1:$(DEST_RUBY_LIBDIR)/1.9.1/$(shell $(DEST_RUBY) --version | sed 's/.*\[\(.*\)\]/\1/')" \
			$(DEST_GEM) install --no-rdoc --no-ri "$$gem"; \
	done
	cd "$(srcdir)" && \
		RUBYLIB="$(DEST_RUBY_LIBDIR)/1.9.1:$(DEST_RUBY_LIBDIR)/1.9.1/$(shell $(DEST_RUBY) --version | sed 's/.*\[\(.*\)\]/\1/')" \
		$(DEST_RAKE)
	for gem in $(srcdir)/pkg/*.gem; do \
		RUBYLIB="$(DEST_RUBY_LIBDIR)/1.9.1:$(DEST_RUBY_LIBDIR)/1.9.1/$(shell $(DEST_RUBY) --version | sed 's/.*\[\(.*\)\]/\1/')" \
			$(DEST_GEM) install --no-rdoc --no-ri "$$gem"; \
	done
	for gem in $(PLUGINS); do \
		RUBYLIB="$(DEST_RUBY_LIBDIR)/1.9.1:$(DEST_RUBY_LIBDIR)/1.9.1/$(shell $(DEST_RUBY) --version | sed 's/.*\[\(.*\)\]/\1/')" \
			$(DEST_GEM) install --no-rdoc --no-ri "$(srcdir)/plugins/$$gem"; \
	done
	rm -fR "$(DEST_RUBY_LIBDIR)/gems/1.9.1/gems/bson-1.6.2/bin/b2json"
	rm -fR "$(DEST_RUBY_LIBDIR)/gems/1.9.1/gems/bson-1.6.2/bin/j2bson"
	mkdir -p $(DESTDIR)$(sysconfdir)/td-agent
	cp -f $(srcdir)/td-agent.conf $(DESTDIR)$(sysconfdir)/td-agent/td-agent.conf.tmpl
	mkdir -p $(DESTDIR)$(sysconfdir)/td-agent/prelink.conf.d
	cp -f $(srcdir)/td-agent.prelink.conf $(DESTDIR)$(sysconfdir)/td-agent/prelink.conf.d/td-agent.conf
	mkdir -p $(DESTDIR)$(sysconfdir)/td-agent/plugin

dist:
	cd $(srcdir) && ./make_dist.sh

.PHONY: plugins
