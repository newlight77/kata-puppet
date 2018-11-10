# == Function: tyk::app_basic
#
# Function to configure a tyk app with Basic authentication.
#
define tyk::docker::app_basic (
  $app_name = $title,
  $listen_path,
  $target_url,
  $api_id,
  $with_middleware = false,
  $base_dir
) {

  $tyk_parent_dir = hiera('tyk_parent_dir')

  file { "${base_dir}/apps/app_${app_name}_basic.json":
    ensure  => 'file',
    content => template('tyk/app_basic.json.erb'),
    mode    => '0644'
  }
}
