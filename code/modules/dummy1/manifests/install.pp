class dummy1::install (
) {

    $ntp_servers   = hiera('ntp_servers')
    $servers       = hiera('servers')

    file { "/etc/dummy1.txt":
        ensure => present,
        content => template("dummy1/dummy.txt.erb"),
        mode => "644"
    }

}
