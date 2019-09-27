class profiles::udb3::search (
) {

  contain ::profiles
  contain ::profiles::elasticsearch
  contain ::deployment::udb3::search

  Class['profiles::elasticsearch'] -> Class['deployment::udb3::search']
}
