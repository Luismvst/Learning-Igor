#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <FilterDialog> menus=0
#include "gpibcom"
<<<<<<< HEAD
=======
//#include "mainIIIV_v3.1c"
>>>>>>> Mult2000Faster

Menu "Multi2000"
	"Initialize", Init_Multi2000()
	"Clear", Close_Multi2000()
	"Panel/ç",/Q, Mult2000Panel ()
	End
	
End

//STATS - 5 voltage measurements -> algoritmo de sleepy ideado para gestionar estos tiempos 
//con nplc = 0.01, 	tarda 1.20 	segundos en realizar la medida
//con nplc = 0.1, 	tarda 1.22	segundos en realizar la medida
//con nplc = 1, 		tarda 1.2 	segundos en realizar la medida
//con nplc = 5, 		tarda 7 		segundos en realizar la medida
//con nplc = 10, 	tarda 12 		segundos en realizar la medida

//STATS - 1 voltage measurement -> the best way to take a fast measure
//con nplc = 0.01,	tarda 0.20 	segundos en realizar la medida
//con nplc = 0.1, 	tarda 0.16 	segundos en realizar la medida
//con nplc = 1, 		tarda 0.08 	segundos en realizar la medida
//con nplc = 2,		tarda 0.18 	segundos en realizar la medida
//con nplc = 3, 		tarda 0.24 	segundos en realizar la medida
//NPLC CAN NOT BE MORE THAN 3 IN FASTER MODE. (NPLC<=3) IT WONT BE A FAST MEASUREMENT, AND THERE WILL BE ERRORS BECOUSE IT IS TOO SLOW. 
//USE NORMAL MEASURING IF YOU WANT TO USE NPLC > 3
//Values given by Medir() are on S.I. ( International System of units )

//It take the same time to measure voltage, resistance and current

//To simplify
Function Medir ()
	variable v = 1	//mode
	variable n = 3	//nplc
	variable q = 1	//num
	if (q == 1 && n<=3)
		return Faster(v, n)
	else
		return Measure_MultiK2000(mode=v, num=q, nplc=n)
	endif
end

//Instructions to use Faster() and PrepareFaster()

//Prepare Faster(mode, nplc) 	is used to specify the INITIAL MODE (before measuring, once is enough), or if there has been CHANGES in NPLC. 
//	If we want Faster() Function to be fast, the mode and nplc should have the same values among the different measurments
// If you want to change this values, use PrepareFaster() before Faster() to give the multimeter the time to change its configuration,
// and then use Faster() to take the measurements.

//Faster(nplc) is to MEASURE faster than Measure_Multi2000 ([ ... ])
// If you are using always the same characteristics ( same nplc and faster() ) , you don't have to use Preparefaster().
// Faster() already works, but the first iteration he has to change the mode and nplc for example, so the first measure
// will be a bit slow  compared to the rest


