# == Define: prometheus::rules
#
# Add a Prometheus 'recording rule', see also:
# https://prometheus.io/docs/querying/rules/
# https://prometheus.io/docs/practices/rules/
#
# = Parameters
#
# [*instance*]
#   The Prometheus instance the rule is for.
#
# [*instance_path*]
#   The Prometheus instance path on filesystem.

define prometheus::rule (
    $instance,
    $ensure = 'present',
    $source = undef,
    $content = undef,
    $instance_path = "/srv/prometheus/${instance}",
) {
    validate_ensure($ensure)
    validate_re($title, '.conf$')

    $service_name = "prometheus@${instance}"
    $file_path = "${instance_path}/rules/${title}"

    $prometheus_v2 = hiera('prometheus::server::prometheus_v2', false)
    if $prometheus_v2 {
      $validate_cmd = '/usr/bin/promtool check rules %'
    } else {
      $validate_cmd = '/usr/bin/promtool check-rules %'
    }

    file { $file_path:
        ensure       => file,
        mode         => '0444',
        owner        => 'root',
        source       => $source,
        content      => $content,
        notify       => Exec["${service_name}-rules-reload"],
        validate_cmd => $validate_cmd,
    }

    exec { "${service_name}-rules-reload":
        command     => "/bin/systemctl reload ${service_name}",
        refreshonly => true,
    }
}
