class openstack::cinder::service::stein(
    $openstack_controllers,
    $db_user,
    $db_pass,
    $db_name,
    $db_host,
    $ldap_user_pass,
    $keystone_admin_uri,
    $region,
    String $ceph_pool,
    String $rabbit_user,
    String $rabbit_pass,
    Stdlib::Port $api_bind_port,
    String $libvirt_rbd_cinder_uuid,
) {
    require "openstack::serverpackages::stein::${::lsbdistcodename}"

    package { 'cinder-api':
        ensure => 'present',
    }
    package { 'cinder-scheduler':
        ensure => 'present',
    }
    package { 'cinder-volume':
        ensure => 'present',
    }

    file {
        '/etc/cinder/cinder.conf':
            content   => template('openstack/stein/cinder/cinder.conf.erb'),
            owner     => 'cinder',
            group     => 'cinder',
            mode      => '0440',
            show_diff => false,
            notify    => Service['cinder-scheduler', 'nova-api', 'cinder-volume', 'cinder-api'],
            require   => Package['cinder-api', 'cinder-scheduler', 'cinder-volume'];
        '/etc/cinder/policy.json':
            ensure  => 'absent';
        '/etc/cinder/policy.yaml':
            source  => 'puppet:///modules/openstack/stein/cinder/policy.yaml',
            owner   => 'cinder',
            group   => 'cinder',
            mode    => '0644',
            require => Package['cinder-api'];
        '/etc/cinder/resource_filters.json':
            source  => 'puppet:///modules/openstack/stein/cinder/resource_filters.json',
            owner   => 'cinder',
            group   => 'cinder',
            mode    => '0644',
            require => Package['cinder-api'];
    }
}
