class openstack::cinder::service::rocky(
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
    String $libvirt_rbd_uuid,
) {
    require "openstack::serverpackages::rocky::${::lsbdistcodename}"

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
            content   => template('openstack/rocky/cinder/cinder.conf.erb'),
            owner     => 'cinder',
            group     => 'nogroup',
            mode      => '0440',
            show_diff => false,
            notify    => Service['cinder-scheduler', 'nova-api', 'cinder-volume', 'cinder-api'],
            require   => Package['cinder-api', 'cinder-scheduler', 'cinder-volume'];
        '/etc/cinder/policy.json':
            ensure  => 'absent';
        '/etc/cinder/policy.yaml':
            source  => 'puppet:///modules/openstack/rocky/cinder/policy.yaml',
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            require => Package['cinder-api'];
    }
}
