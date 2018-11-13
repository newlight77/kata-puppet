# == Function: tyk::app_auth
#
# Function to configure a tyk app with token authentication.
#
define tyk::app_auth (

  $app_name = $title,
  $listen_path,
  $target_url,
  $api_id = "1",
  $with_middleware = true,
  $whitelist = {},
  $tyk_parent_dir = hiera('tyk_parent_dir'),
  $token = hiera('tyk_token'),
  $port = hiera('tyk_port'),
  $user = hiera('posc_generic_user'),
  $group = hiera('posc_generic_group'),
  $use_param = false,
  $param_name = undef
) {

  file { "${tyk_parent_dir}/apps/app_${app_name}_auth.json":
    ensure  => 'file',
    content => template('tyk/app_auth.json.erb'),
    mode    => '0644',
    owner   => $user,
    group   => $group,
  }~>
  exec { "Tyk reload for ${app_name}_auth":
    command => "curl -H \"X-Tyk-Authorization: ${token}\" http://localhost:${port}/tyk/reload/",
    path    => $::path,
    user    => $user,
    group   => $group,
    refreshonly => true,
    tries       => 3,
    try_sleep   => 2
  }

}
