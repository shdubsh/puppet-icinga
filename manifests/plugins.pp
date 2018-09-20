
class icinga::plugins (
  $custom_plugins = [
    'check_all_memcached.php',
    'check_bgp',
    'check_cirrus_frozen_writes.py',
    'check_dsh_groups',
    'check_elasticsearch.sh',
    'check_elasticsearch.py',
    'check_elasticsearch_shard_size.py',
    'check_etcd_mw_config_lastindex',
    'check_grafana_alert',
    'check_graphite',
    'check_graphite_freshness',
    'check_gsb.py',                     # Google safebrowsing lookup API client
    'check_icinga_config',
    'check_ifstatus_nomon',
    'check_jnx_alarms',
    'check_legal_html.py',
    'check_longqueries.pl',
    'check_MySQL.php',
    'check_mysql-replication.pl',
    'check_ores_workers',
    'check_prometheus_metric.py',
    'check_ripe_atlas.py',
    'check_ssl',
    'check_sslxNN',
    'check_to_check_nagios_paging',
    'check_wikidata',
    'check_wikidata_crit.sh',           # Wikidata dispatcher monitoring
    'check_wikitech_static.sh',
    'check_wikitech_static_version.py',
  ]
) {
  ensure_packages('nagios-nrpe-plugin')

  file { '/usr/lib/nagios/plugins/eventhandlers':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/usr/lib/nagios/plugins/eventhandlers/submit_check_result':
    source => "puppet:///modules/${module_name}/submit_check_result.sh",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # WMF custom service checks
  $custom_plugins.each |String $plugin_filename| {
    file { "/usr/lib/nagios/plugins/${plugin_filename}":
      ensure  => 'present',
      source  => "puppet:///modules/${module_name}/plugins/${plugin_filename}",
      mode    => '0755'
    }
  }

}
