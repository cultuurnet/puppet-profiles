# Originally copied from Peter Souter hiera_vault repository, licensed under the Apache License, Version 2.0
#
# https://github.com/petems/petems-hiera_vault/blob/master/lib/puppet/functions/hiera_vault.rb

require_relative 'hiera_vault/authentication.rb'

Puppet::Functions.create_function(:hiera_vault) do
  begin
    require 'vault'
  rescue LoadError => _e
    raise Puppet::DataBinding::LookupError, "[hiera-vault] Must install vault gem to use hiera-vault backend"
  end

  dispatch :lookup_key do
    param 'Variant[String, Numeric]', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def lookup_key(key, options, context)
    if confine_keys = options['confine_to_keys']
      raise ArgumentError, '[hiera-vault] confine_to_keys must be an array' unless confine_keys.is_a?(Array)

      begin
        confine_keys = confine_keys.map { |r| Regexp.new(r) }
      rescue StandardError => e
        raise Puppet::DataBinding::LookupError, "[hiera-vault] creating regexp failed with: #{e}"
      end

      regex_key_match = Regexp.union(confine_keys)

      unless key[regex_key_match] == key
        context.explain { "[hiera-vault] Skipping hiera_vault backend because key '#{key}' does not match confine_to_keys" }
        context.not_found
      end
    end

    if strip_from_keys = options['strip_from_keys']
      raise ArgumentError, '[hiera-vault] strip_from_keys must be an array' unless strip_from_keys.is_a?(Array)

      strip_from_keys.each do |prefix|
        key = key.gsub(Regexp.new(prefix), '')
      end
    end

    vault_get(key, options, context)
  end

  def vault_get(key, options, context)
    hiera_vault_client = Vault::Client.new

    begin
      hiera_vault_client.configure do |config|
        config.address = options['address'] unless options['address'].nil?
        config.ssl_verify = options['ssl_verify'] unless options['ssl_verify'].nil?
        config.ssl_ca_cert = options['ssl_ca_cert'] if config.respond_to? :ssl_ca_cert
      end

      context.explain { "[hiera-vault] Using #{options['authentication']['method']} authentication" }
      authenticate(options['authentication'], hiera_vault_client, context)

      if hiera_vault_client.sys.seal_status.sealed?
        raise Puppet::DataBinding::LookupError, "[hiera-vault] vault is sealed"
      end

      context.explain { "[hiera-vault] Client configured to connect to #{hiera_vault_client.address}" }
    rescue StandardError => e
      hiera_vault_client.shutdown
      raise Puppet::DataBinding::LookupError, "[hiera-vault] Skipping backend. Configuration error: #{e}"
    end

    answer = nil

    # Only kv v2 mounts supported
    options['mounts'].each_pair do |mount, paths|
      interpolate(context, paths).each do |path|
        context.explain { "[hiera-vault] Looking on mount #{mount} in path #{path} for #{key}" }

        secret = nil

        begin
          context.explain { "[hiera-vault] Checking path: #{path} on mount: #{mount}" }
          secret = hiera_vault_client.kv(mount).read(File.join(path, key).chomp('/'))
        rescue Vault::HTTPConnectionError
          msg = "[hiera-vault] Could not connect to read secret: #{path} on mount: #{mount}"
          context.explain { msg }
          raise Puppet::DataBinding::LookupError, msg
        rescue Vault::HTTPError => e
          msg = "[hiera-vault] Could not read secret #{path} on mount #{mount}: #{e.errors.join("\n").rstrip}"
          context.explain { msg }
          raise Puppet::DataBinding::LookupError, msg
        end

        next if secret.nil?

        context.explain { "[hiera-vault] Read secret: #{key}" }
        # Turn secret's hash keys into strings allow for nested arrays and hashes
        # this enables support for create resources etc
        answer = secret.data.inject({}) { |h, (k, v)| h[k.to_s] = stringify_keys v; h }
        break
      end

      break unless answer.nil?
    end

    raise Puppet::DataBinding::LookupError, "[hiera-vault] Could not find secret #{key}" if answer.nil?

    answer = context.not_found if answer.nil?
    hiera_vault_client.shutdown

    return answer
  end

  # Stringify key:values so user sees expected results and nested objects
  def stringify_keys(value)
    case value
    when String
      value
    when Hash
      result = {}
      value.each_pair { |k, v| result[k.to_s] = stringify_keys v }
      result
    when Array
      value.map { |v| stringify_keys v }
    else
      value
    end
  end

  def interpolate(context, paths)
    allowed_paths = []
    paths.each do |path|
      path = context.interpolate(path)
      # TODO: Unify usage of '/' - File.join seems to be a mistake, since it won't work on Windows
      # secret/puppet/scope1,scope2 => [[secret], [puppet], [scope1, scope2]]
      segments = path.split('/').map { |segment| segment.split(',') }
      allowed_paths += build_paths(segments) unless segments.empty?
    end
    allowed_paths
  end

  # [[secret], [puppet], [scope1, scope2]] => ['secret/puppet/scope1', 'secret/puppet/scope2']
  def build_paths(segments)
    paths = [[]]
    segments.each do |segment|
      p = paths.dup
      paths.clear
      segment.each do |option|
        p.each do |path|
          paths << path + [option]
        end
      end
    end
    paths.map { |p| File.join(*p) }
  end
end
