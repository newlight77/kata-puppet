# == Class: tyk::install
#
# Install tyk from tarball.
#
class tyk::install (

  $source_url,
  $tarball,
  $tyk_parent_dir,
  $user,
  $group,
  $port = $::tyk::params::port,
  $token,
  $redis_host,
  $redis_port,
  $redis_pwd,
  $posc_datastore_host,
  $posc_datastore_port,
  $url_baseCoeur_tokenCCU,
  $url_baseCoeur_tokenTyk,
  $tyk_log_dir,
  $tyk_rt_duration,
  $tyk_at_duration,
  $tyk_basic_auth_keys,
  $provision_max_duration_in_minutes,
  $redis_cluster_enable,
  $service_ensure,
  $service_enable,
  $limit_nofile,
  $limit_nproc,
  $policies,
  $tyk_insecure,
  $tyk_binary_dir,
  $rpm_version,
  $tyk_template_dir = "$tyk_binary_dir/templates",
  $pump_rpm_version,
  $token_domain,
  $token_url_path,
  $tyk_debug_provision
) inherits tyk {

  package { 'tyk':
    name   => "tyk-gateway",
    ensure => $rpm_version,
    notify => Service["tyk"]
  }

  file{ "${tyk_parent_dir}":
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    # pour migrer depuis la version ou /tyk etait un lien symbolique
    force   => true
  }->
  file{ "${tyk_parent_dir}/apps":
    ensure  => 'directory',
    recurse => true,
    purge   => true,
    owner  => $user,
    group  => $group
  }->
  file{ "${tyk_parent_dir}/middleware":
    ensure  => 'directory',
    recurse => true,
    purge   => true,
    owner  => $user,
    group  => $group
  }->
  file{ "${tyk_parent_dir}/middleware/checkHmacV1Middleware.js":
    ensure => 'file',
    mode   => '0644',
    owner  => $user,
    group  => $group,
    notify => Service["tyk"],
    source => 'puppet:///modules/tyk/checkHmacV1Middleware.js'
  }-> file{ "${tyk_parent_dir}/middleware/checkTokenV1Middleware.js":
    ensure => 'file',
    mode   => '0644',
    owner  => $user,
    group  => $group,
    notify => Service["tyk"],
	  content => template('tyk/checkTokenV1Middleware.js.erb')
  }->
  file{ "${tyk_parent_dir}/policies":
    ensure  => 'directory',
    recurse => true,
    purge   => true,
    owner  => $user,
    group  => $group
  }->
  file{ "${tyk_parent_dir}/policies/policies.json":
    ensure  => 'file',
    mode    => '0644',
    owner   => $user,
    group   => $group,
    content => template('tyk/policies.json.erb'),
    notify  => Service["tyk"]
  }->
  if ($redis_cluster_enable) {
    file{ "${tyk_parent_dir}/tyk.conf":
      ensure  => 'file',
      mode    => '0644',
      owner   => $user,
      group   => $group,
      content => template('tyk/tyk_cluster.conf.erb'),
      notify  => Service["tyk"]
    }
  } else {
    file{ "${tyk_parent_dir}/tyk.conf":
      ensure  => 'file',
      mode    => '0644',
      owner   => $user,
      group   => $group,
      content => template('tyk/tyk.conf.erb'),
      notify  => Service["tyk"]
    }
  }->
  tyk::tyk_middleware { 'getUserIdCCUMiddleware':
    tyk_parent_dir      => $tyk_parent_dir,
    user                => $user,
    group               => $group,
    posc_datastore_host => $posc_datastore_host,
    posc_datastore_port => $posc_datastore_port,
    service_path        => $url_baseCoeur_tokenCCU
  }->
  tyk::tyk_middleware { 'getUserIdTykMiddleware':
    tyk_parent_dir      => $tyk_parent_dir,
    user                => $user,
    group               => $group,
    posc_datastore_host => $posc_datastore_host,
    posc_datastore_port => $posc_datastore_port,
    service_path        => $url_baseCoeur_tokenTyk
  }

  # tyk-pump installation / configuration
  package { 'tyk-pump':
    ensure => $pump_rpm_version
  }->
  if ($redis_cluster_enable) {
    file { "/opt/tyk-pump/pump.conf":
      ensure  => 'file',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('tyk/tyk_cluster_pump.conf.erb'),
      notify  => Service["tyk-pump"]
    }
  } else {
    file { "/opt/tyk-pump/pump.conf":
      ensure  => 'file',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template('tyk/tyk_pump.conf.erb'),
      notify  => Service["tyk-pump"]
    }
  }->
  file { "/usr/lib/systemd/system/tyk-pump.service":
    ensure  => file,
    content => template('tyk/tyk_pump_service.erb'),
    mode    => '0644',
    notify  => Service["tyk-pump"]
  }~>
  exec { "Tyk-pump systemctl daemon-reload":
    command     => "systemctl daemon-reload",
    path        => $::path,
    refreshonly => true,
    before      => Service["tyk-pump"]
  }

  if $::osfamily == "RedHat" and $::operatingsystem == "CentOS" and $::operatingsystemmajrelease == "7" {

    file { "/etc/init.d/tyk":
      ensure  => absent,
      require => Tyk::Tyk_middleware["getUserIdTykMiddleware"]
    }->
    file { "${tyk_parent_dir}/tyk.start":
      ensure  => file,
      content => template('tyk/tyk_start.erb'),
      mode    => '0744',
      owner   => $user,
      group   => $group
    }->
    file { "${tyk_log_dir}":
      ensure  => directory,
      recurse => true,
      owner   => $user,
      group   => $group
    }->
    file { "${tyk_log_dir}/tyk.log":
      ensure  => file,
      mode    => '0644',
      owner   => $user,
      group   => $group
    }->
    file { "/usr/lib/systemd/system/tyk.service":
      ensure  => file,
      content => template('tyk/tyk_service.erb'),
      mode    => '0644',
      notify  => Service["tyk"]
    }~>
    exec { "Tyk systemctl daemon-reload":
      command     => "systemctl daemon-reload",
      path        => $::path,
      refreshonly => true,
      before      => Service["tyk"]
    }

  } else {

    file { "/etc/init.d/tyk":
      ensure  => file,
      content => template('tyk/tyk_service_6.erb'),
      mode    => '0755',
      owner   => $user,
      group   => $group,
      notify  => Service["tyk"],
      require => tyk_middleware["getUserIdTykMiddleware"],
      before  => Service["tyk"]
    }
  }

  service { 'tyk':
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package['tyk']
  }

  file { "/USR/newtprod/tyk_diff_dates.sh":
    ensure  => file,
    content => template('tyk/tyk_diff_dates.sh.erb'),
    mode    => '0755'
  }

  $tyk_basic_auth_keys.each |$title, $auth| {
    tyk::provision_key { $title :
      api_id       => $auth['api_id'],
      password     => $auth['password'],
      ensure       => $auth['ensure'],
      type_key     => $auth['type_key'],
      allowance    => $auth['allowance'],
      rate         => $auth['rate'],
      per          => $auth['per'],
      expires      => $auth['expires'],
      quota_max    => $auth['quota_max'],
      key          => $auth['key'],
      secret       => $auth['secret'],
      client_id    => $auth['client_id'],
      redirect_uri => $auth['redirect_uri'],
      policy_id    => $auth['policy_id'],
      debug        => $tyk_debug_provision,
      require      => Service['tyk']
    }

    tyk::delete_key { $title :
      api_id    => $auth['api_id'],
      ensure    => $auth['ensure'],
      type_key  => $auth['type_key'],
      key       => $auth['key'],
      client_id => $auth['client_id'],
      debug     => $tyk_debug_provision,
      require  => Service['tyk']
    }
  }

  service { 'tyk-pump':
    ensure => $service_ensure,
    enable => $service_enable
  }
}
