class role::redis{
  $redis_version                  = lookup('redis_version')
  $service_enable                 = lookup('redis_service_enable', { 'default_value' => true })
  $service_running                = lookup('redis_service_running', { 'default_value' => true })
  $redisport                      = lookup('redis_port')
  $redis_src_dump_dir             = lookup('redis_src_dump_dir')
  $redis_target_dump_dir          = lookup('redis_target_dump_dir')
  $redis_dump_filename_prefix     = lookup('redis_dump_filename_prefix')
  $redis_dump_filename_ext        = lookup('redis_dump_filename_ext')
  $redis_dump_max_retention       = lookup('redis_dump_max_retention')
  $redis_dump_appendonly_filename = lookup('redis_dump_appendonly_filename')
  $save_script_filename           = "save_redis_dump.sh"
  $save_script_filepath           = "/USR/newtprod/${save_script_filename}"
  $redis_trib_version             = lookup('redis_trib_version', { 'default_value' => false })
  $redis_cluster_enable           = lookup('redis_cluster_enable', { 'default_value' => false })
  $redis_memory                   = lookup('redis_memory_limit')
  $redis_mempolicy                = lookup('redis_mempolicy')
  $redis_user                     = lookup('posc_generic_user')
  $redis_group                    = lookup('posc_generic_group')
  $redis_dir                      = '/VAR/redis'
  $redis_run_dir                  = "${redis_dir}/run"
  if ($redis_cluster_enable) {$redis_server_name = 'cluster-instance1'} else {$redis_server_name = 'instance1'}
  if ($redis_cluster_enable) {$redis_slave_server_name = 'cluster-instance2'}

  exec {'Fix non root redis':
    command     => "chown -R $redis_user.$redis_group ${redis_dir}/redis_$redis_server_name",
    onlyif      => "test `/usr/bin/stat ${redis_dir}/redis_$redis_server_name/dump.rdb --printf \"%G\"` != \"prod\"",
    path        => '/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin',
    require     => Class['redis::install'],
    before      => Service["redis-server_$redis_server_name"]
  }

  exec {'Fix non root redis 2':
    command     => "chown -R $redis_user.$redis_group ${redis_dir}/log",
    onlyif      => "test `/usr/bin/stat ${redis_dir}/log/redis_$redis_server_name.log --printf \"%G\"` != \"prod\"",
    path        => '/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin',
    require     => File["${redis_dir}/log"],
    before      => Service["redis-server_$redis_server_name"]
  }

  exec {'Fix non root redis_cluster':
    command     => "chown -R $redis_user.$redis_group ${redis_dir}/redis_$redis_server_name",
    onlyif      => "test `/usr/bin/stat ${redis_dir}/redis_$redis_server_name/nodes-cluster.conf --printf \"%G\"` != \"prod\"",
    path        => '/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin',
    require     => Class['redis::install'],
    before      => Service["redis-server_$redis_server_name"]
  }

  exec {'Fix non root redis config':
    command     => "chmod 644 /etc/redis_$redis_server_name.conf",
    onlyif      => "test `/usr/bin/stat /etc/redis_$redis_server_name.conf --printf \"%a\"` != \"644\"",
    path        => '/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin',
    require     => Class['redis::install'],
    before      => Service["redis-server_$redis_server_name"]
  }

  class { 'redis::install':
    redis_version => $redis_version,
    redis_package => true,
    redis_user    => $redis_user,
    redis_group   => $redis_group
  }

  file { "${redis_target_dump_dir}":
    ensure => 'directory',
    mode   => '0755'
  }->
  file{ "${save_script_filepath}":
    ensure  => file,
    content => template("role/redis/${save_script_filename}.erb"),
    owner   => root,
    group   => root,
    mode    => '0755'
  }->
  cron{ 'run-saveredis':
    command => "${save_script_filepath} > /dev/null 2>&1",
    user    => $user,
    target  => $user,
    hour  => '*/4',
    minute => '0'
  }

  if ($redis_trib_version) {
    Package { 'redis-trib':
      ensure => $redis_trib_version
    }
  }

  file { $redis_dir:
    ensure => 'directory',
    mode   => '0755',
    owner  => $redis_user,
    group  => $redis_group
  }->
  file { "${redis_dir}/log":
    ensure => 'directory',
    mode   => '0755',
    owner  => $redis_user,
    group  => $redis_group,
    before => Service["redis-server_$redis_server_name"]
  }

  file { "${redis_run_dir}":
    ensure  => 'directory',
    mode    => '0755',
    owner   => $redis_user,
    group   => $redis_group,
    require => File[$redis_dir],
    before  => Service["redis-server_$redis_server_name"]
  }

  redis::server {
    $redis_server_name:
      redis_memory        => $redis_memory,
      redis_mempolicy     => $redis_mempolicy,
      redis_ip            => '0.0.0.0',
      redis_port          => $redisport,
      redis_loglevel      => 'notice',
      redis_nr_dbs        => lookup('redis_nr_dbs', { 'default_value' => 1 }),
      running             => $service_running,
      enabled             => $service_enable,
      cluster_enabled     => $redis_cluster_enable,
      redis_dir           => $redis_dir,
      redis_append_enable => lookup('redis_append_enable', { 'default_value' => false }),
      save                => lookup('redis_save', { 'default_value' => [] }),
      subscribe           => Class['redis::install'],
      redis_log_dir       => "${redis_dir}/log",
      redis_run_dir       => "${redis_run_dir}"
  }

  if ($redis_cluster_enable) {
    redis::server {
      $redis_slave_server_name:
        redis_memory        => $redis_memory,
        redis_mempolicy     => $redis_mempolicy,
        redis_ip            => '0.0.0.0',
        redis_port          => $redisport + 1,
        redis_loglevel      => 'notice',
        redis_nr_dbs        => lookup('redis_nr_dbs', { 'default_value' => 1 }),
        running             => $service_running,
        enabled             => $service_enable,
        cluster_enabled     => $redis_cluster_enable,
        redis_dir           => $redis_dir,
        redis_append_enable => lookup('redis_append_enable', { 'default_value' => false }),
        save                => lookup('redis_save', { 'default_value' => [] }),
        subscribe           => Class['redis::install'],
        redis_log_dir       => "${redis_dir}/log",
        redis_run_dir       => "${redis_run_dir}"
    }
  }

}
