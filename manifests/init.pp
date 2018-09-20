
class icinga (
  $users                  = ['admin'],
  $cfg_files              = [],
  $cfg_dirs               = [],
  $contactgroups          = {},
  $max_concurrent_checks  = 10000,
  $service_check_timeout  = 90,
  $enable_notifications   = 0,
  $enable_event_handlers  = 1,
  $icinga_user            = 'nagios',
  $icinga_group           = 'nagios',
  $ensure_service         = 'running',
) {
  ensure_packages('icinga')

  include icinga::plugins
  include icinga::commands

  service { 'icinga':
    ensure    => $ensure_service,
    hasstatus => false,
    restart   => 'systemctl reload icinga',
    require   => Mount['/var/icinga-tmpfs'],
  }

  file { '/etc/icinga/cgi.cfg':
    content => template("${module_name}/cgi.cfg.erb"),
    mode    => '0644',
    owner   => $icinga_user,
    group   => $icinga_group,
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/etc/icinga/icinga.cfg':
    content => template("${module_name}/icinga.cfg.erb"),
    mode    => '0644',
    owner   => $icinga_user,
    group   => $icinga_group,
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/etc/icinga/resource.cfg':
    source  => "puppet:///modules/${module_name}/resource.cfg",
    owner   => $icinga_user,
    group   => $icinga_group,
    mode    => '0644',
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }

  # If in Vagrant, fall back to local auth.
  if ($domain == 'test')  # FIXME: There must be a better way to detect this.
  {
    file { '/etc/icinga/htpasswd.users':
      content => 'admin:$6$A5e7/pKObWowY$PpcFrl5O9MZ4PfAAJFmIkOZTiFz7zoi.jdSqB4/8FxGEnvAe6I9rkooUcCpAGR/zyfBrXHzv29hc3OYSMPLwf1', # admin:admin
      mode    => '0644'
    }
  }

  file { '/etc/icinga/objects':
    ensure  => 'directory',
    purge   => true,
    recurse => true,
  }

  # TODO: Enable when contactgroups are configured
  # file { '/etc/icinga/objects/ncsa_frack.cfg':
  #   source  => "puppet:///modules/${module_name}/ncsa_frack.cfg",
  #   owner   => $icinga_user,
  #   group   => $icinga_group,
  #   mode    => '0644',
  #   require => Package['icinga'],
  #   #notify  => Service['icinga'],
  # }

  file { '/etc/icinga/objects/contactgroups.cfg':
    content   => template("${module_name}/contactgroups.cfg.erb"),
    mode      => '0644',
    owner     => $icinga_user,
    group     => $icinga_group,
    show_diff => false,
    require   => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { "/etc/icinga/objects/contacts.cfg":
    content   => template("${module_name}/contacts.cfg.erb"),
    owner     => $icinga_user,
    group     => $icinga_group,
    mode      => '0600',
    show_diff => false,
    require   => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/etc/icinga/objects/timeperiods.cfg':
    source  => "puppet:///modules/${module_name}/timeperiods.cfg",
    owner   => $icinga_user,
    group   => $icinga_group,
    mode    => '0644',
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/etc/icinga/objects/notification_commands.cfg':
    source  => "puppet:///modules/${module_name}/notification_commands.cfg",
    owner   => $icinga_user,
    group   => $icinga_group,
    mode    => '0644',
    require => Package['icinga'],
    #notify  => Service['icinga'],
  }

  file { '/var/icinga-tmpfs':
    ensure  => directory,
    owner   => $icinga_user,
    group   => $icinga_group,
    mode    => '0755',
  }

  mount { '/var/icinga-tmpfs':
    ensure  => mounted,
    atboot  => true,
    fstype  => 'tmpfs',
    device  => 'none',
    options => "size=1024m,uid=${icinga_user},gid=${icinga_group},mode=755",
    require => File['/var/icinga-tmpfs'],
  }

  # Fix the ownerships of some files. This is ugly but will do for now
  file { ['/var/cache/icinga', '/var/lib/icinga' ]:
    ensure  => directory,
    owner   => $icinga_user,
  }

  # Script to purge resources for non-existent hosts
  file { '/usr/local/sbin/purge-nagios-resources.py':
    source  => "puppet:///modules/${module_name}/purge-nagios-resources.py",
    owner   => $icinga_user,
    group   => $icinga_group,
    mode    => '0755',
  }

  # Command folders / files to let icinga web to execute commands
  # See Debian Bug 571801
  file { '/var/lib/icinga/rw':
    owner => $icinga_user,
    group => 'www-data',
    mode  => '2710', # The sgid bit means new files inherit guid
  }

  # ensure icinga can write logs for ircecho, raid_handler etc.
  file { '/var/log/icinga':
    ensure => 'directory',
    owner  => $icinga_user,
    group  => 'adm',
    mode   => '2755',
  }

  # TODO: incorporate interface
  # Check that the icinga config is sane
  # monitoring::service { 'check_icinga_config':
  #   description    => 'Check correctness of the icinga configuration',
  #   check_command  => 'check_icinga_config',
  #   check_interval => 10,
  # }

  # script to schedule host downtimes
  file { '/usr/local/bin/icinga-downtime':
    ensure => present,
    source => "puppet:///modules/${module_name}/icinga-downtime.sh",
    owner  => 'root',
    group  => 'root',
    mode   => '0550',
  }

  # script to manually send SMS to Icinga contacts (T82937)
  file { '/usr/local/bin/icinga-sms':
    ensure => present,
    source => "puppet:///modules/${module_name}/icinga-sms.py",
    owner  => 'root',
    group  => 'root',
    mode   => '0550',
  }

  # Purge unmanaged nagios_host and nagios_services resources
  # This will only happen for non exported resources, that is resources that
  # are declared by the icinga host itself
  resources { 'nagios_host': purge => true, }
  resources { 'nagios_service': purge => true, }
}
