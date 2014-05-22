# vim: set ts=4 et sw=4:
# role/ocg.pp
# Offline content generator for the MediaWiki collection extension

# Virtual resources for the monitoring server
@monitor_group { 'ocg_eqiad': description => 'offline content generator eqiad' }

class role::ocg::production {
    system::role { 'ocg': description => 'offline content generator for MediaWiki Collection extension' }

    include passwords::redis

    if ( $::ocg_redis_server_override != undef ) {
        $redis_host = $::ocg_redis_server_override
    } else {
        # Default host in the WMF production env... this needs a variable or something
        $redis_host = 'rdb1002.eqiad.wmnet'
	}

    class { '::ocg':
        redis_host      => $redis_host,
        redis_password  => $passwords::redis::main_password,
        temp_dir        => '/srv/deployment/ocg/tmp',
    }

    monitor_service { 'ocg':
        description   => 'Offline Content Generation - Collection',
        check_command => "check_http_on_port!80",
    }
}

class role::ocg::test {
    system::role { 'ocg-test': description => 'offline content generator for MediaWiki Collection extension (single host testing)' }

    include passwords::redis

    class { '::ocg':
        redis_host      => 'localhost',
        redis_password  => $passwords::redis::ocg_test_password,
        temp_dir        => '/srv/deployment/ocg/tmp',
    }

    class { 'redis':
        maxmemory       => '500Mb',
        password        => $passwords::redis::ocg_test_password,
    }
}
