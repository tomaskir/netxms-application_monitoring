#!/usr/bin/tclsh

# set stats file path here if needed
set stat_file_path {/var/cache/bind/named.stats}

set lookup_list [list {IPv4 requests received|bind9.Requests.Received.IPv4|} {IPv6 requests received|bind9.Requests.Received.IPv6|} {recursive queries rejected|bind9.Requests.Recursive.Rejected|} {queries resulted in authoritative answer|bind9.Answers.Auth|} {queries resulted in non authoritative answer|bind9.Answers.NonAuth|} {queries resulted in nxrrset|bind9.Answers.nxrrset|} {queries resulted in SERVFAIL|bind9.Answers.SERVFAIL|} {queries resulted in NXDOMAIN|bind9.Answers.NXDOMAIN|} {queries caused recursion|bind9.Answers.Recursive|} {other query failures|bind9.Requests.Failed.Other|} {IPv4 notifies sent|bind9.Notifies.Sent.IPv4|} {IPv6 notifies sent|bind9.Notifies.Sent.IPv6|} {IPv4 notifies received|bind9.Notifies.Received.IPv4|} {IPv6 notifies received|bind9.Notifies.Received.IPv6|}]

exec rndc stats

# read stat file into variable
set fp [open $stat_file_path r]
set file_data [read $fp]
close $fp

# create line list of the file
set file_lines [split $file_data "\n"]

foreach line $file_lines {
  # trim leading ws
  set line [string trimleft $line]

  for {set i 0} {$i < [llength $lookup_list]} {incr i} {
    set param [lindex $lookup_list $i]
    set param_list [split $param {|}]
    set param_desc [lindex $param_list 0]

    if {[string first $param_desc $line] != -1} {
      set line_list [split $line { }]
      set result [lindex $line_list 0]

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

file delete $stat_file_path

exit 0
