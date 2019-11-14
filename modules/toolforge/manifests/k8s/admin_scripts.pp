class toolforge::k8s::admin_scripts (
) {
    file { '/usr/local/sbin/wmcs-k8s-get-cert':
        ensure => 'present',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => 'puppet:///modules/toolforge/k8s/admin_scripts/wmcs-k8s-get-cert.sh',
    }
}
