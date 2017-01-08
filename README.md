Adds Let's Encrypt support to the official haproxy image

## Configuration

### Volumes

* `/certs` : the concatenated LetsEncrypt cert + key is stored here as `haproxy.pem`
* `/config` : by default `haproxy-gen-cfg.yml` is loaded from here to render the haproxy.cfg

### Environment Variables

* `EMAIL` : **required** for specifying the e-mail registration for LetsEncrypt certificate
* `DOMAINS` : comma separated list of `DOMAIN@BACKEND:PORT` where `DOMAIN` is the public
  domain to serve, `BACKEND` is the Docker resolvable hostname of the backend service, and
  `PORT` is the listening port of that service.
* `STAGING` : set to `true` in order to use staging LetsEncrypt certificate requests

### Port Mappings

* 80
* 443

## Example

The following would request a certificate to identify two domains and proxy those each to
distinct backend Docker services.

```
docker run -d -e EMAIL=me@there \
  -e DOMAINS=one.com@service1:8080,two.com@service2:8080 \
  itzg/haproxy-lets
```
