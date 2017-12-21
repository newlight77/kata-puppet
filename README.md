# puppet-demo


_#1_ First,
```
docker-compose up -d
```

_#2_ On client, request for certificate signing,
```
docker exec agent puppet agent --test
```

_#3_ Then accept the agent certificate on puppet master,
```
$ docker exec puppet puppet cert list

  "agent" (SHA256) E4:92:A3:4F:8F:52:13:60:AA:41:39:DA:4B:B7:15:6A:AF:60:A8:FF:88:9D:13:22:6D:31:EE:EF:45:6F:ED:9D

$ docker exec puppet puppet cert sign agent

Signing Certificate Request for:
  "agent" (SHA256) E4:92:A3:4F:8F:52:13:60:AA:41:39:DA:4B:B7:15:6A:AF:60:A8:FF:88:9D:13:22:6D:31:EE:EF:45:6F:ED:9D
Notice: Signed certificate request for agent
Notice: Removing file Puppet::SSL::CertificateRequest agent at '/etc/puppetlabs/puppet/ssl/ca/requests/agent.pem'
```

_#4_ On client, run puppet agent -t,
```
docker exec agent puppet agent -t

Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Info: Caching catalog for agent
Info: Applying configuration version '1513849805'
Info: Creating state file /opt/puppetlabs/puppet/cache/state/state.yaml
Notice: Applied catalog in 0.05 seconds
```

_#5_ Do your thing under code.
