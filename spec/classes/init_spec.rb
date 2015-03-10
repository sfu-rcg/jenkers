require 'spec_helper'

describe 'jenkins' do

  context "on an unsupported product version" do
    # here we setup two fake facts:
    # yes, we are Darwin
    # no, we are not Mavericks (10.9)
    let :facts do
      {
        :osfamily => 'Darwin',
      }
    end
    # Test the Puppet fail directive
    it "should raise a Puppet:Error" do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /This module only works on Debian and Red Hat based systems./)
    end
  end

  context 'on a supported product version' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
      }
    end

    context 'with defaults for all parameters' do
      it { should contain_package ('curl') }
      it { should contain_class ('jenkins') }
      it { should contain_group ('jenkins') }
      it { should contain_user  ('jenkins') }
      it { should contain_file  ('/var/jenkins_home') }
      it { should contain_file  ('/var/jenkins_home/plugins') }
      it { should contain_file  ('/var/jenkins_home/init.groovy') }
      it { should contain_class ('docker') }
      it { should contain_docker__image('jenkins') }
      it { should contain_docker__run('jenkins') }
    end

    context 'when plugins are listed' do

      base_url    = 'http://mirrors.jenkins-ci.org/plugins'
      plugins_dir = '/var/jenkins_home/plugins'
      plugins = {
        'chucknorris' => 'latest',
        'greenballs'  => '1.14',
        'scm-api'     => '0.1',
        'git-client'  => '1.15.0',
        'git'         => '1.1.11',
        'ws-cleanup'  => '0.25',
      }

      let(:params) do
        { :plugins => plugins }
      end

      plugins.each do |plugin,version|
        url     = "#{base_url}/#{plugin}/#{version}/#{plugin}.hpi"
        outfile = "#{plugins_dir}/#{plugin}.hpi"

        it { should contain_exec ("curl -sf -o #{outfile} -L #{url}") }
      end

    end

  end


end
