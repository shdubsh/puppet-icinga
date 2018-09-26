# = Class: icinga::naggen
#
# Runs naggen2 to generate hosts, service and hostext config
# from exported puppet resources
class icinga::naggen {

  file { '/etc/nagios/puppet_hosts.cfg':
    content => generate('/usr/local/bin/naggen2', '--type', 'hosts'),
    backup  => false,
    owner   => $icinga::icinga_user,
    group   => $icinga::icinga_group,
    mode    => '0644',
    notify  => Service['icinga'],
  }

  file { '/etc/nagios/puppet_services.cfg':
    content => generate('/usr/local/bin/naggen2', '--type', 'services'),
    backup  => false,
    owner   => $icinga::icinga_user,
    group   => $icinga::icinga_group,
    mode    => '0644',
    notify  => Service['icinga'],
  }

  # Collect all (virtual) resources
  Monitoring::Group <| |> {
    notify  => Service['icinga'],
  }

  Monitoring::Host <| |> {
    notify  => Service['icinga'],
  }

  Monitoring::Service <| tag != 'nrpe' |> {
    notify  => Service['icinga'],
  }

}
