define tyk::provision_key (
  $api_id,
  $ensure,
  $type_key     = "basic_auth",
  $password     = "",
  $key          = "",
  $secret       = "",
  $client_id    = "",
  $allowance    = "20",
  $rate         = "20",
  $per          = "1",
  $expires      = "0",
  $quota_max    = "-1",
  $policy_id    = "",
  $redirect_uri = "",
  $debug        = false,
  $tyk_host     = lookup('tyk_host'),
  $tyk_port     = lookup('tyk_port'),
  $tyk_token    = lookup('tyk_token')
) {
  if undef != $key and "" != $key {
    $final_key = $key
  } elsif undef != $client_id and "" != $client_id {
    $final_key = $client_id
  } else {
    $final_key = $title
  }

  if undef != $secret and "" != $secret {
    $final_secret = $secret
  } elsif undef != $password and "" != $password {
    $final_secret = $password
  } else {
    $final_secret = ""
  }

  if undef == $type_key or "basic_auth" == $type_key {
    $body_ext = "\"basic_auth_data\" : { \"password\" : \"${final_secret}\" }"
  } else {
    $body_ext = "\"hmac_enabled\": true, \"hmac_string\": \"${final_secret}\""
  }

  if undef == $type_key or "basic_auth" == $type_key or "hmac" == $type_key {
    $url = "http://${tyk_host}:${tyk_port}/tyk/keys/${final_key}"
    $body = "'{ \"allowance\" : ${allowance}, \"rate\" : ${rate}, \"per\" : ${per}, \"expires\" : ${expires}, \"quota_max\" : ${quota_max}, \"access_rights\" : { \"${api_id}\" : { \"api_id\": \"${api_id}\"} }, \"org_id\" : \"\", ${body_ext} }'"
  } else {
    $url = "http://${tyk_host}:${tyk_port}/tyk/oauth/clients/create"
    $body = "{ \"client_id\": \"${final_key}\", \"redirect_uri\": \"${redirect_uri}\", \"api_id\": \"${api_id}\", \"policy_id\": \"\", \"secret\": \"${final_secret}\" }"
  }

  $curl = "curl -X POST ${url} -H 'content-type: application/json' -H 'x-tyk-authorization: ${tyk_token}' -d ${body}"
  $diffCmd = "test `/bin/bash /USR/newtprod/tyk_diff_dates.sh ${api_id} ${title}` = \"OK\""

  if undef != $debug and $debug {
    notify {"[TYK][PROVISION_KEY] Executing curl : ${curl}": }
    notify {"[TYK][PROVISION_KEY] Only if : ${diffCmd}": }
  }

  if $ensure == undef or $ensure != "absent" {
    exec { "setup-password-${api_id}-${title}":
      command => $curl,
      path    => "/bin",
      onlyif  => "$diffCmd"
    }
  }
}