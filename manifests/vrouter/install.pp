# == Class: contrail::vrouter::install
#
# Install the vrouter service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for vrouter
#
class contrail::vrouter::install (
  $is_dpdk = undef,
) {

  if !$is_dpdk {
    package { 'contrail-openstack-vrouter' :
      ensure => latest,
    }
  } else {
    package { 'contrail-lib' :
      ensure => latest,
    }
    package { 'contrail-nodemgr' :
      ensure => latest,
    }
    package { 'contrail-vrouter-agent' :
      ensure => latest,
    }
    package { 'contrail-utils' :
      ensure => latest,
    }
    file { '/etc/contrail/vnagent_ExecStartPost.sh' :
      ensure => file,
      source => '/opt/contrail/bin/vnagent_ExecStartPost.sh',
    }
    exec { 'ldconfig vrouter agent':
      command => '/sbin/ldconfig',
    }
  }

  #file { '/opt/contrail/utils/update_dev_net_config_files.py' :
  #  ensure => file,
  #  source => 'puppet:///modules/contrail/vrouter/update_dev_net_config_files.py',
  #}

}
