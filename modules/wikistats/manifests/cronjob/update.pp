# define a cronjob to update a wikistats table
# usage: <project prefix>@<hour>
define wikistats::cronjob::update (
    String $project = $name,
    Integer $hour = 0,
    Integer $minute = 0,
    Wmflib::Ensure $ensure = 'present',
){

    cron { "cron-wikistats-update-${name}":
        ensure  => $ensure,
        command => "/usr/bin/php /usr/lib/wikistats/update.php ${project} > /var/log/wikistats/update_${name}.log 2>&1",
        user    => 'wikistatsuser',
        hour    => $hour,
        minute  => $minute,
    }
}

