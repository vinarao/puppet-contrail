# == Class: contrail::database::install
#
# Install the database service
#

class contrail::analyticsdatabase::install (
  $container_name           = undef,
  $container_tag            = undef,
  $container_url            = undef,
) inherits contrail::params {

  if $version < 4 {
    package { 'wget' :
      ensure => latest,
    } ->
    package { 'java-1.8.0-openjdk' :
      ensure => latest,
    } ->
    package { 'contrail-openstack-database' :
      ensure => latest,
    }
#   } ->
#   exec { 'stop contrail-database service':
#        command => '/bin/systemctl stop contrail-database',
#   } ->
#   exec { 'rm -rf /var/lib/cassandra/data/*' :
#      path => '/bin',
#   }
  } else {
     contrail::container::install { $container_name :
      container_tag => $container_tag,
      container_url => $container_url,
    }
  }
}
