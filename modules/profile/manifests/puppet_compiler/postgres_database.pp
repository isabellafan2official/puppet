class profile::puppet_compiler::postgres_database {

    # set ssldir to location of the local catalog-differ puppet CA.
    # this allows catalog-differ runs to validate local puppetdb connections.
    $ssldir='/var/lib/catalog-differ/puppet/ssl'
    wmflib::dir::mkdir_p($ssldir)

    # here a ca_path is specificed so that the ca cert copied below
    # is used to validate connection to nginx puppetdb frontend
    class { 'profile::puppetdb':
        ssldir  => $ssldir,
        ca_path => '/etc/puppetdb/ssl/ca.pem',
        master  => $facts['fqdn'],
    }

    class { 'profile::puppetdb::database':
        master         => $facts['fqdn'],
        ssldir         => $ssldir,
        shared_buffers => '2048MB',
    }

    # copy the catalog-differ puppet CA to validate connections to puppetdb
    file { '/etc/puppetdb/ssl/ca.pem':
        source => "${ssldir}/certs/ca.pem",
        owner  => 'puppetdb',
        before => Service['puppetdb']
    }

}
