# Defining Node Configuration paramaters

set val(chan)           Channel/WirelessChannel    ;# channel type

set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model

set val(netif)           Phy/WirelessPhy            ;# network interface type

set val(mac)            Mac/802_11                ;# MAC type

set val(ifq)            Queue/DropTail/PriQueue   ;# interface queue type

set val(ll)             LL                         ;# link layer type

set val(ant)            Antenna/OmniAntenna        ;# antenna model

set val(ifqlen)         50                         ;# max packet in ifq

set val(nn)             8                          ;# number of mobilenodes

set val(rp)             DSDV                       ;# routing protocol

set val(x)              500                        ;# X dimension of the topography

set val(y)              500                           ;# Y dimension of the topography

 

# Set the Mac Parameters, for more parameters, refer the ~ns-2.35/lib/ns-default.tcl

Mac/802_11 set RTSThreshold_  3000

Mac/802_11 set basicRate_ 1Mb

Mac/802_11 set dataRate_  2Mb

 

# creation of tracefiles for various metrics

# *** Throughput Trace ***

set f0 [open thru02.tr w]

set f1 [open thru12.tr w]

set f2 [open thru22.tr w]

set f3 [open thru32.tr w]

 

# *** Packet Loss Trace ***

set f4 [open pktloss02.tr w]

set f5 [open pktloss12.tr w]

set f6 [open pktloss22.tr w]

set f7 [open pktloss32.tr w]

 

# *** Packet Delay Trace ***

set f8 [open pktdelay02.tr w]

set f9 [open pktdelay12.tr w]

set f10 [open pktdelay22.tr w]

set f11 [open pktdelay32.tr w]

 

# Simulator Object

set ns              [new Simulator]

 

# Trace file initialization

set tracef     [open wireless3.tr w]

$ns trace-all $tracef

 

# Network Animator

set namf [open wireless3.nam w]

$ns namtrace-all-wireless $namf $val(x) $val(y)

 

# Topography

set topo       [new Topography]

$topo load_flatgrid 500 500

 

#creation of god (General Operations Director) object

create-god $val(nn)

 

# configure nodes

       $ns node-config -adhocRouting $val(rp) \
                         -llType $val(ll) \
                         -macType $val(mac) \
                         -ifqType $val(ifq) \
                         -ifqLen $val(ifqlen) \
                         -antType $val(ant) \
                         -propType $val(prop) \
                         -phyType $val(netif) \
                         -channelType $val(chan) \
                         -topoInstance $topo \
                         -agentTrace ON \
                         -routerTrace ON \
                         -macTrace OFF \
                         -movementTrace OFF                   

# Creation of Nodes

        for {set i 0} {$i < $val(nn) } {incr i} {

                set node_($i) [$ns node]

                $node_($i) random-motion 0            ;# disable random motion

        }

 

 

#initial position of nodes

 

$node_(0) set X_ 5.0

$node_(0) set Y_ 5.0

$node_(0) set Z_ 0.0

 

$node_(1) set X_ 10.0

$node_(1) set Y_ 15.0

$node_(1) set Z_ 0.0

 

$node_(2) set X_ 35.0

$node_(2) set Y_ 250.0

$node_(2) set Z_ 0.0

 

$node_(3) set X_ 10.0

$node_(3) set Y_ 50.0

$node_(3) set Z_ 0.0

 

$node_(4) set X_ 235.0

$node_(4) set Y_ 10.0

$node_(4) set Z_ 0.0

 

$node_(5) set X_ 400.0

$node_(5) set Y_ 100.0

$node_(5) set Z_ 0.0

 

$node_(6) set X_ 285.0

$node_(6) set Y_ 150.0

$node_(6) set Z_ 0.0

 

$node_(7) set X_ 120.0

$node_(7) set Y_ 115.0

$node_(7) set Z_ 0.0

 

# Create traffic flow using UDP with Constant Bit Rate Application

# this includes priority and the sink is LossMonitor agent to trace the bytes received (because the Null Agent does not handle this)

set agent1 [new Agent/UDP]             

$agent1 set prio_ 0                 

set sink [new Agent/LossMonitor] 

$ns attach-agent $node_(0) $agent1

$ns attach-agent $node_(1) $sink

$ns connect $agent1 $sink       

set app1 [new Application/Traffic/CBR]

$app1 set packetSize_ 512            ; # setting the packet size

$app1 set rate_ 600Kb                ; # setting the rate at which the packets are transmitted

$app1 attach-agent $agent1           ; # attaching the agent

 

 

 

set agent2 [new Agent/UDP]           

$agent2 set prio_ 1                  

set sink2 [new Agent/LossMonitor]    

$ns attach-agent $node_(2) $agent2   

$ns attach-agent $node_(3) $sink2    

$ns connect $agent2 $sink2           

set app2 [new Application/Traffic/CBR]

$app2 set packetSize_ 512              

$app2 set rate_ 600Kb                 

$app2 attach-agent $agent2            

 

 

 

set agent3 [new Agent/UDP]            

$agent3 set prio_ 2                  

set sink3 [new Agent/LossMonitor]    

$ns attach-agent $node_(4) $agent3   

$ns attach-agent $node_(5) $sink3    

$ns connect $agent3 $sink3           

set app3 [new Application/Traffic/CBR]

$app3 set packetSize_ 512            

$app3 set rate_ 600Kb                

$app3 attach-agent $agent3

set agent4 [new Agent/UDP]

$agent4 set prio_ 3      

set sink4 [new Agent/LossMonitor]     

$ns attach-agent $node_(6) $agent4    

$ns attach-agent $node_(7) $sink4     

$ns connect $agent4 $sink4            

