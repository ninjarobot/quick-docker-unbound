# quick-docker-unbound
Small container with Unbound DNS resolver with auto-reload

Unbound is a validating, recursive, and caching DNS resolver.  It is intended for resolving DNS requests, but is able to resolve for local domains as well.  It is not intended to be an authoritative DNS server so it doesn't support zone transfers, but if you have a simple DNS requirement like a single location or home network, it's helpful for serving all DNS for the local network and quickly resolving external hostnames up to root DNS servers.

Build a Docker image tagged as `unbound-server` from the `Unbound.dockerfile`.

```sh
docker build -t unbound-server -f Unbound.dockerfile .
```

By default, the configuration is loaded from `/etc/unbound`, so map the location of the `unbound.conf` and `myzone.dns` files to the `/etc/unbound` directory and they'll be loaded on startup.

```sh
docker run --rm -it -p 53:53 -p 53:53/udp -v `pwd`:/etc/unbound/ unbound-server sh
```

In the example below, my docker host is at 192.168.2.235, and the DNS port 53 is forwarded to the container.

```sh
# Resolve a domain
dig @192.168.2.235 +short abcdef.myzone.localnet
1.2.3.4

# Reverse lookup
dig @192.168.2.235 +short -x 1.2.3.4
abcdef.myzone.localnet

# Retrieve arbitrary data from a TXT record
dig @192.168.2.235 +short TXT abcdef.myzone.localnet
"foo=bar"
"pow=shazam"
```

The entrypoint uses `inotifywait` to watch for changes in that directory.  If there are changes, the `HUP` signal is sent to the `unbound` process, which tells it to reload the configuration.  That means changes to the `myzone.dns` file will be reflected right away, with one caveat being that errors in the config will cause it to stop listening and you can't really reload.  Easy enough, remove the container and launch a new one.

