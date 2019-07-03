class profile::toolforge::k8s::apilb (
        $servers = hiera('profile::toolforge::k8s::api_servers'),
    ) {
    class { 'haproxy':
        template => 'profile/toolforge/k8s/apilb/haproxy.cfg.erb',
        monitor  => false,
    }

    file { '/etc/haproxy/conf.d/k8s-api-servers.cfg':
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('profile/toolforge/k8s/apilb/k8s-api-servers.cfg.erb'),
    }

    exec { 'toolforge_k8s_apilb_reload_haproxy_service':
        command     => '/bin/systemctl reload haproxy',
        subscribe   => File['/etc/haproxy/conf.d/k8s-api-servers.cfg'],
        refreshonly => true,
    }
}
