# == Class: contrail::analytics::install
#
# Install the analytics service
#

class contrail::analytics::install (
  $container_name           = undef,
  $container_tag            = undef,
  $container_url            = undef,
) inherits contrail::params {

  if $version < 4 {
    package { 'python-redis' :
      ensure => absent,
    } ->
    package { 'python-gevent' :
      ensure => latest,
    } ->
    package { 'contrail-openstack-analytics' :
      ensure => latest,
    }
  } else {
    contrail::container::install { $container_name :
      container_tag => $container_tag,
      container_url => $container_url,
    }
  }
}
