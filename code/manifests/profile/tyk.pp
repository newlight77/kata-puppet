class profile::tyk {
    include role::users
    include role::parent
    include role::redis
    include role::tyk

    Class['role::users'] -> Class['role::parent'] -> Class['role::redis'] -> Class['role::tyk']

}
