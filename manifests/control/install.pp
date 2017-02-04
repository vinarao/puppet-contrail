# == Class: contrail::control::install
#
# Install the control service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for control
#
class contrail::control::install (
) {

  package { 'boost' :
    ensure => installed,
  }
  package { 'contrail-openstack-control' :
    ensure => installed,
  }

}
