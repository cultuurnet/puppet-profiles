class profiles::museumpas::cache inherits ::profiles {

  realize Firewall['400 accept redis traffic']

  include redis
  include profiles::meilisearch
}

