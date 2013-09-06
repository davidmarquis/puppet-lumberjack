# Class: lumberjack::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'lumberjack::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
# Edit: Kayla Green <mailto:kaylagreen771@gmail.com>
#
class lumberjack::config {
    File {
        owner => root,
        group => root
    }
  
    $configdir = $lumberjack::params::configdir

    if ($lumberjack::ensure == 'present') {
        # Manage the single instance dir
        file { "${configdir}":
            ensure  => directory,
            mode    => '0644',
        }

        # Manage the single config dir
        file { "${configdir}/conf":
            ensure  => directory,
            mode    => '0640',
            purge   => true,
            recurse => true,
            require => File ["${configdir}"],
        }
          # Manage the single config dir
        file { "${configdir}/bin":
            ensure  => directory,
            mode    => '0644',
            require => File ["${configdir}"],
        }


        #Create network portion of config file
        $servers = $lumberjack::servers
        $ssl_ca = $lumberjack::ssl_ca_path
        $ssl_certificate = $lumberjack::ssl_certificate
        $ssl_key = $lumberjack::ssl_key
        
        #### Setup configuration files
        include concat::setup
        concat{ "${configdir}/conf/lumberjack.conf":
            require => File["${configdir}/conf"],
        }

        # Add network portion of the config file
        concat::fragment{"default-start":
            target  => "${configdir}/conf/lumberjack.conf",
            content => template("${module_name}/network_format.erb"),
            order   => 001,
        }  

        # Add the ending brackets and additional set of {} brackets needed to fix comma/json parsing issue
        concat::fragment{"default-end":
            target  => "${configdir}/conf/lumberjack.conf",
            content => "\n\t\t}\n\t]\n}\n",
            order   => 999,
        }
        
    } else {
        # Remove the lumberjack directory and all of its configs. 
        file {$configdir : 
            ensure  => 'absent',
            purge   => true,
            recurse => true,
            force   => true,
        }
        
    }
}
