# About

The event collector daemon, for Treasure Data Cloud. This daemon collects
various types of logs/events via various way, and transfer them to the
cloud.

For more about Treasure Data, see <http://treasure-data.com/>.

For full documentation see <http://docs.treasure-data.com/>.

# Requirement

* openssl

# Build

```bash
$ ./make-rpm.sh # for rpm
$ ./make-deb.sh # for deb
```

# Install and Setup

Please refer the document (http://docs.treasure-data.com).

# Notice

td-agent consists of the following components, and packaged as rpm/deb.

* ruby 1.9.2
* fluent: https://github.com/fluent/fluent
* fluent-plugin-scribe: https://github.com/fluent/fluent-plugin-scribe
* fluent-plugin-td: https://github.com/treasure-data/fluent-plugin-td

# License

Released under the Apache2 license.
