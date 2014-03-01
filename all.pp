node default {
  include 'openstack::all'
  include 'openstack::auth_file'

  cinder_config { 'DEFAULT/volume_driver':
    value => 'cinder.volume.drivers.lvm.LVMISCSIDriver',
  }

  neutron_dhcp_agent_config { 'DEFAULT/dnsmasq_dns_server':
    value => '8.8.8.8',
  }

  include 'cinder::setup_test_volume'
  include 'openstack::provision'
}
