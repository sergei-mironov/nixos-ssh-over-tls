{pkgs, config, lib, ...}:
let
  cfg = config.services.ssh-over-tls;
in
with lib;
{
  options = {
    services.ssh-over-tls = {
      httpd_port = mkOption {
        default = 80;
        type = with types; uniq int;
        description = ''
          Port of the local HTTP daemon (should be run independently)
        '';
      };
      sshd_port = mkOption {
        default = 22;
        type = with types; uniq int;
        description = ''
          Port of the local SSHD daemon (should be run independently)
        '';
      };
      tls_port = mkOption {
        default = 443;
        type = with types; uniq int;
        description = ''
          Port of the HAProxy's HTTPS daemon (run by this module)
        '';
      };
      cert_pem = mkOption {
        default = ../stunnel.pem;
        type = with types; uniq path;
        description = ''
          Path to the TLS private key FILE.pem.
        '';
      };
    };
  };

  config =
    let
      inherit (cfg) cert_pem httpd_port sshd_port tls_port;
    in
    {
      services.haproxy = {
        enable = true;
        config = assert builtins.pathExists cert_pem ; ''
          backend secure_http
              http-request add-header X-Forwarded-Proto https
              http-response add-header Strict-Transport-Security max-age=31536000
              mode http
              option httplog
              option forwardfor
              server local_http_server 127.0.0.1:${toString httpd_port}

          backend ssh
              mode tcp
              option tcplog
              server ssh 127.0.0.1:${toString sshd_port}
              timeout tunnel 600s

          frontend ssl
              bind 0.0.0.0:${toString tls_port} ssl crt ${cert_pem} no-sslv3
              mode tcp
              option tcplog
              tcp-request inspect-delay 5s
              tcp-request content accept if HTTP

              acl client_attempts_ssh payload(0,7) -m bin 5353482d322e30

              use_backend ssh if !HTTP
              use_backend ssh if client_attempts_ssh
              use_backend secure_http if HTTP
        '';
      };
    };
}

