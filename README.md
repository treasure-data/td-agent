# About

The event collector daemon, for Treasure Data Cloud. This daemon collects
various types of logs/events via various way, and transfer them to the
cloud.

For more about Treasure Data, see <http://treasure-data.com/>.

For full documentation see <http://docs.treasure-data.com/>.

# Requirement

* openssl
* pbuilder
* rinse

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

# Install and Setup

Please refer the document (http://docs.treasure-data.com).

# Notice

td-agent consists of the following components, and packaged as rpm/deb.

* ruby 1.9.2
* fluent: https://github.com/fluent/fluentd
* fluent-plugin-scribe: https://github.com/fluent/fluent-plugin-scribe
* fluent-plugin-td: https://github.com/treasure-data/fluent-plugin-td
* fluent-plugin-mongo: https://github.com/treasure-data/fluent-plugin-mongo

# License

Released under the Apache2 license.
