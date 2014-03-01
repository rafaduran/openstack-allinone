Routing Vagrant VMs traffic
===========================
Just run next command into your work machine in order to be able to access VMs
public IPs::

   $ sudo route -n add -net 172.24.4.224 10.10.0.202 255.255.255.240

Once your done you can delete it again with::

   $ sudo route -n delete -net 172.24.4.224 10.10.0.202 255.255.255.240
