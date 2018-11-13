class profile::tyk {
    include role::users
    include role::parent
    include role::tyk

    Class['role::users'] -> Class['role::parent'] -> Class['role::tyk']

}
