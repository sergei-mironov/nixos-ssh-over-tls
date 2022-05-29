About
-----

This repo contains a [NixOS](https://nixos.org) module which NixOS module which
hides both HTTP and SSH daemons behind SSL proxy on a same port.

**This repo should be considered as a draft.**

Usage
-----

1. Add the module to your system's config like this

  ```nix
  {
    # ...

    require = [
    ../path/to/ssh-over-ssl/nix/default.nix
    ];

    # ...

    services.ssh-over-ssl = {
      cert_pem = ../stunnel.pem;
      sshd_port = 22;
      httpd_port = 80;
      ssl_port = 443;
    };

    # ...
  }
  ```

2. Run `sh sh/genkeys.sh` to generate Stunnel certificates. Set up `cert_pem` to
   point to the PEM-file produced. Copy it to your clients.

3. Make sure your SSH and HTTPD servers are set up correctly (we assume they use
   ports 22 and 80 in the example above).

4. On server, build the system with `nixos-rebuild switch`

5. On client, run `sh sh/client.sh`
