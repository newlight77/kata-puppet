define dummy2::dummy_file (
    # $name, # not allowed to redefine a built-in parameter
    $server_name,
    $nbinstances
) {
    $prefix = "param"
    $list = "<%= a=[]; (1..@nbinstances).step(1) do |i| a+=['$prefix-%s@%s' % [@title,i]] end; a.join(',') %>"
    $params_to_install = split(inline_template($list), ',')

    file { "/etc/dummy${server_name}.txt":
        ensure => present,
        content => template("dummy2/dummy.txt.erb"),
        mode => "644"
    }
}
