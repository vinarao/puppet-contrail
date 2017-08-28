# == Class: contrail::config::install
#
# Install the config service
#

class contrail::config::install (
  $container_name           = undef,
  $container_tag            = undef,
  $container_url            = undef,
) inherits contrail::params {

  if $version < 4 {
    package { 'wget' :
      ensure => latest,
    }
    package { 'python-gevent' :
      ensure => latest,
    } ->
    package { 'contrail-openstack-config' :
      ensure => latest,
    }
  } else {
     contrail::container::install { $container_name :
      container_tag => $container_tag,
      container_url => $container_url,
    }
  }
}