Function Measure_MultiK2000( [mode, num, nplc, range, triggertime, saved] )  

	variable mode, num, nplc, range, triggertime, saved
	//Cambiar el tip return de la fncion principal, ivan lo que quiere es medir y que enseguida se le devuelva la medida
	//Idea: realizar un panel guai que lo entienda hasta mi abuela
		
	//mode 			- Type of measuring: 1 - voltage, 2 - current, 3 - resistance
	//num				- Number of Measure points Keithley will measure. IT has to be ">=2"
	//nplc				- NPLCycles
	//range 			- Range ( normally in auto ) 	
	//triggertime 	- Time between each measure ( trigger timer )	
	//saved			- Saves the data measured in different columns of a 2D wave, one column per measure. 1 - Save
	//databack		- /*NOT IMPLEMENTED*/ Boolean value indicating to return all de values measured
	
	//return 			- Return the averege value of the different measurings
	
	//Timer -> It shows us the duration each measure takes keithley to be done
	//variable start = stopmstimer (-2)
	
	//Default parameters
	if (paramisdefault(mode))
		mode = 1
	endif
	if (paramisdefault(num))
		num = 5	
	endif
	if (paramisdefault(nplc))
		nplc = 1
	endif
	if (paramisdefault(range))
		range = 0
	endif
	if (paramisdefault(triggertime))
		triggertime = 0.01
	endif
	if (paramisdefault(saved))
		saved = 0						//	0 - Do not save the measurings into data wave 
	endif
	
	DFRef saveDFR=GetDataFolderDFR()	
	string path = "root:DeviceControl:Mult2000:Measure"
	DFRef dfr = $path
	SetDatafolder dfr
	
	
	string type
	if (mode==1)
		type = "volt"
	elseif (mode==2)
		type = "curr"
	elseif (mode==3)
		type = "res"
	endif
		
	code1(type, num, nplc, range)
	
	//We have to wait for a short time to let Keithley run the code and measure before asking him again
	variable sleepy 
	//This algorithm could be better implemented for the different measurings, but this is faster enough.
	//The way to improve the measurings with more speed is to chronometer the time manually the keithley is  
	//taking measures, and when SRQ appears on the screen, it is the time igor requires to be waiting to ask him 
	
	if ( nplc > 1 )
		sleepy = nplc*num
		if(num>10)
			sleepy = 1.5 + nplc*num/10
		else
			sleepy = 1.5 + nplc*num/5		
		endif
	else
		sleepy = 0.5 + 0.05*num
	endif
	
	//We wait until the commands has been executed, and we are having an answer from keithley	
	Sleep/S sleepy	//VERY IMPORTANT	
	
	//If THIS Sleep is not bigger enough, the multimeter probably will not probably have enough time to take all the 
	//measurings and it won't be good. "SRQ" instruction will be shown on keitley's screen if sleepy problem occurs
	
	//After sending the commands, we ask some questions and the values back.
	//Asking returns the average value of them
	
	
	variable average_1 = Asking()
	
	if (saved)
		wave buffer 
		Save_Data(buffer)
		variable /G root:DeviceControl:Mult2000:average = average_1
	endif
	
	return average_1
	
	SetDataFolder saveDFR
	
end

Function Asking()

	variable points 
	variable first = 1
	
	do
		Send(":stat:meas?;")					//Wait for SRQ == 0
		
		if (first)													
			sleep/S 0.1
			first = 0
		else
			sleep/S 0.05
		endif
		
	while (Listen_Variable() != 0 )	//When register bit SRQ == 0, the multimeter has finished his homeworks	

	Send (":TRACe:points?;")									//How many points has the multimeter measured
	sleep/S 0.05
	points = Listen_Variable()
	make /D/O/N=(points) buffer

	Send (":data:data?;")										//Ask for data 
	
	Read_Data(points, buffer)									//Read the buffer 
	
	//Print_Data(points, buffer)
	
	WaveStats/M=2/Q	buffer		// M=2 is for V_sdev and V_avg
	variable media = V_avg
	variable desv_tipica = V_sdev
	
	return media
	
end

//Reads the data from te buffer. It requiers the number of points needed to be read
Function Read_Data (points, buffer)
	variable points
	wave buffer 
	variable i
	for (i = 0; i<points; i+=1)
		buffer[i] = Listen_Variable()
	endfor
end

Function Print_Data(points, buffer)
	variable points
	wave buffer
	printf "Let's print %d data: \r", points
	variable i
	for  (i = 0; i<points; i+=1)
		if ( mod (i, 10) == 0 )	//for each 10 points printed, we change line on history command line
			print " "
		endif
		printf "%.8f     ", buffer[i]	
	endfor	
End

Function code1 (type, num, nplc, range)
	
	//This code do not use the trigger. If the value of nplcycle is '1', it measures with the net period (50Hz).
	//Range is auto if commented
	string type
	variable num, nplc, range
	
	Send ("*rst")														
	Send (":status:preset;")												
	Send ("*cls")														
	Send (":stat:meas:enab 512;")											
	Send ("*sre 1")															
	Send (":sens:func '" + type + "';")									
	//Send (":sens:" + type + ":rang " + num2str(range) + ";")	 	//If commented: Auto Range
	Send (":sens:" + type + ":nplc " + num2str(nplc) + ";") 	
	Send (":trig:count " + num2str(num) + ";")
	Send (":trac:cle; poin " + num2str(num) + "; feed sens1;")
	Send (":trac:feed:control next;")								
	Send (":init")														

end

