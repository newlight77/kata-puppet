class role::parent {

    $root_dir           = hiera('root_dir')
    $parent_dir         = hiera('parent_dir')
    $var_root_dir       = hiera('var_root_dir')
    $var_parent_dir     = hiera('var_parent_dir')

    file { "${var_root_dir}":
      ensure  => 'directory',
      owner   => $user,
      group   => $group,
      force   => true
    } ->
    file { "${var_parent_dir}":
      ensure  => 'directory',
      owner   => $user,
      group   => $group,
      force   => true
    }

    file { "${root_dir}":
      ensure  => 'directory',
      owner   => $user,
      group   => $group,
      force   => true
    } ->
    file { "${parent_dir}":
      ensure  => 'directory',
      owner   => $user,
      group   => $group,
      force   => true
    }
}
