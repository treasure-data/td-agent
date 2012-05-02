# About

The event collector daemon, for Treasure Data Cloud. This daemon collects
various types of logs/events via various way, and transfer them to the
cloud.

For more about Treasure Data, see <http://treasure-data.com/>.

For full documentation see <http://docs.treasure-data.com/>.

# Requirement

* openssl
* pbuilder

# Prepare

This script will create the debian environments by pbuilder-dist.

# Build

## deb

For the first time, you need to prepare chroot environments for each distribution. This takes a time.

```bash
$ ./make-deb-init.sh
```

Then, execute make-deb.sh.

```bash
$ ./make-deb.sh
```

## rpm

```bash
$ ./make-rpm.sh
```

If you use specific revision of fluentd...

```bash
$ ./make-rpm.sh e20137ce1f92c4e364d304969f56bf41e713ee07
```

# Install and Setup

Please refer the document (http://docs.treasure-data.com).

# Notice

td-agent consists of the following components, and packaged as rpm/deb.

* ruby (1.9.3-p125): http://www.ruby-lang.org/en/
* jemalloc: http://www.canonware.com/jemalloc/
* fluentd: https://github.com/fluent/fluentd
* fluent-plugin-mongo: https://github.com/fluent/fluent-plugin-mongo
* fluent-plugin-s3: https://github.com/fluent/fluent-plugin-s3
* fluent-plugin-scribe: https://github.com/fluent/fluent-plugin-scribe
* fluent-plugin-td: https://github.com/treasure-data/fluent-plugin-td

td-agent depends on those packages.

* openssl, readline, libxslt, libxml2
* [td-libyaml](https://github.com/treasure-data/td-libyaml) (rpm) or libyaml (deb)

# License

Released under the Apache2 license.