//Function code2 (type)
//	
//	//This code use the trigger. It is triggered with a timer between each measure
//	string type 
//	//Panel is not implemented with this code. It has to be done by commands
//	
//	Send ("*rst")															//Send a reset
//	Send (":status:preset;")												//Clear status bit
//	Send ("*cls")															//Send a clear
//	Send (":stat:meas:enab 512;")											//Enable measurement complete status bit
//	Send ("*sre 1")															//Generate SRQ on measurement complete (MSB)
//	Send (":sens:func '" + type + "';")									//Set func to read  
//	//Send (":sens:" + type + ":rang " + num2str(range) + ";")		//Set  range - if commented : auto-range by defect
//	Send (":trac:cle; feed sens; points " + num2str(num) + ";")	//Clear the buffer, Read w/o calculation, Set buffer length according to the number of points
//	Send (":trig:count " + num2str(num) + "; sour timer; timer " + num2str(triggertime) + ";")		//Set trigger to the numb of points, Sourced to timer with its sec interval
//	Send (":trac:feed:control next;")									//Fill up the buffer on trigger
//	Send (":init")															//Initiates the measurements
//
//	//Range: 0.1 V, 1 V, 10 V, 100 V, 1000 V
//	//NPLCypcles: 0.01 to 10. 
//	//range is readjusted if you asks for a grater scale, to the auto scale needed. for lower scales there is overflow.
//	
//end
//

//Not implemented yet. Coming soon
Function Save_Data (buffer)

	//This saves the buffer into data wave. You can change the wave's name 
	wave buffer
	DFRef saveDFR=GetDataFolderDFR()	
	string path = "root:DeviceControl:Mult2000:"
	DFRef dfr = $path
	SetDatafolder dfr
	svar /Z name = :Measure:dname
	
	variable points=DimSize(buffer,0)
	make /d/n=(points) $name
	wave datos = $name 
	datos = buffer	
		
	SetDataFolder saveDFR
end

Function Send (a)
	string a
	nvar ID = root:DeviceControl:Mult2000:MultID
	GPIB2 device = ID
	GPIBWrite2 a	
end

Function/S Listen_String ()
	string b
	nvar ID = root:DeviceControl:Mult2000:MultID
	GPIB2 device = ID
	GPIBRead2 b
	print b
	return b
end

//Function to simplify writing on command Windo. It also prints the solution
function ls ()
	variable a= listen_variable()
	print a
end

Function Listen_Variable () 
	variable b
	nvar ID = root:DeviceControl:Mult2000:MultID
	GPIB2 device = ID
	GPIBRead2 b
	return b
end

Function Close_Multi2000()
	//KillIo initialize the GPIB and send an interface clear
	nvar MultID = root:DeviceControl:Mult2000:MultID
	GPIB2 device = MultID
	GPIBWrite2 ":TRACe:CLEar;"
	GPIB2 KillIO
end

Function Init_Multi2000()

	DFRef saveDFR=GetDataFolderDFR()	//Instead of a string, a DatafolderReference is better for this type of use
	string path = "root:DeviceControl:Mult2000:"
	if (!DataFolderExists(path))
		genDFolders (path)
		genDFolders ("root:DeviceControl:Mult2000:LastData")
		genDFolders ("root:DeviceControl:Mult2000:Measure")
	endif
	DFRef dfr = $path
	
	SetDatafolder dfr
	
	InitBoard_GPIB(0)
	
	Variable /G MultID = InitDevice_GPIB (0, 16) // boarn is 0 in most cases and address 26 for K2600, 16 for K2000 -> Manual
	if (MultID == 0)		//If the ID assigned by the gpib for our K2000 randomly is equal to 0, then exit()
		print "UNKNOWN DEVICE DETECTED. ABORT"
		return 0
	endif
	
	string  Mult2000Info
	string  eol = "\r\n"		//End of line. 
	
	GPIB2 device = MultID
	
	GPIBWrite2 "*WAI;"	//Pay atention to the orders that will be sent after this
		
	//IDN establece el modo remote enable y enciende a un talker y un listener 
	//Abort commit a talker idle state
	GPIBWrite2 "*IDN?" + eol	//I dont use ';', i want to write Mult2000Info in the same line. The other is valid too but it changes the line
	Sleep/S 0.1
	GPIBRead2 /T=eol Mult2000Info
	variable flag
	if(!StringMatch(Mult2000Info,""))
		flag =1
		print Mult2000Info + "HAS BEEN INITIALIZED"

	else 
		flag = 0
		print "ERROR. MULTIMETER COULD NOT BE INITIALIZED"
	endif
	
	SetDataFolder saveDFR
	return flag
