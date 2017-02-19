# == Class: contrail::vrouter::install
#
# Install the vrouter service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for vrouter
#
class contrail::vrouter::install (
  $is_dpdk = undef,
) {
  if $is_dpdk {
    package { 'liburcu2':
      ensure => installed,
    }
  }
  package { 'contrail-openstack-vrouter' :
    ensure => latest,
  }

  #file { '/opt/contrail/utils/update_dev_net_config_files.py' :
  #  ensure => file,
  #  source => 'puppet:///modules/contrail/vrouter/update_dev_net_config_files.py',
  #}

}
