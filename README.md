saphana-preconfigure
=====================

This role git@github.com:mk-ansible-roles/saphana-preconfigure.git. This role configures a RHEL 6.7 or 7.x system according to the SAP notes so that SAP HANA is installable

Requirements
------------

To use this role your system needs to be installed with at least the RHEL core packges and properly registered. It needs access to the software repositories required to install SAP HANA (see also: [How to subscribe SAP HANA systems to the Update Services for SAP Solutions](https://access.redhat.com/solutions/3075991))
You can use the [subscribe-rhn](https://galaxy.ansible.com/mk-ansible-roles/subscribe-rhn/)  role to automate this process

To install HANA on Red Hat Enterprise Linux 6 or 7 you need some additional packages
which come in a special repository. To get this repository you need to have one
of the following products:

 - [RHEL for SAP Solutions](https://access.redhat.com/solutions/3082481) (premium, standard, developer Edition)
 - RHEL for Business Partner NFRs

[Click here](https://developers.redhat.com/products/sap/download/) to achieve a personal developer edition of RHEL for SAP solutions. Please register as a developer and download the developer edition.

- [Registration Link](http://developers.redhat.com/register) :
  Here you can either register a new personal account or link it to an already existing
  **personal** Red Hat Network account.
- [Download Link](https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.2/x86_64/product-software):
  Here you can download the Installation DVD for RHEL with your previously registered
  account

*NOTE:* This is a regular RHEL installation DVD as RHEL for SAP Solutions is no additional
 product but only a special bundling. The subscription grants you access to the additional
 packages through our content delivery network(CDN) after installation.

For supported RHEL releases: https://access.redhat.com/solutions/2479121

It is also important that your disks are setup according to the [SAP storage requirements for SAP HANA](https://www.sap.com/documents/2015/03/74cdb554-5a7c-0010-82c7-eda71af511fa.html). This [BLOG](https://blogs.sap.com/2017/03/07/the-ultimate-guide-to-effective-sizing-of-sap-hana/) is also quite helpful when sizing HANA systems.
You can use the [disk-init](https://galaxy.ansible.com/mk-ansible-roles/disk-init/)  role to automate this process

If you want to use this system in production make sure time service is configured correctly. You can use [rhel-system-roles](https://access.redhat.com/articles/3050101) to automate this

Role Variables
--------------

### Configuration for SAP-Media-Check

The saphana preconfigure role has implemented a couple of different ways to access the sap installation media. At the end, the unpacked installation media has to be available at `hana_installdir`.

The scope of this check is to make sure that the HANA installation files are available on the host. Normally you have your own setup to do this, e.g. automounter or local copy. It figures out the HANA version you provided  to make installation decsions based on this information.
So you need to define the path to your HANA installation directory here:
* `hana_installdir : /path/to/hana/installdir`

If you want the media-check to mount the installation directory ready and unpacked from an nfs share define the follwoing variables:
* `install_nfs: "<ip-address>:/export/directory"` : NFS Share that holds installation tree
* `installroot: /somepath` : Mountpoint, where to mount the above share
* `hana_installdir: {{ installroot + '/wherever/the/files/are' }} `: path to HANA install dir

If you provide the downloaded rar files on an NFS share and you want to unpack the rar files locally  define the following variables:
* `install_nfs: "<ip-address>:/export/directory"` : NFS Share that holds the rar files
* `installroot: /install` where to unpack the Hana install binaries
* `installversion: "51051151"` :  Hana Install version. basically the numeric prefix of the first rar archive
In addition you need to provide an unrar binary to unpack the rar archives.  Red Hat cannot provide an unrar command, due to license restrictions, so that you need to provide it externally. If you have an appropriate package on your satellite server or internet access you can provide the name of the package in the varaible * `unrar_pkg`, here are some examples where to get working unrar packages:
* `unrar_pkg: http://apt.sw.be/redhat/el6/en/x86_64/rpmforge/RPMS/unrar-4.2.3-1.el6.rf.x86_64.rpm` for RHEL 6
* `unrar_pkg: https://dl.fedoraproject.org/pub/epel/7Server/x86_64/Packages/u/unar-1.10.1-1.el7.x86_64.rpm` for RHEL 7
* `unrar_pkg: unar ` use this if you have enabled EPEL on your RHEL 7 system

If you do not have an unrar package you can also provide a path to the unrar command in the variable `unrar_cmd`. I prefer putting it on the NFS-Share where my archives live, which is mounted to /tmp/install. So define the variable similar to this:
* `unrar_cmd: /tmp/install/bin/unrar`

When you unpack your installation archives like this, it is save to define hana_install dir like this
* `hana_installdir: "{{ installroot + '/' + installversion }}"`

### Further Variables to prepare the HANA deployment
- `hostname`: system hostname, needed for internal tests for Scale-Out and SAP Host Agent, and for multihomed systems. Use `"{{ ansible_hostname }}"` as default value. It's recommended to use `host_vars/hostname` to set this file
- `hana_pw_hostagent_ssl`: Password for SAP Host Agent
- `id_user_sapadm`: System user ID for Linux user sapadm
- `id_group_shm`: System Group ID for <sid>shm
- `id_group_sapsys`:  System group ID for Linux group sapsys
- `pw_user_sapadm_clear`: Password for Linux system user sapadm in clear text

The variable definitions can be in the playbook or can also be made in an according groups_var or host_vars file

Example Playbook
----------------

Here is an example playbook that installs a complete server

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

              # disk-init role variables
              disks:
                      /dev/vdc: vg00
                      /dev/vdb: vg00
              logvols:
                      hana_shared:
                              size: 24G
                              vol: vg00
                              mountpoint: /hana/shared
                      hana_data:
                              size: 24G
                              vol: vg00
                              mountpoint: /hana/data
                      hana_logs:
                              size: 12G
                              vol: vg00
                              mountpoint: /hana/logs
                      usr_sap:
                              size: 49G
                              vol: vg00
                              mountpoint: /usr/sap


              # rhel-system-roles.timesync variables
              ntp_servers:
                      - hostname: 0.rhel.pool.ntp.org
                        iburst: yes
                      - hostname: 1.rhel.pool.ntp.org
                        iburst: yes
                      - hostname: 2.rhel.pool.ntp.org
                        iburst: yes
                      - hostname: 3.rhel.pool.ntp.org
                        iburst: yes


              # SAP Precoonfigure role

              # SAP-Media Check
              install_nfs: "mynfsserver:/installi-export"
              installroot: /install
              hana_installdir: "{{ installroot + '/HANA2SPS02' }}"

              hana_pw_hostagent_ssl: "MyS3cret!"
              id_user_sapadm: "20202"
              id_group_shm: "20202"
              id_group_sapsys: "20202"
              pw_user_sapadm_clear: "MyS3cret!"

      roles:
              - { role: mk-ansible-roles.subscribe-rhn }
              - { role: mk-ansible-roles.disk-init }
              - { role: linux-system-roles.timesync }
              - { role: mk-ansible-roles.saphana-preconfigure }
              - { role: mk-ansible-roles.saphana-deploy }
              - { role: mk-ansible-roles.saphana-hsr }

License
-------

Apache License
Version 2.0, January 2004

Author Information
------------------

Markus Koch

Please leave comments in the github repo issue list
