# == Class: contrail::vrouter::config
#
# Configure the vrouter service
#
# === Parameters:
#
# [*vhost_ip*]
#   (optional) IP of the vrouter agent
#   Defaults to '127.0.0.1'
#
# [*discovery_ip*]
#   (optional) IP of the discovery service
#   Defaults to '127.0.0.1'
#
# [*device*]
#   (optional) Network device
#   Defaults to 'eth0'
#
# [*kmod_path*]
#   (optional) full path for vrouter.ko
#   Defaults to '/lib/modules/${::kernelrelease}/extra/net/vrouter/vrouter.ko
#
# [*compute_device*]
#   (optional) Network device for Openstack compute
#   Defaukts to 'eth0;
#
# [*mask*]
#   (optional) Netmask in CIDR form
#   Defaults '24'
#
# [*netmask*]
#   (optional) Full netmask
#   Defaults '255.255.255.0'
#
# [*gateway*]
#   (optional) Gateway IP address
#   Defaults to '127.0.0.1'
#
# [*vgw_public_subnet*]
#   (optional) Virtual Gateway public subnet
#   Defaults to undef
#
# [*vgw_interface*]
#   (optional) Virtual Gateway interface
#   Defaults to undef
#
# [*macaddr*]
#   (optional) Mac address
#   Defaults to $::macaddr
#
# [*vrouter_agent_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-vrouter-agent.conf
#   Defaults {}
#
# [*vrouter_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-vrouter-nodemgr.conf
#   Defaults {}
#
class contrail::vrouter::config (
  $step                   = hiera('step'),
  $compute_device         = 'eth0',
  $discovery_ip           = '127.0.0.1',
  $device                 = 'eth0',
  $gateway                = '127.0.0.1',
  $is_tsn                 = undef,
  $is_dpdk                = undef,
  $kmod_path              = "vrouter",
  $macaddr                = $::macaddress,
  $mask                   = '24',
  $netmask                = '255.255.255.0',
  $keystone_config        = {},
  $vhost_ip               = '127.0.0.1',
  $vgw_public_subnet      = undef,
  $vgw_interface          = undef,
  $vrouter_agent_config   = {},
  $vrouter_nodemgr_config = {},
  $vnc_api_lib_config     = {},
) {

#  include ::contrail::vnc_api
#  include ::contrail::ctrl_details
#  include ::contrail::service_token
#
  file { '/etc/contrail/contrail-keystone-auth.conf':
    ensure => file,
  }
  if $step == 1 and $is_dpdk {
    file_line { 'net.ipv4.tcp_keepalive_time = 5':
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv4.tcp_keepalive_time = 5',
    } ->
    file_line { 'net.ipv4.tcp_keepalive_probes = 5':
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv4.tcp_keepalive_probes = 5',
    } ->
    file_line { 'net.ipv4.tcp_keepalive_intvl = 1':
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'net.ipv4.tcp_keepalive_intvl = 1',
    } ->
    file_line { 'vm.nr_hugepages = 64480':
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'vm.nr_hugepages = 64480',
    } ->
    file_line { 'vm.max_map_count = 128960':
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'vm.max_map_count = 128960',
    } ->
    file_line { 'kernel.core_pattern = /var/crashes/core.%e.%p.%h.%t':
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => 'kernel.core_pattern = /var/crashes/core.%e.%p.%h.%t',
    } ->
    exec {'/sbin/sysctl --system':
      command => '/sbin/sysctl --system',
    }
    file {'/etc/contrail/vnagent_ExecStartPost.sh':
      ensure => file,
      source => '/etc/contrail/dpdk/vnagent_ExecStartPost.sh',
    }
    file {'/etc/contrail/vnagent_ExecStartPre.sh':
      ensure => file,
      source => '/etc/contrail/dpdk/vnagent_ExecStartPre.sh',
    }
    file {'/etc/contrail/vnagent_ExecStopPost.sh':
      ensure => file,
      source => '/etc/contrail/dpdk/vnagent_ExecStopPost.sh',
    }
    file {'/etc/contrail/supervisord_vrouter_files/contrail-vrouter-dpdk.ini':
      ensure => file,
      source => '/etc/contrail/dpdk/contrail-vrouter-dpdk.ini',
    }
    file_line { 'patch vrouter-functions.sh':
      ensure => present,
      path   => '/opt/contrail/bin/vrouter-functions.sh',
      line   => '    eval `cat ${AGENT_CONF} | grep \'^[a-zA-Z]\'| sed \'s/[[:space:]]//g\'`',
      match  => '^\ \ \ \ eval `cat \${AGENT_CONF} | grep \'^[a-zA-Z]\'`',
    }
  }

  validate_hash($vrouter_agent_config)
  validate_hash($vrouter_nodemgr_config)
  validate_hash($keystone_config)

  $contrail_keystone_config = { 'path' => '/etc/contrail/contrail-keystone-auth.conf' }
  $contrail_vrouter_agent_config = { 'path' => '/etc/contrail/contrail-vrouter-agent.conf' }
  $contrail_vrouter_nodemgr_config = { 'path' => '/etc/contrail/contrail-vrouter-nodemgr.conf' }
  $contrail_vnc_api_lib_config = { 'path' => '/etc/contrail/vnc_api_lib.ini' }

  create_ini_settings($keystone_config, $contrail_keystone_config)
  create_ini_settings($vrouter_agent_config, $contrail_vrouter_agent_config)
  create_ini_settings($vrouter_nodemgr_config, $contrail_vrouter_nodemgr_config)
  create_ini_settings($vnc_api_lib_config, $contrail_vnc_api_lib_config)

  exec { '/sbin/weak-modules --add-kernel' :
    command => '/sbin/weak-modules --add-kernel',
  }
  if $step == 5 and !$is_tsn {
    file { '/nova_libvirt.patch' :
      ensure  => file,
      content => template('contrail/vrouter/nova_libvirt.patch.erb'),
    } ->
    file_line { 'patch nova':
      ensure => present,
      path   => '/usr/lib/python2.7/site-packages/nova/virt/libvirt/designer.py',
      line   => '    conf.script = None',
      match  => '^\ \ \ \ conf.script\ \=',
    }
  }

  file { '/etc/contrail/agent_param' :
    ensure  => file,
    content => template('contrail/vrouter/agent_param.erb'),
  }

  file { '/etc/contrail/default_pmac' :
    ensure  => file,
    content => $macaddr,
  }

  file { '/etc/contrail/contrailnetns.te' :
    ensure  => file,
    source => '/usr/share/openstack-puppet/modules/contrail/files/vrouter/contrailnetns.te',
  } ->
  exec { 'checkmodule -M -m -o /etc/contrail/contrailnetns.mod /etc/contrail/contrailnetns.te':
    command => '/bin/checkmodule -M -m -o /etc/contrail/contrailnetns.mod /etc/contrail/contrailnetns.te',
  } ->
  exec { 'semodule_package -o /etc/contrail/contrailnetns.pp -m /etc/contrail/contrailnetns.mod':
    command => '/bin/semodule_package -o /etc/contrail/contrailnetns.pp -m /etc/contrail/contrailnetns.mod',
  } ->
  exec { 'semodule -i /etc/contrail/contrailnetns.pp':
    command => '/sbin/semodule -i /etc/contrail/contrailnetns.pp',
  }

  file { '/etc/contrail/vrouter_nodemgr_param' :
    ensure  => file,
    content => "DISCOVERY=${discovery_ip}",
  }
  if $::ipaddress_vhost0 != $vhost_ip {
    file { '/opt/contrail/utils/update_dev_net_config_files.py':
      ensure => file,
      source => '/usr/share/openstack-puppet/modules/contrail/files/vrouter/update_dev_net_config_files.py',
    } -> 
    exec { '/bin/python /opt/contrail/utils/update_dev_net_config_files.py' :
      path => '/usr/bin',
      command => "/bin/python /opt/contrail/utils/update_dev_net_config_files.py \
                   --vhost_ip ${vhost_ip} \
                   --dev ${device} \
                   --compute_dev ${device} \
                   --netmask ${netmask} \
                   --gateway ${gateway} \
                   --cidr ${vhost_ip}/${mask} \
                   --mac ${macaddr}",
    }
  }
}
