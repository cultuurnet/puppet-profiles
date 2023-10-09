class profiles::museumpas::cache inherits ::profiles {

  include redis
  realize Firewall['400 accept REDIS traffic']

  include profiles::meilisearch
  realize Firewall['400 accept MEILISEARCH traffic']
}

