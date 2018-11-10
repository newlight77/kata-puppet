define tyk::docker::app_keyless (
  $app_name = $title,
  $listen_path,
  $target_url,
  $strip_listen_path = true,
  $base_dir = "/var/docker_conf"
) {

  $tyk_parent_dir = hiera('tyk_parent_dir')

  file { "${base_dir}/apps/app_${app_name}_keyless.json":
    ensure  => 'file',
    content => template('tyk/app_keyless.json.erb'),
    mode    => '0644'
  }
}
