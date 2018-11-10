define tyk::docker::app_auth (
  $app_name = $title,
  $listen_path,
  $target_url,
  $api_id = "1",
  $with_middleware = true,
  $whitelist = {},
  $base_dir,
  $use_param = false,
  $param_name = undef
) {

  $tyk_parent_dir = hiera('tyk_parent_dir')

  file { "${base_dir}/apps/app_${app_name}_auth.json":
    ensure  => 'file',
    content => template('tyk/app_auth.json.erb'),
    mode    => '0644'
  }
}
