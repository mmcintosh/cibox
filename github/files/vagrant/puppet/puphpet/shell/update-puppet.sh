#!/bin/bash

VAGRANT_CORE_FOLDER=$(cat "/.puphpet-stuff/vagrant-core-folder.txt")

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
RELEASE=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" RELEASE)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)

if [[ ! -f /.puphpet-stuff/update-puppet ]]; then
    if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
        echo "Downloading http://apt.puppetlabs.com/puppetlabs-release-${CODENAME}.deb"
        wget --quiet --tries=5 --connect-timeout=10 -O "/.puphpet-stuff/puppetlabs-release-${CODENAME}.deb" "http://apt.puppetlabs.com/puppetlabs-release-${CODENAME}.deb"
        echo "Finished downloading http://apt.puppetlabs.com/puppetlabs-release-${CODENAME}.deb"

        dpkg -i "/.puphpet-stuff/puppetlabs-release-${CODENAME}.deb" >/dev/null

        echo "Running update-puppet apt-get update"
        DEBIAN_FRONTEND=noninteractive apt-get update >/dev/null
        echo "Finished running update-puppet apt-get update"

        echo "Updating Puppet to version 3.4.x"
        DEBIAN_FRONTEND=noninteractive apt-get install -y puppet=3.4.3-1puppetlabs1 puppet-common=3.4.3-1puppetlabs1 >/dev/null
        PUPPET_VERSION=$(puppet help | grep 'Puppet v')
        echo "Finished updating puppet to latest version: ${PUPPET_VERSION}"

        touch /.puphpet-stuff/update-puppet
        echo "Created empty file /.puphpet-stuff/update-puppet"
    elif [ "${OS}" == 'centos' ]; then
        echo "Downloading http://yum.puppetlabs.com/el/${RELEASE}/products/x86_64/puppet-3.4.3-1.el6.noarch.rpm"
        yum -y --nogpgcheck install "http://yum.puppetlabs.com/el/${RELEASE}/products/x86_64/puppet-3.4.3-1.el6.noarch.rpm" >/dev/null
        echo "Finished downloading http://yum.puppetlabs.com/el/${RELEASE}/products/x86_64/puppet-3.4.3-1.el6.noarch.rpm"

        echo "Installing/Updating Puppet to version 3.4.x"
        yum -y install puppet >/dev/null
        PUPPET_VERSION=$(puppet help | grep 'Puppet v')
        echo "Finished installing/updating puppet to version: ${PUPPET_VERSION}"

        touch /.puphpet-stuff/update-puppet
        echo "Created empty file /.puphpet-stuff/update-puppet"
    fi
fi
