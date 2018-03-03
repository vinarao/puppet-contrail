# == Class: contrail::webui::install
#
# Install the webui service
#
# === Parameters:
#
# [*package_name*]
#   (optional) Package name for webui
#
class contrail::webui::install (
) {
  package { 'yum-plugin-versionlock' :
    ensure => 'latest',
  } ->
  exec { 'lock java version':
    command => 'yum versionlock java-1.8.0-openjdk-*',
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
  } ->
  package { 'contrail-openstack-webui' :
    ensure => latest,
  }
}
