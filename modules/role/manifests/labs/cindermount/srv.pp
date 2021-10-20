# == Class role::labs::cindermount::srv
#
# Detect an unused, attached cinder volume, format it and mount it on /srv
#
class role::labs::cindermount::srv {
    include ::profile::labs::cindermount::srv

    system::role { 'labs:cindermount::srv':
        description => 'Mount cinder volume in /srv',
    }
}
