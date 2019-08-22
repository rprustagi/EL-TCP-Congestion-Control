#Experiment for sending UDP traffic.
# nodes are connected as n1<-->32<-->n3

# Procedures used in the code.
proc finish { } {
    global ns nf tf file_namtr
    $ns flush-trace
    close $nf
    close $tf
    exit 0
}

set file_namtr "simpletcp2.nam"
set file_pkttr "simpletcp2.tr"

# create the ns object and trace files
set ns [ new Simulator ]
set nf [ open $file_namtr w ]
$ns namtrace-all $nf
set tf [ open $file_pkttr w ]
$ns trace-all $tf

# create the nodes and links for traffic
set n0 [$ns node]

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
$n1 color "red"
$n3 color "blue"
$n1 label "sender"
$n3 label "receiver"

$ns duplex-link $n1 $n2 10Mb 100ms DropTail
$ns duplex-link $n2 $n3 1Mb 100ms DropTail
$ns duplex-link $n4 $n2 10Mb 100ms DropTail
$ns duplex-link $n2 $n5 1Mb 100ms DropTail
$ns queue-limit $n2 $n3 10
$ns queue-limit $n2 $n5 10

# define node, and links colors for graph animation
$ns color 1 "green"

Agent/TCP set packetSize_ 1460
Agent/TCP set window_ 20

# Generate TCP traffic
set tcps1 [new Agent/TCP]
set tcpr1 [new Agent/TCPSink]
$ns attach-agent $n1 $tcps1
$ns attach-agent $n3 $tcpr1
$ns connect $tcps1 $tcpr1
$tcps1 set fid_ 1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcps1
$ftp1 set type_ FTP

set tcptrf1 [open tcpcong21.tr w]
$tcps1 attach $tcptrf1
$tcps1 trace cwnd_
$tcps1 trace dupacks_

# Generate 2nd TCP traffic
set tcps2 [new Agent/TCP]
set tcpr2 [new Agent/TCPSink]
$ns attach-agent $n4 $tcps2
$ns attach-agent $n5 $tcpr2
$ns connect $tcps2 $tcpr2
$tcps2 set fid_ 2

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcps2
$ftp2 set type_ FTP

set tcptrf2 [open tcpcong22.tr w]
$tcps2 attach $tcptrf2
$tcps2 trace cwnd_
$tcps2 trace dupacks_
#Schedule events for FTP agents
$ns at 0.0 "$ftp1 start"
$ns at 10.0 "$ftp1 stop"

$ns at 2.0 "$ftp2 start"
$ns at 10.0 "$ftp2 stop"

$ns at 10.1 "finish"
$ns run
#----------------------
