# Knife::Infoblox

A knife plugin for interacting with Infoblox DNS/IPAM servers.

## Usage

knife infoblox dns [cname HOSTNAME CANONICAL ] | [arecord HOSTNAME IP ] | [ptr HOSTNAME TARGET IPADDR]
knife infoblox host [create HOSTNAME1 [ HOSTNAME2...][-N NETWORK][-i IPADDRESS][-n SUGGEST][-m MACADDR]] 
                    [edit HOSTNAME [-m MACADDR][-i IP] 
                    [delete HOSTNAME [-i IP]]
knife infoblox ip [NETWORK [ --next-available|-n #COUNT ]]
knife infoblox network [NETWORK [ --next-available|-n [--exclude|-N LIST ] #COUNT ]]


## Installation

If you are running [Chef-DK](http://www.getchef.com/downloads/chef-dk) you can install it by running:

    $ chef gem install knife-infoblox

Otherwise, this plugin is distributed as a Ruby Gem. To install it, run:

    $ gem install knife-infoblox

Depending on your system's configuration, you may need to run this command with root privileges.

## Configuration
In addition to the command-specific options, the plugin supports a common set
of options: [-h INFOBLOX_HOSTNAME][-u INFOBLOX_USERNAME][-p INFOBLOX_PASSWORD]

Most options can be passed to the knife subcommands explicitly but this
quickly becomes tiring, repetitive, and error-prone. A better solution is to
add some of the common configuration to your `~/.chef/knife.rb` or your
projects `.chef/knife.rb` file like so:

```ruby
knife[:infoblox_username] = 'joetester'
knife[:infoblox_password] = 'hootytooty'
knife[:infoblox_hostname] = 'ns.example.com'
```

## Subcommands

The subcommands work the same way they work for [knife bootstrap](http://docs.opscode.com/chef/knife.html#bootstrap). Please see [http://docs.opscode.com/chef/knife.html#bootstrap](http://docs.opscode.com/chef/knife.html#bootstrap) for more information on the subcommands.
