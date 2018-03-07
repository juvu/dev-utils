Create file: /etc/docker/daemon.json

```json
{
  "bip": "172.18.12.1/24"
}
```

Execute:
```shell
sudo service docker restart
```
