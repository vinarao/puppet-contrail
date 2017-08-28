# == Class: contrail::analytics::service
#
# Manage the analytics service
#

class contrail::analytics::service(
  $container_name = undef,
) inherits contrail::params {

  if $version < 4 {

    # Package based deployment

    service {'redis' :
      ensure => running,
      enable => true,
    } ->
    service {'supervisor-analytics' :
      ensure => running,
      enable => true,
    }
  } else {

    # Container based deployment

    contrail::container::run { $container_name :
    }
  }
}
