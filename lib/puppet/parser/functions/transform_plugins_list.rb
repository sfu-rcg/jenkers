module Puppet::Parser::Functions
  newfunction(:transform_plugins_list, :type => :rvalue, :doc => <<-EOS
Returns an Array of curl commands that will install Jenkins plugins. Accepts a base URL and Hash.
    EOS
  ) do |args|

    if args.size != 3
      e = "transform_plugins_list(): Wrong number of args: #{args.size} for 3"
      raise(Puppet::ParseError, e)
    end

    base_url, plugins_dir, plugins = *args

    unless base_url.is_a? String
      e = "transform_plugins_list(): Wrong arg type! (#{base_url.class} instead of String)"
      raise(Puppet::ParseError, e)
    end

    unless plugins_dir.is_a? String
      e = "transform_plugins_list(): Wrong arg type! (#{plugins_dir.class} instead of String)"
      raise(Puppet::ParseError, e)
    end

    unless plugins.is_a? Hash
      e = "transform_plugins_list(): Wrong arg type! (#{plugins.class} instead of Hash)"
      raise(Puppet::ParseError, e)
    end

    return {} if plugins.empty?

    plugins.inject([]) do |memo, (plugin,version)|
      url     = "#{base_url}/#{plugin}/#{version}/#{plugin}.hpi"
      outfile = "#{plugins_dir}/#{plugin}.hpi"
      memo << "curl -sf -o #{outfile} -L #{url}"
      memo
    end

  end
end
