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
    $db_dir = '/var/lib/analyticsdb'
    $logs_dir = '/var/log/contrail/analyticsdb'
    $zk_dir = '/var/lib/analyticsdb_zookeeper_data'
    $zk_logs_dir = '/var/log/contrail/analyticsdb_zookeeper'
    $mounts = [
      "${db_dir}:/var/lib/cassandra",
      "${logs_dir}:/var/log/contrail",
      "${zk_dir}:/var/lib/zookeeper",
      "${zk_logs_dir}:/var/log/zookeeper",
    ]
    file { [$db_dir, $logs_dir, $zk_dir, $zk_logs_dir, ] :
      ensure => 'directory',
    } ->
    contrail::container::run { $container_name :
      mounts => $mounts,
    }
  }
}
