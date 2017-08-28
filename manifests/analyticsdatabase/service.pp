# == Class: contrail::database::service
#
# Manage the database service
#

class contrail::analyticsdatabase::service(
  $container_name = undef,
) inherits contrail::params {

  if $version < 4 {

    # Package based deployment

    service {'contrail-database' :
      ensure => running,
      enable => true,
    }
    service {'supervisor-database' :
      ensure => running,
      enable => true,
    }
  } else {

    # Container based deployment

    contrail::container::run { $container_name :
    }
  }
}
