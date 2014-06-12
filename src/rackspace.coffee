# Description:
#   Rackspace is a cloud hosting company. This script is to output various information
#   from their API.
#
# Dependencies:
#   "cli-table": "~0.3.0",
#   "pkgcloud": "~0.9.5",
#   "moment": "~2.6.0"
#
# Configuration
#   HUBOT_RACKSPACE_USERNAME
#   HUBOT_RACKSPACE_API
#   HUBOT_QUOTE_STRING
#
# Commands:
#   hubot rack servers, Return table of the servers in Rackspace.
#   hubot rack clb, Returns table of information about the load balancers
#   hubot rack dns <domain>, Returns information about the specified DNS entry in rackspace.
#

Table = require "cli-table"
pkgcloud = require "pkgcloud"
moment = require "moment"

rackspace = {
    provider: 'rackspace',
    username: process.env.RACKSPACE_USERNAME,
    apiKey: process.env.RACKSPACE_API,
    region: 'ord'
}

REGIONS = ["ord","dfw","iad","syd","hkg"]

module.exports = (robot) ->
  robot.respond /rack servers/i, (msg) ->
    table = new Table({
      head: ['Name', 'Public IP', 'Private IP', 'Region', 'Age'],
      style: { head:[], border:[], 'padding-left': 1, 'padding-right': 1 }
    })
    for region in REGIONS
      rackspace.region = region
      client = pkgcloud.compute.createClient(rackspace)
      client.getServers((err, servers) ->
        if(err)
          msg.send err
          return false
        else
          for server in servers
            now = moment()
            since = now.from(server.original.created, true)
            table.push(
              ["#{server.name}",
                "#{asIp(server.original.accessIPv4)}",
                "#{asIp(server.addresses.private[0].addr)}",
                "#{region}",
                "#{since}"]
            )
      )
    msg.plain table.toString()

  robot.respond /rack clb/i, (msg) ->
    table = new Table({
      head: ['Name', 'Protocol', 'Port', 'Public IP', 'Nodes'],
      style: { head:[], border:[], 'padding-left': 1, 'padding-right': 1 }
    })

    for region in REGIONS
      rackspace.region = region
      client = pkgcloud.loadbalancer.createClient(rackspace)
      client.getLoadBalancers((err, loadbalancers) ->
        if(err)
          msg.send err
          return false
        else
          for lbs in loadbalancers
            table.push(
              ["#{lbs.name}",
              "#{lbs.protocol}",
              "#{lbs.port}",
              "#{asIp(lbs.virtualIps[0].address)}",
              "#{lbs.nodeCount}"]
            )
      )
    msg.plain table.toString()

  robot.respond /rack dns (.*)/i, (msg) ->
    domain = escape(msg.match[1])
    client = pkgcloud.dns.createClient(rackspace)
    details = {name: domain}
    client.getZones(details, (err, zones) ->
      if(err)
        msg.send err
        return false
      else
        if (zones.length < 1)
          msg.send "I didn't find that domain at Rackspace!"
          return false

        client.getRecords(zones[0].id,( err, records) ->
          if(err)
            msg.send err
          else
            table = new Table({
              head: ['Name', 'Type', 'Data', 'TTL'],
              style: { head:[], border:[], 'padding-left': 1, 'padding-right': 1 }
            })

            for record in records
              table.push(
               ["#{record.name}",
                "#{record.type}",
                "#{record.data}",
                "#{moment.duration((record.ttl/60), "minutes" ).humanize()}"]
              )
            msg.plain table.toString()
        )
    )

asIp = (ip) ->
  if ip == null or ip == ''
    return "Not Set"
  else
    return ip

