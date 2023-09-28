class profiles::nfs (
  String           $mountpoint,
  String           $fs_type       = 'nfs4',
  Optional[String] $mount_options = undef,
  String           $owner         = 'root',
  String           $group         = 'root'
) {

  include ::profiles

  realize Package['nfs-common']
}