end

//This function enables or disables the annoying error bip ( or any sound ) keitley could have
Function Sound_Beep()
	string disable = ":syst:beep 0;"
	string enable = ":syst:beep 1;"
	string ask = ":syst:beep:stat?;"
	Send(ask)
	if( str2num (Listen_String()))
		Send (disable)
		return 0
	else
		Send (enable)
		return 1
	endif		
end

Function/S Queue ()
	//Prints the error queue. Try the function twice if it doesn't work initially.
	string a
	Send (":stat:que:enab?")	//This enables the printing of the error queue if we read some of it
	a = Listen_String()
	//Send (":stat:que:enab ()")	//This closes the printing of the error queue 
	return a
end

//This function works when keithley has been blocked by the register bit of srq. This unlocks the "srq state".
Function srq ()
	send (":stat:meas?")
	//listen_variable()
end


Function Mult2000Panel ()
	//Initialize data
	DFRef saveDFR=GetDataFolderDFR()
	string path = "root:DeviceControl:Mult2000:Measure"
	if(!DatafolderExists(path))
		genDFolders (path)
	endif
	DFRef dfr = $path
	SetDatafolder dfr
	
	if (ItemsinList (WinList("Panel_Keithley2000", ";", "")) > 0)
		SetDrawLayer /W=Panel_Keithley2000 Progfront
		DoWindow /F Panel_Keithley2000	 // Bring the panel to the front
		return 0
	endif
	
	variable/G mode, num, nplc, range, triggertime, saved, fast
	mode = 1; num = 5; nplc = 1; range = 0; triggertime = 0.01; saved= 0; fast = 0;
	string/G dname = "SavedWave"
	
	string cmd = "Panel_Keithley2000()"
	Execute cmd 
	
	SetDatafolder saveDFR
	
end


Window Panel_Keithley2000() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(865,118,1119,339)
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1
	DrawText 13,32,"Multimeter Keithley 2000"
	PopupMenu popupmode,pos={17.00,42.00},size={110.00,19.00},proc=PopMenuProc_Mult2000,title="Measure"
	PopupMenu popupmode,mode=1,popvalue="Voltage",value= #"\"Voltage;Current;Resistance\""
	SetVariable setvarnum,pos={17.00,67.00},size={154.00,18.00},proc=SetVarProc_Mult2000,title="Nº of measurements\\f01"
	SetVariable setvarnum,limits={1,128,1},value= root:DeviceControl:Mult2000:Measure:num
	SetVariable setvarnplc,pos={17.00,94.00},size={154.00,18.00},proc=SetVarProc_Mult2000,title="NPLC\\f01"
	SetVariable setvarnplc,limits={0.01,10,1},value= root:DeviceControl:Mult2000:Measure:nplc
	SetVariable setvarName,pos={17.00,122.00},size={217.00,18.00},disable=2,title="\\f01Saved Wave Name"
	SetVariable setvarName,value= root:DeviceControl:Mult2000:Measure:dname
	CheckBox checksave,pos={128.00,150.00},size={69.00,15.00},proc=CheckProc_Mult2000,title="Save Data "
	CheckBox checksave,variable= root:DeviceControl:Mult2000:Measure:saved
	CheckBox checkfast,pos={153.00,45.00},size={98.00,15.00},proc=CheckProc_Mult2000,title="Fast Measuring "
	CheckBox checkfast,variable= root:DeviceControl:Mult2000:Measure:fast
	Button buttonMeas,pos={59.00,177.00},size={134.00,35.00},proc=ButtonProc_Mult2000,title="Measure"
	Button buttonMeas,fSize=16,fColor=(1,16019,65535)
	Button buttoninit,pos={10.00,147.00},size={90.00,20.00},proc=ButtonProc_Mult2000,title="Initialize"
	Button buttoninit,fSize=12,fColor=(65535,49157,16385)
EndMacro


