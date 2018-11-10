define tyk::docker::app_hmac (
  $app_name = $title,
  $listen_path,
  $target_url,
  $api_id,
  $with_hmac_v1 = true,
  $with_middleware = false,
  $whitelist = {},
  $with_basic = false,
  $base_dir,
  $hmac_allowed_clock_skew = 120000
) {

  $tyk_parent_dir = hiera('tyk_parent_dir')

  file { "${base_dir}/apps/app_${app_name}_hmac.json":
    ensure  => 'file',
    content => template('tyk/app_hmac.json.erb'),
    mode    => '0644'
  }
}
