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
    package { 'contrail-setup' :
      ensure => latest,
    }
    exec { 'ldconfig vrouter agent':
      command => '/sbin/ldconfig',
    }
    exec { 'set selinux to permissive' :
      command => '/sbin/setenforce permissive',
    }
    file {'/etc/contrail/supervisord_vrouter_files/contrail-vrouter.rules' :
      ensure  => file,
      source => '/usr/share/openstack-puppet/modules/contrail/files/vrouter/contrail-vrouter.rules',
    } 
    file {'/nova.diff' :
      ensure  => file,
      source => '/usr/share/openstack-puppet/modules/contrail/files/vrouter/nova.diff',
    } ->
    exec { 'patch -p0 < nova.diff':
      command => '/bin/patch -p0 < /nova.diff || /bin/true',
    }
  }
  exec { '/sbin/weak-modules --add-kernel' :
    command => '/sbin/weak-modules --add-kernel',
  }
  group { 'nogroup':
      ensure => present,
  }
  file { '/tmp/contrailselinux.te' :
    ensure  => file,
    source => '/usr/share/openstack-puppet/modules/contrail/files/vrouter/contrailselinux.te',
  } ->
  exec { 'checkmodule -M -m -o /tmp/contrailselinux.mod /tmp/contrailselinux.te':
    command => '/bin/checkmodule -M -m -o /tmp/contrailselinux.mod /tmp/contrailselinux.te',
  } ->
  exec { 'semodule_package -o /tmp/contrailselinux.pp -m /tmp/contrailselinux.mod':
    command => '/bin/semodule_package -o /tmp/contrailselinux.pp -m /tmp/contrailselinux.mod',
  } ->
  exec { 'semodule -i /tmp/contrailselinux.pp':
    command => '/sbin/semodule -i /tmp/contrailselinux.pp',
  }
  #file { '/etc/contrail/contrailhaproxy.te' :
  #  ensure  => file,
  #  source => '/usr/share/openstack-puppet/modules/contrail/files/vrouter/contrailhaproxy.te',
  #} ->
  #exec { 'checkmodule -M -m -o /etc/contrail/contrailhaproxy.mod /etc/contrail/contrailhaproxy.te':
  #  command => '/bin/checkmodule -M -m -o /etc/contrail/contrailhaproxy.mod /etc/contrail/contrailhaproxy.te',
  #} ->
  #exec { 'semodule_package -o /etc/contrail/contrailhaproxy.pp -m /etc/contrail/contrailhaproxy.mod':
  #  command => '/bin/semodule_package -o /etc/contrail/contrailhaproxy.pp -m /etc/contrail/contrailhaproxy.mod',
  #} ->
  #exec { 'semodule -i /etc/contrail/contrailhaproxy.pp':
  #  command => '/sbin/semodule -i /etc/contrail/contrailhaproxy.pp',
  #}
  #file { '/etc/contrail/contrailhaproxy2.te' :
  #  ensure  => file,
  #  source => '/usr/share/openstack-puppet/modules/contrail/files/vrouter/contrailhaproxy2.te',
  #} ->
  #exec { 'checkmodule -M -m -o /etc/contrail/contrailhaproxy2.mod /etc/contrail/contrailhaproxy2.te':
  #  command => '/bin/checkmodule -M -m -o /etc/contrail/contrailhaproxy2.mod /etc/contrail/contrailhaproxy2.te',
  #} ->
  #exec { 'semodule_package -o /etc/contrail/contrailhaproxy2.pp -m /etc/contrail/contrailhaproxy2.mod':
  #  command => '/bin/semodule_package -o /etc/contrail/contrailhaproxy2.pp -m /etc/contrail/contrailhaproxy2.mod',
  #} ->
  #exec { 'semodule -i /etc/contrail/contrailhaproxy2.pp':
  #  command => '/sbin/semodule -i /etc/contrail/contrailhaproxy2.pp',
  #}

  #file { '/opt/contrail/utils/update_dev_net_config_files.py' :
  #  ensure => file,
  #  source => 'puppet:///modules/contrail/vrouter/update_dev_net_config_files.py',
  #}

}
