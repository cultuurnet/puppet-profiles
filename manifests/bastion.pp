class profiles::bastion inherits ::profiles {

  Ssh_authorized_key <<| tag == 'bastion' |>>
}
