class common::install {

    $packages_list = [
      'apt-transport-https',
      'bzip2',
      'curl',
      'deborphan',
      'htop',
      'less',
      'lsof',
      'ncdu',
      'pbzip2',
      'pigz',
      'pwgen',
      'rpl',
      'screen',
      'strace',
      'sudo',
      'tar',
      'unzip',
      'vim',
      'wget',
      'whois',
      'zip'
    ]

    package {
      $packages_list:
        ensure => 'installed'
    }
}
