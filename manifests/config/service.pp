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
    $db_dir = '/var/lib/configdb'
    $logs_dir = '/var/log/contrail/controller'
    $zk_dir = '/var/lib/config_zookeeper_data'
    $zk_logs_dir = '/var/log/contrail/config_zookeeper'

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

