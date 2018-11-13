# == Function: tyk::app_keyless
#
# Function to configure a keyless tyk app.
#
define tyk::app_keyless (

  $app_name = $title,
  $listen_path,
  $target_url,
  $strip_listen_path = true,
  $tyk_parent_dir = hiera('tyk_parent_dir'),
  $token = hiera('tyk_token'),
  $port = hiera('tyk_port'),
  $user = hiera('posc_generic_user'),
  $group = hiera('posc_generic_group')

) {

  file { "${tyk_parent_dir}/apps/app_${app_name}_keyless.json":
    ensure  => 'file',
    content => template('tyk/app_keyless.json.erb'),
    mode    => '0644',
    owner   => $user,
    group   => $group,
  }~>
  exec { "Tyk reload for ${app_name}_keyless":
    command => "curl -H \"X-Tyk-Authorization: ${token}\" http://localhost:${port}/tyk/reload/",
    path    => $::path,
    user    => $user,
    group   => $group,
    refreshonly => true,
    tries       => 3,
    try_sleep   => 2
  }

}
