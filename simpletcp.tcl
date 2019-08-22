#Experiment for sending UDP traffic.
# nodes are connected as n1-->n2

# Procedures used in the code.
proc finish { } {
    global ns nf tf file_namtr
    $ns flush-trace
    close $nf
    close $tf
    exit 0
}

set file_namtr "simpletcp.nam"
set file_pkttr "simpletcp.tr"

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
$n1 color "red"
$n2 color "blue"
$n1 label "sender"
$n2 label "receiver"

$ns duplex-link $n1 $n2 1Mb 100ms DropTail
$ns queue-limit $n1 $n2 10

# define node, and links colors for graph animation
$ns color 1 "green"

Agent/TCP set packetSize_ 1460
Agent/TCP set window_ 20

# Generate UDP traffic
set tcps [new Agent/TCP]
set tcpr [new Agent/TCPSink]
$ns attach-agent $n1 $tcps
$ns attach-agent $n2 $tcpr
$ns connect $tcps $tcpr
$tcps set fid_ 1

set ftp [new Application/FTP]
$ftp attach-agent $tcps
$ftp set type_ FTP

set tcptrf [open tcpcong.tr w]
$tcps attach $tcptrf
$tcps trace cwnd_
$tcps trace dupacks_

#Schedule events for FTP agents
$ns at 0.0 "$ftp start"
$ns at 2.0 "$ftp stop"


$ns at 2.1 "finish"
$ns run
#----------------------
