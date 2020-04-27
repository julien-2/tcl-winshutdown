package require Tk

# --------------------------------------------------
# global variable(s)
# --------------------------------------------------
set ::hour 0
set ::min  0
set ::sec  0
set ::timeleft 0
set ::couterid ""
set horloge "00:00:00"

# --------------------------------------------------
# Graphics
# --------------------------------------------------

wm title . "Eteindre Windows"
grid [ttk::frame .c -padding "3 3 12 12"] -column 0 -row 0 
grid columnconfigure . 0 -weight 1; grid rowconfigure . 0 -weight 1

grid [ttk::label .c.texthour -text "hour"] -column 1 -row 1 
grid [ttk::label .c.textmin  -text "min"]  -column 2 -row 1 
grid [ttk::label .c.textsec  -text "sec"]  -column 3 -row 1 

grid [ttk::entry .c.hour -width 7 -textvariable hour] -column 1 -row 2 
grid [ttk::entry .c.min  -width 7 -textvariable min]  -column 2 -row 2 
grid [ttk::entry .c.sec  -width 7 -textvariable sec]  -column 3 -row 2 

grid [ttk::label  .c.countdown  -textvariable horloge] -column 2 -row 3 
grid [ttk::button .c.start      -text "Start" -command shutWin] -column 3 -row 3 
grid [ttk::button .c.cancel     -text "Cancel" -command cancelShut] -column 1 -row 3 


# --------------------------------------------------
# Procedure
# --------------------------------------------------

foreach w [winfo children .c] {
	grid configure $w -padx 10 -pady 10
}
focus .c.min
bind . <Return> {shutWin}

proc convertInputIn_ms {} {
	
	set time_ms [expr $::hour*3600e3+$::min*60e3+$::sec*1.0e3]
	
	return [expr int($time_ms)]
}
proc winShutCommand {} {
	
	return [exec $::env(windir)\\System32\\shutdown /t 0 /s]
}
proc cancelShut {} {

	after cancel winShutCommand
	#puts "$::couterid"
	after cancel $::couterid
	set ::timeleft 0
	set ::horloge "00:00:00"
}
proc setHorloge {time} {
	
	set _hour     [expr $time/3600]
	set _min      [expr ($time%3600)/60]
	set _sec      [expr $time%60]
	
	set ::horloge [format "%02d:%02d:%02d" ${_hour} ${_min} ${_sec}]
}
proc shutWin {} {  
   
	after [convertInputIn_ms] winShutCommand
	puts "Countdown Start"   
	
	counter [expr [clock seconds]+[convertInputIn_ms]/1000] 
}
proc counter {final_time } {
	
	set ::timeleft [expr $final_time-[clock seconds]]
	
	if {$::timeleft > 0} {
	
		puts "$::timeleft"
		setHorloge $::timeleft
		set ::couterid [after 1000 counter $final_time]
	}
}
