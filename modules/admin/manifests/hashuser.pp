# A defined type for user creation from hash
#
# === Parameters
#
# [*name*]
#  Hash user name
#
# [*ensure_ssh_key*]
#  If the user is allowed to have a SSH key or not.
#  Useful when a user is needed on a host without
#  allowing ssh access.
#  Default: true
#
define admin::hashuser (
    Boolean $ensure_ssh_key = true,
) {

    $uinfo = $::admin::data['users'][$name]

    if has_key($uinfo, 'gid') {
        $group_id = $uinfo['gid']
    } else {
        $group_id = $uinfo['uid']
    }

    if has_key($uinfo, 'ssh_keys') and $ensure_ssh_key {
        $key_set = $uinfo['ssh_keys']
    } else {
        $key_set = []
    }

    admin::user { $name:
        ensure     => $uinfo['ensure'],
        uid        => $uinfo['uid'],
        gid        => $group_id,
        groups     => $uinfo['groups'],
        comment    => $uinfo['realname'],
        shell      => $uinfo['shell'],
        privileges => $uinfo['privileges'],
        ssh_keys   => $key_set,
    }
}
