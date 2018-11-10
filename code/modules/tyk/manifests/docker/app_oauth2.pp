# == Function: tyk::app_auth
#
# Function to configure a tyk app with oAuth 2.
#
define tyk::docker::app_oauth2 (
  $app_name = $title,
  $listen_path,
  $target_url,
  $api_id,
  $whitelist = {},
  $with_middleware = true,
  $base_dir,
  $auth_login_redirect = hiera('auth_login_redirect'),
  $oauth2_on_keychange_url = hiera('oauth2_on_keychange_url')
) {

  $tyk_parent_dir = hiera('tyk_parent_dir')

  file { "${base_dir}/apps/app_${app_name}_oauth2.json":
    ensure  => 'file',
    content => template('tyk/app_oauth2.json.erb'),
    mode    => '0644'
  }
}
