lappend auto_path ./ext_libs


# /////////////////////////////////////////////////////////////////////////////
# execPowershellCmd 
# /////////////////////////////////////////////////////////////////////////////
# Code from:
# https://wiki.tcl-lang.org/page/exec
# 	- MHo 2019-01-27


#
# Calls a single Powershell command (blocking, hidden)
# Arg: The command to give to Powershell via -command switch
# Ret: A List of three elements:
#  -1 "" <errtext>       -> error from packa re or create_process (twapi)
#   0 <stdouttxt> ""     -> Ok
#   1 "..." <stderrtext> -> Maybe Ok, something written to stderr
#
proc execPowershellCmd {cmd} {
     set cmd "-command $cmd"
     foreach chan {stdin stdout stderr} {
             lassign [chan pipe] rd$chan wr$chan
     }
     if {[catch {
        package require twapi_process
        set cmd [string map [list \" \\\"] $cmd]
        twapi::create_process [auto_execok powershell] -cmdline $cmd -showwindow hidden \
         -inherithandles 1 -stdchannels [list $rdstdin $wrstdout $wrstderr]
     } ret]} {
        return [list -1 "" $ret]
     }
     chan close $wrstdin; chan close $rdstdin; chan close $wrstdout; chan close $wrstderr
     foreach chan [list $rdstdout $rdstderr] {
             chan configure $chan -encoding cp850 -blocking true; # to be further examined
     }
     set out [read $rdstdout]; set err [read $rdstderr]
     chan close $rdstdout; chan close $rdstderr
     return [list [string compare $err ""] $out $err]
}
# exemple : change screen brightness \
execPowershellCmd "\$monitor = Get-WmiObject -ns root/wmi -class wmiMonitorBrightNessMethods ; \$monitor.WmiSetBrightness(1,1)"