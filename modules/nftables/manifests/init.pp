class nftables (
    Wmflib::Ensure $ensure_package = 'present',
    Wmflib::Ensure $ensure_service = 'absent',
) {
    requires_os('debian >= buster')

    package { 'nftables':
        ensure => $ensure_package,
    }

    # if we want the service to be stopped, it indicates we actually don't want this unit running
    # this may prevent accidents in servers whose firewall is managed by others (e.g, neutron)
    if $ensure_service == 'absent' {
        systemd::mask { 'nftables.service': }
    }
    if $ensure_service == 'present' {
        systemd::unmask { 'nftables.service': }
    }

    $nft_main_file = '/etc/nftables/main.nft' # used in the systemd template
    systemd::service { 'nftables':
        ensure   => $ensure_service,
        content  => systemd_template('nftables'),
        override => true,
    }

    # create a directory to hold the nftables config
    file { '/etc/nftables/':
        ensure => 'directory',
    }

    # deploy the basic configuration file, i.e, the basic nftables ruleset skeleton
    file { $nft_main_file:
        ensure  => $ensure_package,
        source  => 'puppet:///modules/nftables/main.nft',
        require => File['/etc/nftables'],
        notify  => Systemd::Service['nftables'],
    }

    # cleanup the file shipped with the debian package, we don't use it
    file { '/etc/nftables.conf':
        ensure => 'absent',
    }

    File <| tag == 'nft' |>
}