set app4 [new Application/Traffic/CBR]

$app4 set packetSize_ 512              

$app4 set rate_ 600Kb                 

$app4 attach-agent $agent4            

# defines the node size in Network Animator

for {set i 0} {$i < $val(nn)} {incr i} {

    $ns initial_node_pos $node_($i) 20

}

 

# Initialize Flags

set ht 0

set hs 0

 

set ht1 0

set hs1 0

 

set ht2 0

set hs2 0

 

set ht3 0

set hs3 0

 

set hr1 0

set hr2 0

set hr3 0

set hr4 0

 

# Function To record Statistcis (Bit Rate, Delay, Drop)

proc record {} {

        global sink sink2 sink3 sink4 f0 f1 f2 f3 f4 f5 f6 f7 ht hs ht1 hs1 ht2 hs2 ht3 hs3 f8 f9 f10 f11 hr1 hr2 hr3 hr4

set ns [Simulator instance]

set time 0.9 ;#Set Sampling Time to 0.9 Sec

 

set bw0 [$sink set bytes_]

set bw1 [$sink2 set bytes_]

set bw2 [$sink3 set bytes_]

set bw3 [$sink4 set bytes_]

set bw4 [$sink set nlost_]

set bw5 [$sink2 set nlost_]

set bw6 [$sink3 set nlost_]

set bw7 [$sink4 set nlost_]

 

set bw8 [$sink set lastPktTime_]

set bw9 [$sink set npkts_]

set bw10 [$sink2 set lastPktTime_]

set bw11 [$sink2 set npkts_]

 

set bw12 [$sink3 set lastPktTime_]

set bw13 [$sink3 set npkts_]

set bw14 [$sink4 set lastPktTime_]

set bw15 [$sink4 set npkts_]

 

set now [$ns now]

# Record the Bit Rate in Trace Files

puts $f0 "$now [expr (($bw0+$hr1)*8)/(2*$time*1000000)]"

puts $f1 "$now [expr (($bw1+$hr2)*8)/(2*$time*1000000)]"

puts $f2 "$now [expr (($bw2+$hr3)*8)/(2*$time*1000000)]"

puts $f3 "$now [expr (($bw3+$hr4)*8)/(2*$time*1000000)]"

 

# Record Packet Loss Rate in File

puts $f4 "$now [expr $bw4/$time]"

puts $f5 "$now [expr $bw5/$time]"

puts $f6 "$now [expr $bw6/$time]"

puts $f7 "$now [expr $bw7/$time]"

 

# Record Packet Delay in File

if { $bw9 > $hs } {

      puts $f8 "$now [expr ($bw8 - $ht)/($bw9 - $hs)]"

      } else {

                puts $f8 "$now [expr ($bw9 - $hs)]"

        }

        if { $bw11 > $hs1 } {

                puts $f9 "$now [expr ($bw10 - $ht1)/($bw11 - $hs1)]"

        } else {

                puts $f9 "$now [expr ($bw11 - $hs1)]"

        }

 

        if { $bw13 > $hs2 } {

                puts $f10 "$now [expr ($bw12 - $ht2)/($bw13 - $hs2)]"

        } else {

                puts $f10 "$now [expr ($bw13 - $hs2)]"

        }

 

        if { $bw15 > $hs3 } {

                puts $f11 "$now [expr ($bw14 - $ht3)/($bw15 - $hs3)]"

        } else {

                puts $f11 "$now [expr ($bw15 - $hs3)]"

        }

 

        # Reset Variables

        $sink set bytes_ 0

        $sink2 set bytes_ 0

        $sink3 set bytes_ 0

        $sink4 set bytes_ 0

 

        $sink set nlost_ 0

        $sink2 set nlost_ 0

        $sink3 set nlost_ 0

        $sink4 set nlost_ 0

 

        set ht $bw8

        set hs $bw9

        set  hr1 $bw0

        set  hr2 $bw1

        set  hr3 $bw2

        set  hr4 $bw3

    $ns at [expr $now+$time] "record"   ;# Schedule Record after $time interval sec

}

 

# Start Recording at Time 0

$ns at 0.0 "record"

$ns at 1.4 "$app1 start"                 ;# Start transmission at  2 Sec

$ns at 10.0 "$app2 start"               ;# Start transmission at 5 Sec

$ns at 20.0 "$app3 start"               ;# Start transmission at 15 Sec

$ns at 30.0 "$app4 start"               ;# Start transmission at 25 Sec

 

# Stop Simulation at Time 70 sec

$ns at 80.0 "finish"

 

# Reset Nodes at time 80 sec

for {set i 0} {$i < $val(nn) } {incr i} {

    $ns at 80.0 "$node_($i) reset";

}

 

# Exit Simulation at Time 70.01 sec

$ns at 80.01 "puts \"NS EXITING...\" ; $ns halt"

 

proc finish {} {

        global ns tracefd f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11

        # Close Trace Files

        close $f0

        close $f1

        close $f2

        close $f3

        close $f4

        close $f5

        close $f6

        close $f7

        close $f8

        close $f9

        close $f10

        close $f11

        # Plot the characteristics using xgrapg

        exec xgraph/bin/xgraph thru02.tr thru12.tr thru22.tr thru32.tr -geometry 800x400 &

        exec xgraph/bin/xgraph pktloss02.tr pktloss12.tr pktloss22.tr pktloss32.tr -geometry 800x400 &

        exec xgraph/bin/xgraph pktdelay02.tr pktdelay12.tr pktdelay22.tr pktdelay32.tr -geometry 800x400 &

        # Reset Trace File

        $ns flush-trace

        close $tracef

        exit 0

}

puts "Starting Simulation..."

$ns run
