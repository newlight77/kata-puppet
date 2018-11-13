class user::install (
    $username,
    $full_name,
    $authorized_keys = [],
    $password,
    $password_min_age,
    $password_max_age,
    $shell,
    $group,
    $has_sudo,
    $private_key,
    $public_key,
    $ssh_target_key_name,
    $home = "/home/${username}",
    $internal_group
) {

    $ssh_dir        = "${home}/.ssh"

    group { $group:
      ensure => 'present',
      before => User[$username]
    }->
    user { $username:
      ensure           => 'present',
      home             => $home,
      comment          => $full_name,
      groups           => $group,
      password         => $password,
      password_max_age => $password_min_age,
      password_min_age => $password_max_age,
      shell            => $shell
    }->
    file { $home:
      ensure => 'directory',
      mode   => '0700',
      owner  => $username,
      group  => $group
    }

    file { "${ssh_dir}":
      ensure => 'directory',
      mode   => '0700',
      owner  => $username,
      group  => $group
    }->
      file { "${ssh_dir}/authorized_keys":
        content => template("user/authorized_keys.erb"),
        mode    => '0600',
        owner   => $username,
        group   => $group
      }

      if ($has_sudo == true) {
        sudo::conf { "${username}":
          priority => 10,
          content  => "${username} ALL=(ALL) NOPASSWD: ALL",
        }
      }

    if($private_key != '' and $private_key != undef) {
      $complete_ssh_private_key_target_path = "${ssh_dir}/${ssh_target_key_name}"

      file { "${complete_ssh_private_key_target_path}":
        content => "${private_key}",
        mode    => '0600',
        owner   => $username,
        group   => $group
      }
    }

    if($public_key != '' and $public_key != undef) {
      $complete_ssh_public_key_target_path = "${ssh_dir}/${ssh_target_key_name}.pub"

      file { "${complete_ssh_public_key_target_path}":
        content => "${public_key}",
        mode    => '0600',
        owner   => $username,
        group   => $group
      }
    }
}
