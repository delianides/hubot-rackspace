Hubot Rackspace
===============
This is a hubot script for querying your Rackspace Cloud account for data about
your architecture without having to log into the dashboard.

Configuration
-------------

`HUBOT_RACKSPACE_API` - Rackspace API Key
`HUBOT_RACKSPACE_USERNAME` - Rackspace Username
`HUBOT_QUOTE_STRING` - The string your chat service uses to display plain text.
  eg: HipChat = `/quote`

Usage
-----
Right now you can only query Rackspace for the details of your cloud servers,
cloud load balancers and the DNS entries that you have listed in your account.

```
> hubot rack servers
> ┌───────────────────┬─────────────────┬────────────────┬──────────┐
  │ Name              │ Public IP       │ Private IP     │ Age      │
  ├───────────────────┼─────────────────┼────────────────┼──────────┤
  │ Server 1          │ 198.10.110.139  │ 10.210.23.100  │ 11 hours │
  ├───────────────────┼─────────────────┼────────────────┼──────────┤
  │ Server 2          │ 192.23.232.121  │ 10.210.02.201  │ 14 hours │
  ├───────────────────┼─────────────────┼────────────────┼──────────┤
  │ Server 3          │ 23.200.12.121   │ 10.210.00.101  │ 20 hours │
  └───────────────────┴─────────────────┴────────────────┴──────────┘

```
