# == Class: contrail::vrouter::service
#
# Manage the vrouter service
#
class contrail::vrouter::service(
  $step = hiera('step'),
  $cidr,
  $gateway,
  $host_ip,
  $is_tsn,
  $physical_interface,
  $vhost_ip,
) {

  service {'supervisor-vrouter' :
    ensure => running,
    enable => true,
  }
  if $step == 5 and !$is_tsn {
    exec { 'restart nova compute':
      path => '/bin',
      command => "systemctl restart openstack-nova-compute",
    }
  }
}
