#!/usr/bin/tclsh

# set server ip and/or port if needed
set server {127.0.0.1}
set port {18120}

# set server status client password
set server_passwd {SuperSecretPassword}

set stat_type 3

set lookup_list [list {FreeRADIUS-Total-Access-Requests|freeradius.Total.Access.Requests|} {FreeRADIUS-Total-Access-Accepts|freeradius.Total.Access.Accepts|} {FreeRADIUS-Total-Access-Rejects|freeradius.Total.Access.Rejects|} {FreeRADIUS-Total-Access-Challenges|freeradius.Total.Access.Challenges|} {FreeRADIUS-Total-Auth-Responses|freeradius.Total.Auth.Responses|} {FreeRADIUS-Total-Auth-Duplicate-Requests|freeradius.Total.Auth.Duplicate-Requests|} {FreeRADIUS-Total-Auth-Malformed-Requests|freeradius.Total.Auth.Malformed-Requests|} {FreeRADIUS-Total-Auth-Invalid-Requests|freeradius.Total.Auth.Invalid-Requests|} {FreeRADIUS-Total-Auth-Dropped-Requests|freeradius.Total.Auth.Dropped-Requests|} {FreeRADIUS-Total-Auth-Unknown-Types|freeradius.Total.Auth.Unknown-Types|} {FreeRADIUS-Total-Accounting-Requests|freeradius.Total.Accounting.Requests|} {FreeRADIUS-Total-Accounting-Responses|freeradius.Total.Accounting.Responses|} {FreeRADIUS-Total-Acct-Duplicate-Requests|freeradius.Total.Acct.Duplicate-Requests|} {FreeRADIUS-Total-Acct-Malformed-Requests|freeradius.Total.Acct.Malformed-Requests|} {FreeRADIUS-Total-Acct-Invalid-Requests|freeradius.Total.Acct.Invalid-Requests|} {FreeRADIUS-Total-Acct-Dropped-Requests|freeradius.Total.Acct.Dropped-Requests|} {FreeRADIUS-Total-Acct-Unknown-Types|freeradius.Total.Acct.Unknown-Types|}]

set output_string [exec echo "Message-Authenticator = 0x00, FreeRADIUS-Statistics-Type = ${stat_type}, Response-Packet-Type = Access-Accept" | radclient -x ${server}:${port} -r 1 status ${server_passwd}]
set output_lines [split $output_string "\n"]

foreach line $output_lines {
  # trim leading ws
  set line [string trimleft $line]

  for {set i 0} {$i < [llength $lookup_list]} {incr i} {
    set param [lindex $lookup_list $i]
    set param_list [split $param {|}]
    set param_desc [lindex $param_list 0]

    if {[string first $param_desc $line] != -1} {
      set line_list [split $line { }]
      set result [lindex $line_list 2]

      lset lookup_list $i "${param}${result}"
    }
  }
}

# output all the parameters from the list
foreach param $lookup_list {
  set param_list [split $param {|}]
  set param_name [lindex $param_list 1]
  set param_value [lindex $param_list 2]

  if {$param_value == ""} {
    set param_value 0
  }

  puts "${param_name}=${param_value}"
}

exit 0
