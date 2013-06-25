require 'formula'

class TdAgent < Formula
  url 'https://github.com/treasure-data/td-agent.git', :revision => '6f5aafc3202fa736767663c0ae5fd651e01b23c1'
  head 'https://github.com/treasure-data/td-agent.git'
  homepage 'https://github.com/treasure-data/td-agent'
  version '1.1.14'

  option 'fluentd-rev=<revision>', 'Using specify Fluentd revision'
  option 'ruby-ver=<version>', 'Using specify Ruby version listed by ruby-build'

  # TODO: depends_on 'jemalloc' => :optional
  depends_on 'readline'
  depends_on 'openssl'
  depends_on 'ruby-build'

  def install
    install_ruby

    %W(bundler 1.3.5 msgpack 0.4.7 iobuffer 1.1.2
       cool.io 1.1.0 http_parser.rb 0.5.1 yajl-ruby 1.1.0).each_slice(2) { |gem, version|
      install_gem(gem, version)
    }

    install_fluentd

    %W(td-client 0.8.52 td 0.10.82 fluent-plugin-td 0.10.14
       thrift 0.8.0 fluent-plugin-scribe 0.10.10
       fluent-plugin-flume 0.1.1 bson 1.8.6 bson_ext 1.8.6 mongo 1.8.6
       fluent-plugin-mongo 0.7.0 nokogiri 1.5.10 aws-sdk 1.8.3.1 fluent-plugin-s3 0.3.3
       webhdfs 0.5.3 fluent-plugin-webhdfs 0.2.0).each_slice(2) { |gem, version|
      install_gem(gem, version)
    }

    unless File.exist?(td_agent_conf)
      inreplace "td-agent.conf", "/var/log/td-agent", "#{var}/log/td-agent"
      (etc + "td-agent").install "td-agent.conf"
    end
    (bin + "td-agent").write(td_agent_bin)

    # TODO: Remove ruby related binaries from /usr/local/bin
    %W(j2bson b2json).each { |b|
      (bin + b).unlink rescue nil
    }
  end

  def post_install
    (etc + 'td-agent/plugin').mkpath
    (var + 'log/td-agent').mkpath
    (var + 'run/td-agent').mkpath
  end

  def test
    system "false"
  end

  def td_agent_bin
    <<-EOS.undent
    #!#{prefix}/bin/ruby
    ENV["FLUENT_CONF"] = "#{td_agent_conf}"
    ENV["FLUENT_PLUGIN"] = "#{etc}/td-agent/plugin"
    ENV["FLUENT_SOCKET"] = "#{var}/run/td-agent/td-agent.sock"
    load "#{prefix}/bin/fluentd"
    EOS
  end

  def caveats
    <<-EOS.undent
    td-agent configuration file and plugin directories were created:

        #{td_agent_conf}
        #{etc}/td-agent/plugin

    You can invoke td-agent manually via td-agent command without launchctl:

        td-agent --pid #{var}/run/td-agent/td-agent.pid

    If you want to know the details of Fluentd, see Fluentd documents at:

        http://docs.fluentd.org/
    EOS
  end

  def plist
    <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{prefix}/bin/td-agent</string>
        <string>--log</string>
        <string>#{var}/log/td-agent/td-agent.log</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{var}/td-</string>
    </dict>
    </plist>
    EOS
  end

  private

  def td_agent_conf
    "#{etc}/td-agent/td-agent.conf"
  end

  def install_ruby
    ver = parse_option_value("ruby-ver", '1.9.3-p392')
    system <<EOS
RUBY_CONFIGURE_OPTS="--with-openssl-dir=#{Formula.factory('openssl').prefix} --with-readline-dir=#{Formula.factory('readline').prefix}" \
#{Formula.factory('ruby-build').bin}/ruby-build #{ver} #{prefix}
EOS
  end

  def install_gem(gem, version)
    system "#{dest_gem} install #{gem} -v #{version} --no-ri --no-rdoc"
  end

  def dest_ruby
    "#{prefix}/bin/ruby"
  end

  def dest_gem
    "#{prefix}/bin/gem"
  end

  def install_fluentd
    rev = fluentd_rev
    system "git clone https://github.com/fluent/fluentd.git"
    Dir.chdir("./fluentd") { 
      system "git checkout #{rev}"
      system "#{dest_gem} build fluentd.gemspec"
      system "#{dest_gem} install ./fluentd-*.gem --no-ri --no-rdoc"
    }
  end

  def fluentd_rev
    rev = parse_option_value("fluentd-rev", '37a1dabceafa2ed7a2ce533f233ad0c1248a3394')
    ohai "Fluentd revision: #{rev}"
    rev
  end

  def parse_option_value(opt, default)
    ARGV.each do |a|
      if a.index("--#{opt}")
        return a.sub("--#{opt}=", '')
      end
    end

    return default
  end
end
