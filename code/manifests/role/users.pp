class role::users {
  $system_users                                    = hiera_hash('system_users')
  $system_user_default_password                    = hiera('system_user_default_password')
  $system_user_default_password_min_age            = hiera('system_user_default_password_min_age')
  $system_user_default_password_max_age            = hiera('system_user_default_password_max_age')
  $system_user_default_shell                       = hiera('system_user_default_shell')
  $system_user_default_group                       = hiera('system_user_default_group')
  $ssh_target_key_name                             = hiera('ssh_target_key_name')

  package { "openssh-clients":
      ensure => present
  }

  $system_users.each |$username, $user| {

    if $user['group'] == undef {
      $group = $system_user_default_group
    } else {
      $group = $user['group']
    }

    class { 'user::install':
      username               => $username,
      full_name           => $user['full_name'],
      authorized_keys     => $user['authorized_keys'],
      password            => $system_user_default_password,
      password_min_age    => $system_user_default_password_min_age,
      password_max_age    => $system_user_default_password_max_age,
      shell               => $system_user_default_shell,
      group               => $group,
      has_sudo            => $user['has_sudo'],
      private_key         => hiera("private_key_${username}", ''),
      public_key          => hiera("public_key_${username}", ''),
      ssh_target_key_name => $ssh_target_key_name,
      home                => $user['home'],
      internal_group      => $system_user_default_group
    }
  }
}
