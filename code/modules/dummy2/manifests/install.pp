class dummy2::install (
) {

    $ntp_servers   = hiera('ntp_servers')
    $servers       = hiera('servers')

    create_resources('dummy2::dummy_file', $servers)
}
