class pentaho ($pentaho_home = '/srv/pentaho') {

  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  }

  package { ['unzip', 'xvfb']: }

  ### JAVA JDK 7 ORACLE ###

  include apt

  apt::key { 'webupd8team':
    key => '7B2C3B0889BF5709A105D03AC2518248EEA14886',
    key_server => 'keyserver.ubuntu.com',
  }

  apt::ppa { 'ppa:webupd8team/java':
    require => Apt::Key['webupd8team'],
  }

  exec {
    'set-licence-selected':
    command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections';

    'set-licence-seen':
    command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections';
  }

  package { 'oracle-java7-installer':
    ensure => present,
    require => [
      Apt::Ppa['ppa:webupd8team/java'],
      Exec['set-licence-selected'],
      Exec['set-licence-seen'],
    ],
  }

  ### DOWNLOAD ###

  $biserver_home = "${pentaho_home}/biserver-ce"

  file { $pentaho_home:
    ensure  => 'directory'
  }

  $biserver_download = 'biserver-ce-5.3.0.0-213'

  archive { $biserver_download:
    ensure => present,
    extension => 'zip',
    digest_type => 'sha1',
    url    => "http://arquivos.interlegis.leg.br/interlegis/produtos/pentaho/${biserver_download}.zip",
    target => $pentaho_home,
    follow_redirects => true,
    require => [
      File[$pentaho_home],
      Package['unzip']],
  }

  ### UPSTART ###

  file { '/etc/init/pentaho.conf':
    content => template('pentaho/pentaho.conf.erb'),
  }

  file { 'upstart_biserver_wrapper.sh':
    path => "${pentaho_home}/upstart_biserver_wrapper.sh",
    content => template('pentaho/upstart_biserver_wrapper.sh.erb'),
    mode => '+x',
    require => File[$pentaho_home],
  }

  service { 'pentaho':
    ensure => running,
    provider => 'upstart',
    require => [
      Package['oracle-java7-installer'],
      Archive[$biserver_download],
      File['/etc/init/pentaho.conf'],
      File['upstart_biserver_wrapper.sh']],
  }

}
