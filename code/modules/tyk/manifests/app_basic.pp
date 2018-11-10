# == Function: tyk::app_basic
#
# Function to configure a tyk app with Basic authentication.
#
define tyk::app_basic (

  $app_name = $title,
  $listen_path,
  $target_url,
  $api_id,
  $with_middleware = false,
  $tyk_parent_dir = hiera('tyk_parent_dir'),
  $token = hiera('tyk_token'),
  $port = hiera('tyk_port'),
  $user = hiera('posc_generic_user'),
  $group = hiera('posc_generic_group')
  
) {

  file { "${tyk_parent_dir}/apps/app_${app_name}_basic.json":
    ensure  => 'file',
    content => template('tyk/app_basic.json.erb'),
    mode    => '0644',
    owner   => $user,
    group   => $group,
    require => Class['::tyk::install'],
  }~>
  exec { "Tyk reload for ${app_name}_basic":
    command => "curl -H \"X-Tyk-Authorization: ${token}\" http://localhost:${port}/tyk/reload/",
    path    => $::path,
    user    => $user,
    group   => $group,
    refreshonly => true,
    tries       => 3,
    try_sleep   => 2
  }

}
