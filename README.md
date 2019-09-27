sap-hana-preconfigure
=====================

This role configures a RHEL 7.x or RHEL 8 system according to the SAP notes so that SAP HANA is installable

Requirements
------------

To use this role your system needs to be installed with at least the RHEL core packges.
It is strongly recommended that you have run the following roles before this:
 - 'linux-system-roles.timesync'
 - 'linux-system-roles.sap-base-settings' (for RHEL 7.x)
 - 'linux-system-roles.sap-preconfigure' (for RHEL 8.x)

It needs to be properly registered and have at least the following RedHat repositories accessable (see also example playbook):

for RHEL 7.x:
 - RHEL Base Repository
 - RHEL SAP HANA Repository

for RHEL 8.x:
 - Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)
 - Red Hat Enterprise Linux 8 for x86_64 - BaseOS (RPMs)
 - Red Hat Enterprise Linux 8 for x86_64 - SAP Solutions (RPMs)


For details, see the Red Hat knowledge base article: [How to subscribe SAP HANA systems to the Update Services for SAP Solutions](https://access.redhat.com/solutions/3075991))
You can use the [subscribe-rhn](https://galaxy.ansible.com/mk-ansible-roles/subscribe-rhn/) role to automate this process

To install HANA on Red Hat Enterprise Linux 6, 7, or 8, you need some additional packages
which come in a special repository. To get this repository you need to have one
of the following products:

 - [RHEL for SAP Solutions](https://access.redhat.com/solutions/3082481) (premium, standard)
 - RHEL for Business Partner NFRs
 - [RHEL Developer Subscription](https://developers.redhat.com/products/sap/download/)

To get a personal developer edition of RHEL for SAP solutions, please register as a developer and download the developer edition.

- [Registration Link](http://developers.redhat.com/register) :
  Here you can either register a new personal account or link it to an already existing
  **personal** Red Hat Network account.
- [Download Link](https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.2/x86_64/product-software):
  Here you can download the Installation DVD for RHEL with your previously registered
  account

*NOTE:* This is a regular RHEL installation DVD as RHEL for SAP Solutions is no additional
 product but only a special bundling. The subscription grants you access to the additional
 packages through our content delivery network (CDN) after installation.

For supported RHEL releases [click here](https://access.redhat.com/solutions/2479121)

It is also important that your disks are setup according to the [SAP storage requirements for SAP HANA](https://www.sap.com/documents/2015/03/74cdb554-5a7c-0010-8F2c7-eda71af511fa.html). This [BLOG](https://blogs.sap.com/2017/03/07/the-ultimate-guide-to-effective-sizing-of-sap-hana/) is also quite helpful when sizing HANA systems.
You can use the [disk-init](https://galaxy.ansible.com/mk-ansible-roles/disk-init/) role to automate this process

If you want to use this system in production make sure time service is configured correctly. You can use [rhel-system-roles](https://access.redhat.com/articles/3050101) to automate this

Role Variables
--------------

### SAP notes to apply
The following variable contains a list of all SAP notes which are used for this role:
```yaml
sap_hana_preconfigure_sapnotes
```

### Switch to tuned profile sap-hana
If you want to switch on tuned profile sap-hana, set the following variable to true (this is the default):
```yaml
sap_hana_preconfigure_switch_to_tuned_profile_sap_hana
```

### Use tuned profile sap-hana where possible
If you want to use the tuned profile sap-hana for configuring kernel parameters where possible and not have the role configure them, set the following variable to true (this is the default):
```yaml
sap_hana_preconfigure_use_tuned_where_possible
```

### Modify grub2 line GRUB_CMDLINE_LINUX
If you do not want to modify the grub2 line GRUB_CMDLINE_LINUX in /etc/default/grub, set the following variable to no (this is the default):
```yaml
sap_hana_preconfigure_modify_grub_cmdline_linux
```

### Run grub2-mkconfig
If you do not want to run grub2-mkconfig to regenerate the grub2 config file, set the following variable to no (this is the default). Before setting this variable to yes, make sure you also have set sap_hana_preconfigure_modify_grub_cmdline_linux (see above) to yes.
```yaml
sap_hana_preconfigure_run_grub2_mkconfig
```

### Required package groups
The following variables define the required package groups. Note that variable sap_hana_preconfigure_packagegroups is automatically filled from either sap_hana_preconfigure_packagegroups_x86_64 or sap_hana_preconfigure_packagegroups_ppc64le:
```yaml
sap_hana_preconfigure_packagegroups_x86_64
sap_hana_preconfigure_packagegroups_ppc64le
sap_hana_preconfigure_packagegroups_s390x
sap_hana_preconfigure_packagegroups
```

### Required packages
The following variables define the required packages:
```yaml
sap_hana_preconfigure_packages
sap_hana_preconfigure_required_ppc64le
```

### Minimum required packages for certain RHEL releases:
The following variables contains a list of packages and their minimum versions according to SAP note 2235581, if any:
```yaml
sap_hana_preconfigure_min_packages_8
sap_hana_preconfigure_min_packages_7.7
sap_hana_preconfigure_min_packages_7.6
sap_hana_preconfigure_min_packages_7.5
sap_hana_preconfigure_min_packages_7.4
sap_hana_preconfigure_min_packages_7.3
sap_hana_preconfigure_min_packages_7.2
```

### HANA Major and minor version
These variables are used in all sap-hana roles so that they are only prefixed with `sap-hana`. If you use `sap-hana-mediacheck` role these variables are read in automatically. The variable is used in the checks for [SAP Note 2235581](https://launchpad.support.sap.com/#/notes/2235581).

```yaml
sap_hana_version: "2"
sap_hana_sps: "0"
```

### HANA validated OS check
If you want to make sure that this role stops if this verison of RHEL is not yet validated for HANA,
set the following variable to no (used in [SAP Note 2235581](https://launchpad.support.sap.com/#/notes/2235581) check):

```yaml
sap_hana_preconfigure_no_strict_version_check: "yes"
```

###  HANA kernel parameters
[SAP Note 238241](https://launchpad.support.sap.com/#/notes/238241) defines kernel parameters that all Linux systems need to set. The parameters recomendation is defined as default. If you need to add or change parameters for your system copy these parameters and change the default values

```yaml
sap_hana_preconfigure_kernel_parameters:
    - { name: net.core.somaxconn, value: 4096 }
    - { name: net.ipv4.tcp_max_syn_backlog, value: 8192}
    - { name: net.ipv4.tcp_timestamps, value: 1 }
    - { name: net.ipv4.tcp_slow_start_after_idle, value: 0 }
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

Here is a simple playbook:

```yaml
---
    - hosts: all
      roles:
         - role: sap-preconfigure
         - role: sap-hana-preconfigure
```

Contribution
------------

Please read the [developer guidelines](./README.DEV.md) if you want to contribute

License
-------

GNU General Public License v3.0

Author Information
------------------

Markus Koch, Thomas Bludau, Bernd Finger, Than Ngo

Please leave comments in the github repo issue list
