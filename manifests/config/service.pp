# == Class: contrail::config::service
#
# Manage the config service
#

class contrail::config::service(
  $container_name = undef,
) inherits contrail::params {

  if $version < 4 {

    # Package based deployment
    service {'supervisor-config' :
      ensure => running,
      enable => true,
    }
  } else {

    # Container based deployment

    contrail::container::run { $container_name :
    }
  }
}

