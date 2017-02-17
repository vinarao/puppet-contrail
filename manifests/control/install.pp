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
    ensure => latest,
  }
  package { 'contrail-openstack-control' :
    ensure => latest,
  }

}
