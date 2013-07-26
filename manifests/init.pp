# Class: project
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Usage:
#
class project {
  $version        = '0.1.0'
  $binary_path    = '/usr/local/bin/project'
  $config_file    = '/usr/local/etc/project.ini'
  $project_url    = "https://s3.amazonaws.com/bucket/project-${version}.tar.gz"
  $install_script = '/usr/local/bin/install_project'
  $log_file       = '/var/log/project.log'
  $upstart_file   = '/etc/init/project.conf'

  file { $install_script:
    content => template('project/install.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  exec { 'install-project':
    command => $install_script,
    unless  => "/usr/bin/test `/usr/local/bin/project -v | tail -1` = ${version}",
    notify  => Service['project'],
    require => File[$install_script],
  }

  file { $config_file:
    ensure  => present,
    path    => $config_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('project/config.erb'),
    notify  => Service['project'],
  }

  file { $upstart_file:
    ensure  => present,
    content => template('project/upstart.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['project'],
    require => [
      File[$config_file],
      File[$log_file],
      Exec['install-project'],
    ]
  }

  service { 'project':
    ensure     => running,
    hasrestart => true,
    require    => File[$upstart_file],
  }
}
