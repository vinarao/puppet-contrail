# == Class: contrail::params
#
class contrail::params(
  $analytics                  = {},
  $analyticsdatabase          = {},
  $container_tag              = hiera('contrail::container::tag', undef),
  $container_url              = hiera('contrail::container::url', undef),
  $config                     = {},
  $control                    = {},
  $database                   = {},
  $webui                      = {},
  $version                    = 4,
) {
  $control_package_name = ['contrail-openstack-control']
  $config_package_name = ['contrail-openstack-config']
  $analytics_package_name = ['contrail-openstack-analytics']
  $webui_package_name = ['contrail-openstack-webui']
  $database_package_name = ['contrail-openstack-database']
  $vrouter_package_name = ['contrail-openstack-vrouter']

  if $::osfamily != 'RedHat' {
    $container_ver=downcase("${::operatingsystem}${::operatingsystemrelease}")
  } else {
    $container_ver='redhat7'
  }

  $analytics_container_name = "contrail-analytics-${container_ver}"
  $analyticsdb_container_name = "contrail-analyticsdb-${container_ver}"
  $controller_container_name = "contrail-controller-${container_ver}"
}
