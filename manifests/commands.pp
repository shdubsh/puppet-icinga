
class icinga::commands (
  $custom_commands = [
    'check_grafana_alert.cfg.erb',
    'check_graphite.cfg.erb',
    'check_icinga_config.cfg.erb',
    'check_legal_html.cfg.erb',
    'check_ores_workers.cfg.erb',
    'check_prometheus_metric.cfg.erb',
    'check_ripe_atlas.cfg.erb',
    'check_ssl.cfg.erb',
    'check_ssl_unified.cfg.erb',
    'check_to_check_nagios_paging.cfg.erb',
    'check_wikidata.cfg.erb',
    'check_wikidata_crit.cfg.erb',
    'check_wikitech_static.cfg.erb',
    'check_wikitech_static_version.cfg.erb',
    'check_wmf_service.cfg.erb',
    'dns.cfg.erb',
    'elasticsearch.cfg.erb',
    'gsb.cfg.erb',
    'http.cfg.erb',
    'ifstatus.cfg.erb',
    'irc.cfg.erb',
    'ldap.cfg.erb',
    'mail.cfg.erb',
    'mysql.cfg.erb',
    'nrpe.cfg.erb',
    'ntp.cfg.erb',
    'ping.cfg.erb',
    'procs.cfg.erb',
    'puppet.cfg.erb',
    'raid_handler.cfg.erb',
    'smtp.cfg.erb',
    'snmp.cfg.erb',
    'ssh.cfg.erb',
    'tcp_udp.cfg.erb',
    'vsz.cfg.erb',
  ]
) {
  if os_version('debian >= stretch') {
    $plugin_perl_package = 'libmonitoring-plugin-perl'
  } else {
    $plugin_perl_package = 'libnagios-plugin-perl' # Deprecated in Debian stretch
  }

  ensure_packages([
    $plugin_perl_package,
    'libnet-ssleay-perl',
    'libio-socket-ssl-perl',
    'libio-socket-inet6-perl',
    'libnet-snmp-perl',
    'libtime-duration-perl',
    'python3-requests',
  ])

  # FIXME: need secrets module
  # include ::passwords::nagios::mysql

  # FIXME: need secrets module
  # $nagios_mysql_check_pass = $passwords::nagios::mysql::mysql_check_pass
  $nagios_mysql_check_pass = 'placeholder'

  $custom_commands.each |String $command_filename| {

    $cleaned = delete($command_filename, '.erb')

    file { "/etc/nagios-plugins/config/${cleaned}":
      ensure => 'present',
      content => template("${module_name}/commands/${command_filename}")
    }

  }
}
