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

  $public_network_name = 'public'
  $public_subnet_name = 'public_subnet'
  $private_network_name = 'private'
  $private_subnet_name = 'private_subnet'
  $floating_range = '172.24.4.224/28'
  $fixed_range = '10.0.0.0/24'
  $router_name = 'router1'
  $public_bridge_name = 'br-ex'
  $admin_tenant_name = 'admin'

  neutron_network { $public_network_name:
    ensure          => present,
    router_external => true,
    tenant_id       => "None",
  }

  neutron_subnet { $public_subnet_name:
    ensure          => 'present',
    cidr            => $floating_range,
    enable_dhcp     => false,
    network_name    => $public_network_name,
    tenant_name     => $admin_tenant_name,
  }

  neutron_network { $private_network_name:
    ensure      => present,
    tenant_name => $admin_tenant_name,
  }

  neutron_subnet { $private_subnet_name:
    ensure       => present,
    cidr         => $fixed_range,
    network_name => $private_network_name,
    tenant_name  => $admin_tenant_name,
  }

  neutron_router { $router_name:
    ensure               => present,
    tenant_name          => $admin_tenant_name,
    gateway_network_name => $public_network_name,
    # A neutron_router resource must explicitly declare a dependency on
    # the first subnet of the gateway network.
    require              => Neutron_subnet[$public_subnet_name],
  }

  neutron_router_interface { "${router_name}:${private_subnet_name}":
    ensure => present,
  }

  neutron_l3_ovs_bridge { $public_bridge_name:
    ensure      => present,
    subnet_name => $public_subnet_name,
  }

  firewall { '000 fordward in':
    ensure     => 'present',
    action     => 'accept',
    chain      => 'FORWARD',
    iniface    => 'br-ex',
    proto      => 'all',
    table      => 'filter',
  }

  firewall { '000 fordward out':
    ensure     => 'present',
    action     => 'accept',
    chain      => 'FORWARD',
    isfragment => 'false',
    outiface   => 'br-ex',
    proto      => 'all',
    table      => 'filter',
  }

  firewall { '000 nat':
    ensure     => 'present',
    chain      => 'POSTROUTING',
    jump       => 'MASQUERADE',
    outiface   => 'eth0',
    proto      => 'all',
    source     => '172.24.4.224/28',
    table      => 'nat',
  }

  $ubuntu_url = 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img'
  $centos_url = 'http://repos.fedorapeople.org/repos/openstack/guest-images/centos-6.5-20140117.0.x86_64.qcow2'
  glance_image { 'Ubuntu 12.04':
    ensure           => present,
    is_public        => 'yes',
    container_format => 'bare',
    disk_format      => 'qcow2',
    source           => $ubuntu_url,
  }

  glance_image { 'CentOS 6.5':
    ensure           => present,
    is_public        => 'yes',
    container_format => 'bare',
    disk_format      => 'qcow2',
    source           => $centos_url,
  }
}
