define tyk::delete_key (
  $api_id,
  $ensure,
  $type_key  = "basic_auth",
  $key       = "",
  $client_id = "",
  $debug     = false,
  $tyk_host  = lookup('tyk_host'),
  $tyk_port  = lookup('tyk_port'),
  $tyk_token = lookup('tyk_token')
) {
  if undef != $key and "" != $key {
    $final_key = $key
  } elsif undef != $client_id and "" != $client_id {
    $final_key = $client_id
  } else {
    $final_key = $title
  }

  $curl = "curl -X DELETE http://${tyk_host}:${tyk_port}/tyk/keys/${final_key} -H 'x-tyk-authorization: ${tyk_token}' "
  $diffCmd = "test `/bin/bash /opt/userdemo/tyk_diff_dates.sh delete_${api_id} ${title}` = \"OK\""

  if undef != $debug and $debug {
    notify {"[TYK][DELETE_KEY] Executing curl : ${curl}": }
    notify {"[TYK][DELETE_KEY] Only if : ${diffCmd}": }
  }

  if $ensure != undef and $ensure == "absent" and ($type_key == "basic_auth" or $type_key == "hmac") {
    exec { "delete-basicauth-${api_id}-${final_key}":
      command => $curl,
      path    => "/bin",
      onlyif  => "$diffCmd"
    }
  }
}
