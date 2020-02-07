# == Class role::pybal::testing
#
# Class for a pybal test host

class role::pybal::testing {
    include ::pybal
    $opts = {
        'instrumentation' => 'yes',
        'bgp'             => 'no',
        'dry-run'         => 'yes',
    }
    # TODO: fix this.\
    $services = wmflib::service::get_services_for_lvs('secondary', $::site)

    $lvs_class_hosts_stub = {
        'high-traffic1' => [$::hostname],
        'high-traffic2' => [$::hostname],
        'low-traffic'   => [$::hostname],
    }
    class { 'pybal::configuration':
        global_options  => $opts,
        services        => $services,
        lvs_class_hosts => $lvs_class_hosts_stub,
        site            => hiera('pybal::configuration::site', 'eqiad'),
        config          => hiera('pybal::configuration::config', 'http'),
        config_host     => hiera(
            'pybal::configuration::config_host', 'config-master.eqiad.wmnet'),
    }
}
