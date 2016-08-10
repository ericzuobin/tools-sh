#!/usr/bin/expect
set timeout 10
set host 172.16.3.81
set name root
set password admin

set domain 172.16.3.
set ip [lindex $argv 0]
set name2 root
set password2 admin

spawn ssh $name@$host
expect {
    "(yes/no)?" {
      send "yes\n"
      expect "assword:" { send "$password\n" }
    }
    "assword:" {
        send "$password\n"
    }
    "*~]*" {
      send "ssh $name2@$domain$ip\n"
        expect {
            "(yes/no)?" {
                send "yes\n"
                expect "assword:" { send "$password2\n" }
            }
            "assword:" {
                send "$password2\n"
           }
           "*~]*" {exp_continue}
      }
   }
}
interact
