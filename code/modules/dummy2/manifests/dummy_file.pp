define dummy2::dummy_file (
    $server_name,
    $nbinstances
) {

    file { "/etc/dummy${server_name}.txt":
        ensure => present,
        content => template("dummy2/dummy.txt.erb"),
        mode => "644"
    }

    #$consumers_to_install = split(inline_template("<%= a=[];(1..@nb_instances).step(1) do |i| a+=['posc-events-%s@%s' % [@title,i]] end;a.join(',') %>"), ',')
}
