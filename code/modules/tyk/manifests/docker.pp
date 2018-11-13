
# == Class: tyk::docker
#
# Create only conf files to build docker images. It MUST NOT be used elsewhere !
#
class tyk::docker (
  $port                = lookup('tyk_port'),
  $token               = lookup('tyk_token'),
  $tyk_parent_dir      = lookup('tyk_parent_dir'),
  $redis_host          = lookup('tyk_redis_instance1_host'),
  $redis_port          = lookup('redis_port'),
  $redis_pwd           = lookup('redis_pwd'),
  $posc_datastore_host = lookup('posc_datastore_host'),
  $posc_datastore_port = lookup('posc_datastore_port'),
  $tyk_rt_duration     = lookup('tyk_rt_duration'),
  $tyk_at_duration     = lookup('tyk_at_duration'),
  $token_domain        = lookup('tyk_at_duration'),
  $token_url_path      = lookup('tyk_token_url_path')
) {

  $root_docker_conf_dir = "/var/docker_conf"
  $base_dir = "${root_docker_conf_dir}/tyk"
  $user = 'root'
  $group = 'root'
  $url_baseCoeur_tokenCCU = lookup('url_baseCoeur_tokenCCU')
  $url_baseCoeur_tokenTyk = lookup('url_baseCoeur_tokenTyk')
  $tyk_insecure           = lookup('tyk_insecure')
  $tyk_template_dir       = "/opt/tyk-gateway/templates"

  file { ["${root_docker_conf_dir}", "${base_dir}"]:
    ensure => 'directory'
  }

  file { "${base_dir}/apps":
    ensure  => 'directory',
    recurse => true,
    purge   => true
  }

  file { "${base_dir}/middleware":
    ensure  => 'directory',
    recurse => true,
    purge   => true
  }

  # Require:
  #  - port
  #  - token
  #  - tyk_parent_dir
  #  - redis_host
  #  - redis_port
  #  - redis_pwd
  #  - tyk_at_duration
  #  - tyk_rt_duration
  file { "${base_dir}/tyk.conf":
    ensure  => 'file',
    mode    => '0644',
    content => template('tyk/tyk.conf.erb')
  }

  tyk::tyk_middleware { 'getUserIdCCUMiddleware':
    tyk_parent_dir      => $base_dir,
    user                => $user,
    group               => $group,
    posc_datastore_host => $posc_datastore_host,
    posc_datastore_port => $posc_datastore_port,
    service_path        => $url_baseCoeur_tokenCCU,
    should_notify       => false
  } ->
    tyk::tyk_middleware { 'getUserIdTykMiddleware':
      tyk_parent_dir      => $base_dir,
      user                => $user,
      group               => $group,
      posc_datastore_host => $posc_datastore_host,
      posc_datastore_port => $posc_datastore_port,
      service_path        => $url_baseCoeur_tokenTyk,
      should_notify       => false
    } ->
    file { "${base_dir}/middleware/checkHmacV1Middleware.js":
      ensure => 'file',
      mode   => '0644',
      owner  => $user,
      group  => $group,
      source => 'puppet:///modules/tyk/checkHmacV1Middleware.js'
    } ->
    file { "${base_dir}/middleware/checkTokenV1Middleware.js":
      ensure => 'file',
      mode   => '0644',
      owner  => $user,
      group  => $group,
      content => template('tyk/checkTokenV1Middleware.js.erb')
    }

  $default_values = {
     "base_dir" => $base_dir
  }

  create_resources('tyk::docker::app_hmac', hiera_hash('tyk_apps_hmac'), $default_values)
  create_resources('tyk::docker::app_basic', hiera_hash('tyk_apps_basic'), $default_values)
}
