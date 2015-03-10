# jenkins

## Overview

Installs Docker (as required) and activates a Jenkins container

## Description

Uses the garethr/docker module to:

* install Docker (as required)
* pull the official Docker image from hub.docker.com
* stand-up Jenkins container with some default security, configuration and plugins

## Requirements

* garethr/docker
* puppetlabs/stdlib

## Usage

    class { 'jenkers':
      container_name       => 'leeroy',
      administrator        => 'leeroy',
      password             => 'jenkins',
      admin_email_name     => 'Leeroy Jenkins',
      admin_email_address  => 'leeroy@foo.bar',
      smtp_host            => 'smtp.foo.bar',
      image_version        => 'latest',
      env_jenkins_home     => '/var/jenkins_home',
      local_data_store     => '/var/jenkins_home',
      host_port            => '8080',
      run_at_startup       => true,
      plugin_source_url    => 'http://mirrors.jenkins-ci.org/plugins/',
      plugins              => { 'chucknorris' => 'latest' },
    }

## Reference

Not applicable

## Limitations

Should work on Ubuntu and CentOS with any luck...
