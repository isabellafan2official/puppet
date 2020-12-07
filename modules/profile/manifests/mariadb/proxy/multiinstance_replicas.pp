# load balancing between several replica dbs on several instances!
class profile::mariadb::proxy::multiinstance_replicas(
    Optional[Hash[String,Hash]]     $section_overrides = lookup('profile::mariadb::proxy::multiinstance_replicas::section_overrides', {default_value => undef}),
    Hash[String,Stdlib::Port]       $section_ports     = lookup('profile::mariadb::section_ports'),
    Enum['analytics', 'web']        $replica_type      = lookup('profile::mariadb::proxy::multiinstance_replicas::replica_type'),
    ) {

    # This template is for stretch/HA1.7, may not work on earlier/later versions
    $replicas_template = 'multi-db-replicas.cfg.erb'

    # Generate a hash of valid backend servers for each section from puppetdb
    # The intent here is to define instances *on the db servers only*
    # because defining them all by hand for both haproxy servers seems like toil
    $replica_sections = ['s1','s2','s3','s4','s5','s6','s7','s8']
    $default_backend_servers = $replica_sections.reduce({}) |$memo, $section|{
        $memo + {$section =>  query_facts(
                    "Class['role::wmcs::db::wikireplicas::${replica_type}_multiinstance'] and Profile::Mariadb::Section[${section}]",
                    ['fqdn', 'ipaddress']
                )}
    }
    # This next part is mostly necessary so that the puppet catalog compiler
    # works as expected. Without it, it either errors or does odd things because
    # it lacks puppetdb.
    $scrubbed_servers = $default_backend_servers.filter |$section|{
        !$section[1].empty
    }

    # Merge $section_overrides to provide weights and depoolings
    if $section_overrides {
        $section_servers = $scrubbed_servers + $section_overrides
    } else {
        $section_servers = $scrubbed_servers
    }
    file { '/etc/haproxy/conf.d/multi-db-replicas.cfg':
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template("profile/mariadb/proxy/${replicas_template}"),
    }
}