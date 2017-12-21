class dummy::install (
    $ntp_servers,
    $servers
) {

    file { "/etc/dummy.txt":
        ensure => present,
        content => template("dummy/dummy.txt.erb"),
        mode => "644"
    }

}
