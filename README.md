sap-hana-preconfigure
=====================

This role configures a RHEL 7.x system according to the SAP notes so that SAP HANA is installable

Requirements
------------

To use this role your system needs to be installed with at least the RHEL core packges.
It is strongly recommended that you have run the following roles before this:
 - 'linux-system-roles.timesync'
 - 'linux-system-roles.sap-base-settings'

It needs to be properly registered and have at least the following RedHat repositories accessable (see also example playbook):

 - RHEL Base Repository
 - RHEL SAP HANA Repository

For details see the Red Hat knowledge base article: [How to subscribe SAP HANA systems to the Update Services for SAP Solutions](https://access.redhat.com/solutions/3075991))
You can use the [subscribe-rhn](https://galaxy.ansible.com/mk-ansible-roles/subscribe-rhn/)  role to automate this process

To install HANA on Red Hat Enterprise Linux 6 or 7 you need some additional packages
which come in a special repository. To get this repository you need to have one
of the following products:

 - [RHEL for SAP Solutions](https://access.redhat.com/solutions/3082481) (premium, standard)
 - RHEL for Business Partner NFRs
 - [RHEL Developer Subscription](https://developers.redhat.com/products/sap/download/)

To achieve a personal developer edition of RHEL for SAP solutions, please register as a developer and download the developer edition.

- [Registration Link](http://developers.redhat.com/register) :
  Here you can either register a new personal account or link it to an already existing
  **personal** Red Hat Network account.
- [Download Link](https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.2/x86_64/product-software):
  Here you can download the Installation DVD for RHEL with your previously registered
  account

*NOTE:* This is a regular RHEL installation DVD as RHEL for SAP Solutions is no additional
 product but only a special bundling. The subscription grants you access to the additional
 packages through our content delivery network(CDN) after installation.

For supported RHEL releases [click here](https://access.redhat.com/solutions/2479121)

It is also important that your disks are setup according to the [SAP storage requirements for SAP HANA](https://www.sap.com/documents/2015/03/74cdb554-5a7c-0010-8F2c7-eda71af511fa.html). This [BLOG](https://blogs.sap.com/2017/03/07/the-ultimate-guide-to-effective-sizing-of-sap-hana/) is also quite helpful when sizing HANA systems.
You can use the [disk-init](https://galaxy.ansible.com/mk-ansible-roles/disk-init/)  role to automate this process

If you want to use this system in production make sure time service is configured correctly. You can use [rhel-system-roles](https://access.redhat.com/articles/3050101) to automate this

Role Variables
--------------

### HANA Major and minor version
These variables are used in all sap-hana roles so that they are only prefixed with `sap-hana`. If you use `sap-hana-mediacheck` role these variables are read in automatically. The variable is used in the checks for [SAP Note 2235581](https://launchpad.support.sap.com/#/notes/2235581).

```yaml
sap_hana_version: "2"
sap_hana_sps: "0"
```

### HANA validated OS check
If you want to make sure that this role stops, if this verison of RHEL is not yet validated for HANA set the following variable to no (Used in [SAP Note 2235581](https://launchpad.support.sap.com/#/notes/2235581) check):

```yaml
sap_hana_preconfigure_no_strict_version_check: "yes"
```

###  HANA kernel parameters
[SAP Note 238241](https://launchpad.support.sap.com/#/notes/238241) defines kernel parameters that all Linux systems need to set. The parameters recomendation is defined as default. If you need to add or change parameters for your system copy these parameters and change the default values

```yaml
sap_hana_preconfigure_kernel_parameters:
    - { name: net.core.somaxconn, value: 4096 }
    - { name: net.ipv4.tcp_max_syn_backlog, value: 8192}
    - { name: net.ipv4.ip_local_port_range, value: "40000 61000" }
    - { name: net.ipv4.tcp_timestamps, value: 1 }
    - { name: net.ipv4.tcp_tw_recycle, value: 1 }
    - { name: net.ipv4.tcp_slow_start_after_idle, value: 0 }
    - { name: net.ipv4.tcp_syn_retries, value: 8 }
     # Not sure about these .... they were in the old script and not set in tuned
    - { name: kernel.shmmni, value: 65536 }
    - { name: kernel.msgmni, value: 32768 }
    - { name: kernel.sysrq, value: 1 }
```

Here are some additional possible tuning parameters you may want to add. See [SAP Note 238241](https://launchpad.support.sap.com/#/notes/238241) for details:
```yaml
    # The following parameter do not work if communicates with hosts behind NAT firewall
    - { name: net.ipv4.tcp_tw_reuse, value: 1 }
    # Tune these for low latency system replication
    - { net.ipv4.tcp_wmem, value: ? }
    - { net.ipv4.tcp_rmem, value: ? }
```

### Reboot behaviour after update
The `installation.yaml` tasks install and update the system to with the current patches. If you want to reboot the system after updating if required after patching set the following default value to yes:

```yaml
sap_hana_preconfigure_reboot_after_update: false
```


Example Playbook
----------------

Here is an example playbook that prepares a server for hana installation.


```yaml
---
- hosts: hana
  remote_user: root

  vars:
      # subscribe-rhn role variables
      reg_activation_key: myregistration
      reg_organization_id: 123456

      repositories:
          - rhel-7-server-rpms
          - rhel-sap-hana-for-rhel-7-server-rpms

          # If you want to use 4 years update services, use:
          #       - rhel-7-server-e4s-rpms
          #       - rhel-sap-hana-for-rhel-7-server-e4s-rpms

          # If you want to use 2 years extend updates, use:
          #       - rhel-7-server-eus-rpms
          #       - rhel-sap-hana-for-rhel-7-server-eus-rpms


          # rhel-system-roles.timesync variables

  roles:
        - { role: mk-ansible-roles.subscribe-rhn }
        - { role: linux-system-roles.sap-base-settings }
        - { role: linux-system-roles.sap-hana-preconfigure }
```

Contribution
------------

Please read the [developer guidelines](./README.DEV.md)  if you want to contribute

License
-------

Apache License
Version 2.0, January 2004

Author Information
------------------

Markus Koch, Thomas Bludau

Please leave comments in the github repo issue list
