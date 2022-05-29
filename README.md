About
-----

This repo contains a [NixOS](https://nixos.org) module which NixOS module which
hides both HTTP and SSH daemons behind HTTPS proxy on a same port.

**This repo should be considered as a draft.**

Usage
-----

1. Add the module to your system's config like this

  ```nix
  {
    # ...

    require = [
    ../path/to/ssh-over-tls/nix/default.nix
    ];

    # ...

    services.ssh-over-tls = {
      cert_pem = ../stunnel.pem;
      sshd_port = 22;
      httpd_port = 80;
      tls_port = 443;
    };

    # ...
  }
  ```

2. Run `sh sh/genkeys.sh` to generate Stunnel certificates. Set up `cert_pem` to
   point to the PEM-file produced. Copy it to your clients.

3. Make sure your SSH and HTTPD servers are set up correctly (we assume they use
   ports 22 and 80 in the example above).

4. On the server, build the system with `nixos-rebuild switch`

5. On the client, run
   - Stunnel client pointing to server's SSL port:
     ```shell
     sh sh/client.sh  -L 3443 IP:443
     ```
     where IP is the server's IP. Port 3443 is picked at will.
   - SSH to the client's local port 3443:
     ```shell
     ssh -p 3443 127.0.0.1
     ```
     The connection will be forwarded to your server's SSHD using SSL protocol.
     Use `-L/-R/-D` ssh forwarding as needed.

