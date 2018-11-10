# == Function: tyk::app_hmac
#
# Function to configure a hmac tyk app.
#
define tyk::app_hmac (

  $app_name = $title,
  $listen_path,
  $target_url,
  $api_id,
  $with_hmac_v1 = true,
  $with_middleware = false,
  $whitelist = {},
  $tyk_parent_dir = hiera('tyk_parent_dir'),
  $token = hiera('tyk_token'),
  $port = hiera('tyk_port'),
  $user = hiera('posc_generic_user'),
  $group = hiera('posc_generic_group'),
  $hmac_allowed_clock_skew = hiera('tyk_hmac_allowed_clock_skew')
  
) {

  file { "${tyk_parent_dir}/apps/app_${app_name}_hmac.json":
    ensure  => 'file',
    content => template('tyk/app_hmac.json.erb'),
    mode    => '0644',
    owner   => $user,
    group   => $group,
    require => Class['::tyk::install'],
  }~>
  exec { "Tyk reload for ${app_name}_hmac":
    command     => "curl -H \"X-Tyk-Authorization: ${token}\" http://localhost:${port}/tyk/reload/",
    path        => $::path,
    user        => $user,
    group       => $group,
    refreshonly => true,
    tries       => 3,
    try_sleep   => 2
  }

}
