# == Class: jenkins
#
# Installs Docker as required and stands-up an official docker/jenkins
# instance with simple security.
#
# === Parameters
#
# [*container_name*]
#   The name of the Jenkins container
#
# [*administrator*]
#   The name of the Jenkins admin account
#
# [*password*]
#   Password for the Jenkins admin account
#
# [*admin_email_name*]
#   Full Name of the Jenkins SMTP user
#
# [*admin_email_address*]
#   Email address of the Jenkins SMTP user
#
# [*smtp_host*]
#   Name of the SMTP server Jenkins should use
#
# [*image_version*]
#   Version of the official Jenkins image to use
#
# [*env_jenkins_home*]
#   The location of Jenkins data store within the container
#
# [*local_data_store*]
#   The location of Jenkins data store on the host
#
# [*host_port*]
#   The port on the local host that will expose Jenkins
#
# [*run_at_startup*]
#   Controls whetehr or not to use init.d to load Jenkins at startup
#
# [*plugin_source_url*]
#   The source URL for fetching plugins
#
# [*plugins*]
#   Hash listing plusgin to install (plugin => version)
#
# === Examples
#
#  class { 'jenkins':
#    container_name => 'leeroy',
#  }
#
# === Authors
#
# Brian Warsing <bcw@sfu.ca>
#
# === Copyright
#
# Copyright 2015 Simon Fraser Univeristy, unless otherwise noted.
#
class jenkins (

  $container_name       = 'jenkins',
  $administrator        = 'leeroy',
  $password             = 'jenkins',
  $admin_email_name     = 'Leeroy Jenkins',
  $admin_email_address  = 'leeroy@foo.bar',
  $smtp_host            = 'smtp.foo.bar',
  $image_version        = 'latest',
  $env_jenkins_home     = '/var/jenkins_home',
  $local_data_store     = '/var/jenkins_home',
  $host_port            = '8080',
  $run_at_startup       = true,
  $plugin_source_url    = 'http://mirrors.jenkins-ci.org/plugins/',
  $plugins              = {},

) {

  $data_store_dirs = [$local_data_store, "$local_data_store/plugins"]
  $plugin_execs    = transform_plugins_list($plugin_source_url, "$local_data_store/plugins", $plugins)

  package { 'curl':
    ensure => installed,
  }

  # Create a service group for Jenkins
  group { 'jenkins':
    gid => '1000',
  }

  # Create a service account for Jenkins
  user { 'jenkins':
    require => Group['jenkins'],
    comment => 'Jenkins User',
    home    => $local_data_store,
    shell   => '/bin/false',
    uid     => '1000',
    gid     => '1000',
  }

  # Create a local Jenkins data store
  file { $data_store_dirs:
    ensure  => directory,
    require => [User['jenkins'], Group['jenkins']],
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0750',
  }

  # Install a Jenkins initialization script
  file { "${local_data_store}/init.groovy":
    ensure  => file,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0640',
    content => template('jenkins/init_groovy.erb'),
  }

  exec { $plugin_execs:
    path => '/usr/bin/curl'
  }

  # Install Docker if it's not already being installed elsewhere
  if ! defined_with_params(Class['docker'], {'manage_kernel' => false}) {
    class { 'docker':
      # version       => '1.5.0',
      manage_kernel => false,
    }
  }

  # Pulls the official Jenkins image
  docker::image { 'jenkins':
    image_tag => $image_version,
  }

  # Create a container named
  # - maps ports, volumes and controls init.d startup
  docker::run { $container_name:
    image           => 'jenkins',
    ports           => ["${host_port}:8080"],
    use_name        => true,
    volumes         => ["${local_data_store}:${env_jenkins_home}"],
    restart_service => $run_at_startup,
    privileged      => false,
    pull_on_start   => false,
  }

}
