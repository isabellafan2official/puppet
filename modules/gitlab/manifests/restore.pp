class gitlab::restore(
  Wmflib::Ensure   $restore_ensure          = 'present',
  Wmflib::Ensure   $restore_ensure_timer    = 'present',
  Stdlib::Unixpath $restore_dir_data        = '/srv/gitlab-backup',
){

  # install restore script
  file {"${restore_dir_data}/gitlab-restore.sh":
      ensure => $restore_ensure,
      mode   => '0744' ,
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/gitlab/gitlab-restore.sh';
  }

  file {"${restore_dir_data}/gitlab-restore-v2.sh":
      ensure => $restore_ensure,
      mode   => '0744' ,
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/gitlab/gitlab-restore-v2.sh';
    }

  # systemd timer for backup restore
  systemd::timer::job { 'backup-restore':
      ensure      => $restore_ensure_timer,
      user        => 'root',
      description => 'GitLab Backup Restore',
      command     => "${restore_dir_data}/gitlab-restore.sh",
      interval    => {'start' => 'OnCalendar', 'interval' => '*-*-* 00:45:00'},
  }
}
