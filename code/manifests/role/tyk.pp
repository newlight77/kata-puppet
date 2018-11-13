class role::tyk {

  $tyk_parent_dir             = hiera('tyk_parent_dir')

  $tyk_log_dir                = hiera('tyk_log_dir')
  $user                       = hiera('posc_generic_user')

  $tyk_merge_hash             = hiera('tyk_merge_hash', true)

  if($tyk_merge_hash) {
    $tyk_apps_hmac            = hiera_hash('tyk_apps_hmac')
    $tyk_apps_basic           = hiera_hash('tyk_apps_basic')
  } else {
    $tyk_apps_hmac            = hiera('tyk_apps_hmac')
    $tyk_apps_basic           = hiera('tyk_apps_basic')
  }

  class { 'tyk::install':
    tyk_parent_dir                        => $tyk_parent_dir,
    user                                  => lookup('posc_generic_user'),
    group                                 => lookup('posc_generic_group'),
    token                                 => lookup('tyk_token'),
    port                                  => lookup('tyk_port'),
    redis_cluster_enable                  => lookup('tyk_redis_cluster_enable',  { 'default_value' => false } ),
    redis_host                            => lookup('tyk_redis_instance1_host'),
    redis_port                            => lookup('redis_port'),
    redis_pwd                             => lookup('redis_pwd'),
    posc_datastore_host                   => lookup('posc_datastore_host'),
    posc_datastore_port                   => lookup('tomcat_listen_port'),
    url_baseCoeur_tokenCCU                => lookup('url_baseCoeur_tokenCCU'),
    url_baseCoeur_tokenTyk                => lookup('url_baseCoeur_tokenTyk'),
    tyk_log_dir                           => lookup('tyk_log_dir'),
    tyk_rt_duration                       => lookup('tyk_rt_duration'),
    tyk_at_duration                       => lookup('tyk_at_duration'),
    tyk_basic_auth_keys                   => lookup('tyk_basic_auth_keys', { 'merge' => 'hash', 'default_value' => {} } ),
    provision_max_duration_in_minutes     => lookup('provision_max_duration_in_minutes'),
    service_ensure                        => lookup('tyk_service_ensure', { 'default_value' => 'running' } ),
    service_enable                        => lookup('tyk_service_enable', { 'default_value' => 'true' } ),
    limit_nofile                          => lookup('tyk_nofile'),
    limit_nproc                           => lookup('tyk_nproc'),
    policies                              => lookup('tyk_policies'),
    tyk_insecure                          => lookup('tyk_insecure'),
    tyk_binary_dir                        => lookup('tyk_binary_dir'),
    rpm_version                           => lookup('tyk_rpm_version'),
    pump_rpm_version                      => lookup('tyk_pump_rpm_version'),
    token_domain                          => lookup('tyk_token_domain'),
    token_url_path                        => lookup('tyk_token_url_path'),
    tyk_debug_provision                   => lookup('tyk_debug_provision', { 'default_value' => false } )
  }

  create_resources('tyk::app_hmac',    $tyk_apps_hmac)

  create_resources('tyk::app_basic',   $tyk_apps_basic)

}
