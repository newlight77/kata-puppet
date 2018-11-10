class profile::test {
    include role::dummy
    include role::tyk
    include dummy1::install
    include dummy2::install
    #include common::install
}
