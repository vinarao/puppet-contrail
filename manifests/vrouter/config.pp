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
  $vhost_ip               = $::ipaddress_eth1,
  $discovery_ip           = '127.0.0.1',
  $device                 = 'eth0',
  $kmod_path              = "/lib/modules/${::kernelrelease}/extra/net/vrouter/vrouter.ko",
  $compute_device         = 'eth0',
  $mask                   = '24',
  $netmask                = '255.255.255.0',
  $gateway                = '127.0.0.1',
  $vgw_public_subnet      = undef,
  $vgw_interface          = undef,
  $macaddr                = $::macaddress,
  $vrouter_agent_config   = {},
  $vrouter_nodemgr_config = {},
) {

  include ::contrail::vnc_api
  include ::contrail::ctrl_details
  include ::contrail::service_token

  $ip_to_steal = getvar(regsubst("ipaddress_${compute_device}", '[.-]', '_', 'G'))
  $control_network_dev = { "NETWORKS/control_network_ip" => { value => $ip_to_steal} }
  $temphash = delete($vrouter_agent_config, "NETWORKS/control_network_ip")
  $new_vrouter_agent_config = merge($temphash, $control_network_dev)

  validate_hash($new_vrouter_agent_config)
  validate_hash($vrouter_nodemgr_config)

  create_resources('contrail_vrouter_agent_config', $new_vrouter_agent_config)
  create_resources('contrail_vrouter_nodemgr_config', $vrouter_nodemgr_config)

  file { '/etc/contrail/agent_param' :
    ensure  => file,
    content => template('contrail/vrouter/agent_param.erb'),
  }

  file { '/etc/contrail/default_pmac' :
    ensure  => file,
    content => $macaddr,
  }

  file { '/etc/contrail/vrouter_nodemgr_param' :
    ensure  => file,
    content => "DISCOVERY=${discovery_ip}",
  }


  exec { '/bin/python /opt/contrail/utils/update_dev_net_config_files.py' :
    path => '/usr/bin',
    command => "/bin/python /opt/contrail/utils/update_dev_net_config_files.py \
                 --vhost_ip ${ip_to_steal} \
                 --dev ${device} \
                 --compute_dev ${device} \
                 --netmask ${netmask} \
                 --gateway ${gateway} \
                 --cidr ${vhost_ip}/${mask} \
                 --mac ${macaddr}",
    creates => '/etc/sysconfig/network-scripts/ifcfg-vhost0'
  }

  exec { 'save ifcfg-ethX unless it has an ip':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "cp /etc/sysconfig/network-scripts/ifcfg-${compute_device} /etc/sysconfig/network-scripts/ifcfg-${compute_device}.contrailsave",
    unless  => "grep -q IPADDR /etc/sysconfig/network-scripts/ifcfg-${compute_device}",
    creates => "/etc/sysconfig/network-scripts/ifcfg-${compute_device}.contrailsave",
    logoutput => true
  }

  exec { 'copy contrailsave ifcfg to running':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "cp /etc/sysconfig/network-scripts/ifcfg-${compute_device}.contrailsave /etc/sysconfig/network-scripts/ifcfg-${compute_device}",
    onlyif  => [ "grep IPADDR /etc/sysconfig/network-scripts/ifcfg-${compute_device}",
                 "ls /etc/sysconfig/network-scripts/ifcfg-${compute_device}.contrailsave",
                 "ls /etc/sysconfig/network-scripts/ifcfg-vhost0" ],
    logoutput => true,
    notify => Exec['restart network devices'],
  }

  exec { 'restart network devices':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "systemctl stop supervisor-vrouter && \
                rmmod vrouter && \
                ifdown ${compute_device} && \
                ifup ${compute_device} && \
                systemctl start supervisor-vrouter",
    #unless  => "ping -c3 ${discovery_ip}",
    logoutput => true
  }
}