Function ButtonProc_Mult2000(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			strswitch (ba.ctrlname)
				case "buttonMeas":
					nvar /z mode = root:DeviceControl:Mult2000:Measure:mode
					nvar /z num 	= root:DeviceControl:Mult2000:Measure:num
					nvar /z nplc = root:DeviceControl:Mult2000:Measure:nplc
					nvar /z saved = root:DeviceControl:Mult2000:Measure:saved
					nvar /z fast = root:DeviceControl:Mult2000:Measure:fast
					variable start, finish
					if (fast || num == 1)
//						start = stopmstimer (-2)
//						print Faster (mode, nplc)
//						finish = stopmstimer(-2) - start
//						finish = finish/(10^6)
//						printf "Tiempo: %.8f\n\r", finish
					 	return Faster (mode, nplc)
					else
//						start = stopmstimer (-2)
//						print Measure_MultiK2000( mode=mode, num=num, nplc=nplc, saved=saved )
						Measure_MultiK2000( mode=mode, num=num, nplc=nplc, saved=saved )
//						finish = stopmstimer(-2) - start
//						finish = finish/(10^6)
//						printf "Tiempo: %.8f\n\r", finish
					endif
					break
				case "buttoninit":
					Init_Multi2000()
				break
				endswitch
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function PopMenuProc_Mult2000(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			
			strswitch(pa.ctrlname)
				case "popupmode":
					NVAR /Z mode=root:DeviceControl:Mult2000:Measure:mode
					mode=popNum
				break
			endswitch
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function CheckProc_Mult2000(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			
			strswitch(cba.ctrlname)
				case "checksave":
					nvar /z saved = root:DeviceControl:Mult2000:Measure:saved
					saved = cba.checked
					if (saved) 
						SetVariable setvarName, disable = 0
					elseif (saved == 0)
						SetVariable setvarName, disable = 2
					endif
					break
				case "checkfast":
					nvar /z fast = root:DeviceControl:Mult2000:Measure:fast
					nvar /z num = root:DeviceControl:Mult2000:Measure:num
					nvar /z nplc = root:DeviceControl:Mult2000:Measure:nplc
					fast = cba.checked
					if (fast) 
						SetVariable setvarNum, disable = 2
						num = 1
						if (nplc > 3 )
							nplc = 3
						endif
					elseif (fast == 0)
						SetVariable setvarNum, disable = 0
					endif
					break
			endswitch						
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function SetVarProc_Mult2000(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	nvar /z num = root:DeviceControl:Mult2000:Measure:num
	if (num == 1)
	if (sva.eventcode == 1 || sva.eventcode == 2 || sva.eventcode == 3 )
		sva.blockReentry=1
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 8:	//The edit ends for num or nplc
		//Those 3 cases are important, we have the blockreentry to ensure not doing this twice
			nvar /z fast = root:DeviceControl:Mult2000:Measure:fast
			if (fast)
				nvar /z mode = root:DeviceControl:Mult2000:Measure:mode
				nvar /z nplc = root:DeviceControl:Mult2000:Measure:nplc
				PrepareFaster(mode, nplc)
			endif
			//we need to prepare the measurings becouse it is so fast that gives error if we do not do this. 
			break
		case -1: // control being killed
			break
	endswitch
	endif
	endif
End

//MAX NPLC = 3 -> If you do not want errors, the code is faster enough been under a nplc < 3
Function Faster (mode, nplc)
	variable mode, nplc
	string type
	if (mode==1)
		type = "volt"
	elseif (mode==2)
		type = "curr"
	elseif (mode==3)
		type = "res"
	endif			
	
	Send (":sens:func '" + type + "';")	
	Send (":sens:" + type + ":nplc " + num2str(nplc) + ";")	
//	Send(":Read?")	-> Executing read we are doing:  Abort, init and fetch? -> init is not realized and there is an error -213. 
	//we make it easier and faster this way
	Send (":abort;:fetch?")
	//Send (":Measure:" + type + "?") -> Realize Abort:conf<func>:read? -> It takes more time 
	
	return Listen_Variable()
end

//This function is needed becouse the multimeter takes some miliseconds while it changes the measuring mode
Function PrepareFaster (mode, nplc)
	variable mode, nplc
	string type
	if (mode==1)
		type = "volt"
	elseif (mode==2)
		type = "curr"
	elseif (mode==3)
		type = "res"
	endif	
	Send (":sens:func '" + type + "';")	
	Send (":sens:" + type + ":nplc " + num2str(nplc) + ";")	
	delay (1000)	//1 sec to wait for the changed mode, necesary the first time there's a change in nplc or mode
end

//Luis Martínez de Velasco Sánchez-Tembleque