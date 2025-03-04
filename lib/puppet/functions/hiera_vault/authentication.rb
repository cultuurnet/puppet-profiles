def authenticate(options, client, context)
  auth_methods = {
    'token'           => method(:token),
    'tls_certificate' => method(:tls)
  }

  auth_methods[options['method']].(options['config'], client, context)
end

def token(config, client, context)
  context.explain { "[hiera-vault] Starting token authentication with config: #{config}" }
  client.auth.token(config['token'])
end

def tls(config, client, context)
  privatekeydir = Puppet.settings['privatekeydir']
  certdir       = Puppet.settings['certdir']
  certname      = config['certname']

  privatekey    = File.read("#{privatekeydir}/#{certname}.pem")
  certificate   = File.read("#{certdir}/#{certname}.pem")

  context.explain { "[hiera-vault] Starting tls_certificate authentication with config: #{config}" }
  client.auth.tls(privatekey + certificate)
end
