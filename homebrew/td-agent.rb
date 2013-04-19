require 'formula'

class TdAgent < Formula
  url 'https://github.com/treasure-data/td-agent.git', :revision => 'a9b4ea2cb198113208f1aa1af7865f4cae563545'
  head 'https://github.com/treasure-data/td-agent.git'
  homepage 'https://github.com/treasure-data/td-agent'
  version '1.1.12'

  option 'fluentd-rev=<revision>', 'Using specify Fluentd revision'

  # TODO: depends_on 'jemalloc' => :optional
  depends_on 'readline'
  depends_on 'openssl'
  depends_on 'ruby-build'

  def install
    install_ruby unless File.exist?(dest_ruby)

    %W(bundler 1.2.5 json 1.5.2 msgpack 0.4.7 iobuffer 1.1.2
       cool.io 1.1.0 http_parser.rb 0.5.1 yajl-ruby 1.0.0).each_slice(2) { |gem, version|
      install_gem(gem, version)
    }

    install_fluentd

    %W(td-client 0.8.39 td 0.10.63 fluent-plugin-td 0.10.13
       thrift 0.8.0 fluent-plugin-scribe 0.10.10
       fluent-plugin-flume 0.1.1 bson 1.8.4 bson_ext 1.8.4 mongo 1.8.4
       fluent-plugin-mongo 0.7.0 aws-sdk 1.8.3.1 fluent-plugin-s3 0.3.1
       webhdfs 0.5.1 fluent-plugin-webhdfs 0.1.4).each_slice(2) { |gem, version|
      install_gem(gem, version)
    }

    unless File.exist?(td_agent_conf)
      inreplace "td-agent.conf", "/var/log/td-agent", "#{var}/log/td-agent"
      (etc + "td-agent").install "td-agent.conf"
    end
    (bin + "td-agent").write(td_agent_bin)

    # TODO: Remove ruby related binary from /usr/local/bin
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
    Default configuration file was created here:

       #{td_agent_conf}

    If you want to know the detail of Fluentd, see Fluentd documents at

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
    system <<EOS
RUBY_CONFIGURE_OPTS="--with-openssl-dir=#{Formula.factory('openssl').prefix} --with-readline-dir=#{Formula.factory('readline').prefix}" \
#{Formula.factory('ruby-build').bin}/ruby-build 1.9.3-p194 #{prefix}
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
    rev = '9ed984d88c21d77b4878f9fc7f31440d1f28ed27'
    ARGV.each do |a|
      if a.index('--fluentd-rev')
        rev = a.sub('--fluentd-rev=', '')
        break
      end
    end

    ohai "Fluentd revision: #{rev}"
    rev
  end
end
