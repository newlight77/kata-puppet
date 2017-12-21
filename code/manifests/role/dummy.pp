class role::dummy {

    class { 'dummy::install' :
        ntp_servers   => hiera('ntp_servers'),
        servers       => hiera('servers')
    }

    contain 'dummy::install'
}
