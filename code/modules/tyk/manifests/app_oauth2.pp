# == Function: tyk::app_auth
#
# Function to configure a tyk app with oAuth 2.
#
define tyk::app_oauth2 (

  $app_name = $title,
  $listen_path,
  $target_url,
  $api_id,
  $whitelist = {},
  $with_middleware = true,
  $tyk_parent_dir = hiera('tyk_parent_dir'),
  $token = hiera('tyk_token'),
  $port = hiera('tyk_port'),
  $auth_login_redirect = hiera('auth_login_redirect'),
  $oauth2_on_keychange_url = hiera('oauth2_on_keychange_url'),
  $user = hiera('posc_generic_user'),
  $group = hiera('posc_generic_group'),
  $tyk_shared_secret = hiera('tyk_shared_secret')
) {

  file { "${tyk_parent_dir}/apps/app_${app_name}_oauth2.json":
    ensure  => 'file',
    content => template('tyk/app_oauth2.json.erb'),
    mode    => '0644',
    owner   => $user,
    group   => $group,
    require => Class['::tyk::install'],
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
