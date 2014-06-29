require 'spec_helper_acceptance'

case fact('lsbdistdescription')
when 'Ubuntu 14.04 LTS'
  rubygems_package_name = 'ruby'
  ruby_package_name     = 'ruby'
else
  rubygems_package_name = 'rubygems'
  ruby_package_name     = 'ruby'
end

describe 'ruby class' do
  context 'without parameters' do
    it 'should run with no errors' do
      pp = <<-EOS
      class { 'ruby': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('ruby') do
      it {
        should be_installed
      }
    end
  end

  context 'with alternate packages specified' do
    it 'should run with no errors' do
      pp = <<-EOS
      class { 'ruby':
        ruby_package     => 'ruby1.9.1-full',
        rubygems_package => 'rubygems1.9.1',
        gems_version     => 'latest',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)

      skip "fix recurring \"ensure changed 'purged' to 'latest' \" on each run"
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('ruby1.9.1') do
      it {
        should be_installed
      }
    end
  end

  RUBY187_UNSUPPORTED_PLATFORMS = ['Ubuntu 14.04 LTS']
  context 'with ruby 1.8.7 specified', :unless => RUBY187_UNSUPPORTED_PLATFORMS.include?(fact('lsbdistdescription')) do
    it 'should run with no errors' do
      pp = <<-EOS
      class { 'ruby':
        version         => '1.8.7',
        rubygems_update => false
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('rubygems') do
      it {
        should be_installed
      }
    end
  end

  context 'with latest rubygems' do
    it 'should run with no errors' do
      pp = <<-EOS
      class { 'ruby':
        gems_version => 'latest',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package(rubygems_package_name) do
      it {
        should be_installed
      }
    end
  end
end
