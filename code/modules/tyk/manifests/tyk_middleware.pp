define tyk::tyk_middleware(
  $tyk_parent_dir,
  $user,
  $group,
  $posc_datastore_host,
  $posc_datastore_port,
  $service_path,
  $should_notify = true
){
  file{"${tyk_parent_dir}/middleware/${name}.js":
    ensure  => 'file',
    mode    => '0644',
    owner   => $user,
    group   => $group,
    content => template('tyk/getUserIdMiddleware.js.erb'),
    notify  => $should_notify ? {
      true => Service["tyk"],
      default => undef
    }
  }
}
