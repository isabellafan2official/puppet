class profile::mariadb::sanitarium_multiinstance (
    $num_instances = hiera('profile::mariadb::sanitarium_multiinstance::num_instances'),
    $s1            = hiera('profile::mariadb::sanitarium_multiinstance::s1', false),
    $s2            = hiera('profile::mariadb::sanitarium_multiinstance::s2', false),
    $s3            = hiera('profile::mariadb::sanitarium_multiinstance::s3', false),
    $s4            = hiera('profile::mariadb::sanitarium_multiinstance::s4', false),
    $s5            = hiera('profile::mariadb::sanitarium_multiinstance::s5', false),
    $s6            = hiera('profile::mariadb::sanitarium_multiinstance::s6', false),
    $s7            = hiera('profile::mariadb::sanitarium_multiinstance::s7', false),
    $s8            = hiera('profile::mariadb::sanitarium_multiinstance::s8', false),
) {
    require profile::mariadb::packages_wmf
    class { 'mariadb::service':
        override => "[Service]\nExecStartPre=/bin/sh -c \"echo 'mariadb main service is \
disabled, use mariadb@<instance_name> instead'; exit 1\"",
    }

    include ::profile::mariadb::mysql_role

    class { 'mariadb::config':
        datadir       => false,
        basedir       => $profile::mariadb::packages_wmf::basedir,
        read_only     => 1,
        config        => 'profile/mariadb/mysqld_config/sanitarium_multiinstance.my.cnf.erb',
        p_s           => 'on',
        ssl           => 'puppet-cert',
        binlog_format => 'ROW',
    }

    file { '/etc/mysql/mysqld.conf.d':
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0755',
    }

    if $s1 {
        mariadb::instance { 's1':
            port                    => 3311,
            innodb_buffer_pool_size => $s1,
        }
        profile::mariadb::section { 's1': }
        profile::mariadb::ferm { 's1': port => '3311' }
        profile::prometheus::mysqld_exporter_instance { 's1': port => 13311, }
        profile::mariadb::replication_lag { 's1': prom_port => 13311, }
    }
    if $s2 {
        mariadb::instance { 's2':
            port                    => 3312,
            innodb_buffer_pool_size => $s2,
        }
        profile::mariadb::section { 's2': }
        profile::mariadb::ferm { 's2': port => '3312' }
        profile::prometheus::mysqld_exporter_instance { 's2': port => 13312, }
        profile::mariadb::replication_lag { 's2': prom_port => 13312, }
    }
    if $s3 {
        mariadb::instance { 's3':
            port                    => 3313,
            innodb_buffer_pool_size => $s3,
        }
        profile::mariadb::section { 's3': }
        profile::mariadb::ferm { 's3': port => '3313' }
        profile::prometheus::mysqld_exporter_instance { 's3': port => 13313, }
        profile::mariadb::replication_lag { 's3': prom_port => 13313, }
    }
    if $s4 {
        mariadb::instance { 's4':
            port                    => 3314,
            innodb_buffer_pool_size => $s4,
        }
        profile::mariadb::section { 's4': }
        profile::mariadb::ferm { 's4': port => '3314' }
        profile::prometheus::mysqld_exporter_instance { 's4': port => 13314, }
        profile::mariadb::replication_lag { 's4': prom_port => 13314, }
    }
    if $s5 {
        mariadb::instance { 's5':
            port                    => 3315,
            innodb_buffer_pool_size => $s5,
        }
        profile::mariadb::section { 's5': }
        profile::mariadb::ferm { 's5': port => '3315' }
        profile::prometheus::mysqld_exporter_instance { 's5': port => 13315, }
        profile::mariadb::replication_lag { 's5': prom_port => 13315, }
    }
    if $s6 {
        mariadb::instance { 's6':
            port                    => 3316,
            innodb_buffer_pool_size => $s6,
        }
        profile::mariadb::section { 's6': }
        profile::mariadb::ferm { 's6': port => '3316' }
        profile::prometheus::mysqld_exporter_instance { 's6': port => 13316, }
        profile::mariadb::replication_lag { 's6': prom_port => 13316, }
    }
    if $s7 {
        mariadb::instance { 's7':
            port                    => 3317,
            innodb_buffer_pool_size => $s7,
        }
        profile::mariadb::section { 's7': }
        profile::mariadb::ferm { 's7': port => '3317' }
        profile::prometheus::mysqld_exporter_instance { 's7': port => 13317, }
        profile::mariadb::replication_lag { 's7': prom_port => 13317, }
    }
    if $s8 {
        mariadb::instance { 's8':
            port                    => 3318,
            innodb_buffer_pool_size => $s8,
        }
        profile::mariadb::section { 's8': }
        profile::mariadb::ferm { 's8': port => '3318' }
        profile::prometheus::mysqld_exporter_instance { 's8': port => 13318, }
        profile::mariadb::replication_lag { 's8': prom_port => 13318, }
    }

    class { 'mariadb::monitor_disk':
        is_critical   => false,
        contact_group => 'admins',
    }

    class { 'mariadb::monitor_process':
        process_count => $num_instances,
        is_critical   => false,
        contact_group => 'admins',
    }

    class { 'mariadb::monitor_memory': }
}
