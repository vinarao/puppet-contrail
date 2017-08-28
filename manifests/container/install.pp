
define contrail::container::install (
  $container_file  = undef,
  $container_name  = $title,
  $container_tag   = undef,
  $container_url   = undef,
  $timeout         = 3600,
) {

  include ::contrail::container::install_tools

  $local_file = $container_file ? {
    undef   => "/tmp/${container_name}.tar.gz",
    default => $container_file,
  }
  $container_image = $container_tag ? {
    undef   => $container_name,
    ''      => $container_name,
    default => "${container_name}:${container_tag}",
  }
  $check_docker_image_cmd = "docker images | awk '{print(\$1\":\"\$2)}' | grep -q '${container_image}'"
  $repo_url = $::contrail_repo_url ? {
    undef   => undef,
    ''      => undef,
    default => $::contrail_repo_url,
  }
  if ($container_url and $container_url != '') or $repo_url {
    if $container_tag and $container_tag != '' {
      $url = $container_url ? {
        undef   => "${repo_url}/${container_name}-${container_tag}.tar.gz",
        ''      => "${repo_url}/${container_name}-${container_tag}.tar.gz",
        default => "${container_url}/${container_name}-${container_tag}.tar.gz",
      }
      $wget_cmd = "wget --tries 5 --waitretry=2 --retry-connrefused -O ${local_file} ${url}"
    } else {
      $base_url = $container_url ? {
        undef   => $repo_url,
        ''      => $repo_url,
        default => $container_url,
      }
      $get_version_cmd = "curl -L ${base_url} 2>&1 | grep '${container_name}' | grep -o '[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+-[0-9]\\+' | sort -n -r | head -n 1"
      $wget_cmd = "wget --tries 5 --waitretry=2 --retry-connrefused -O ${local_file} ${base_url}/${container_name}-$(${get_version_cmd}).tar.gz"
    }
    exec { "Dowload ${container_name}":
      path    => '/usr/bin:/usr/sbin:/bin',
      command => $wget_cmd,
      onlyif  => "[ ! -f ${local_file} ]",
      unless  => $check_docker_image_cmd,
      timeout => $timeout,
      require => Service['docker'],
      before  => Exec["pull ${container_name} container to docker"],
    }
  }
  exec { "pull ${container_name} container to docker" :
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "docker load -i ${local_file}",
    unless  => $check_docker_image_cmd,
    timeout => $timeout,
    require => Service['docker'],
  }
}

