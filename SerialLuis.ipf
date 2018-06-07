#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Menu "Puerto Serie"
	"InicializarPuertoSerie/0",/Q, init_SPort()
End

Function init_SPort()
	
	if (ItemsinList (WinList("SerialPanel", ";", "")) > 0)
		SetDrawLayer /W=SerialPanel Progfront
		DoWindow /F SerialPanel
		print "Brought to the front"
		return 0
	endif
	//	DoIExist()
	SetDataFolder root:
	//VFamos a tener que cambiar todo esto de los path
	NewDataFolder /O/S MagicBox
	string/G Device = "MagicBox"
	//IF ERROR/ALERT: comment aux and com, discoment COM and select the com manually (i.e. "COM1")	
	string aux = getSerialPort()	
	string/G com = cleanedPort(aux)
	//string/G COM = "COM1"
	string /G name = " "
	init_OpenSerial (com, Device)	//Function engaged 
	Serial_Panel()	//Plot the Panel
	SetDataFolder root:
End


Function/S cleanedPort(aux)
//This is becouse the getSerialPort() introduce the ; and some extra ports normally
	string aux
	string chaincom = ""
	variable i
	for (i=0; i<8; i+=1)
		string a = stringfromlist(i, aux)
		chaincom += a
		if (i == 7 && strlen(chaincom)<5)
			return chaincom
		elseif ( i == 7 && strlen(chaincom)>5 )
			string smsg="Problem openning SERIAL port.\r"
			smsg += " These ports are open: " + chaincom + "\r"
			smsg += " To solve this you have to change the function init_SPort ().\r"
			smsg += " Follow the instructions in the function.  \r\r"
			smsg += " You have to comment aux y com and discomment COM\r"
			DoAlert /T="Unable to open Serial Port" 0, smsg	
			smsg = " Select the com Manually. The VDT.xop is not as good as we would want\r"
			smsg += " There is no several problems, IGOR just thinks that there are more than \r"
			smsg += " one device connected at the same time to his COMports, so it gets blocked\r"
			smsg+= " Select the port manually "
			Abort smsg
		endif
	endfor
end

Function init_OpenSerial (com, Device)

	string com, Device
	string cmd, DeviceCommands
	//string reply
	variable flag
	string/G sports=getSerialPort()
		//print sports
	if(StringMatch(Device,"MagicBox"))	//It looks for the Word in the DeviceStr
		DeviceCommands=" baud=1200, stopbits=1, databits=8, parity=0"
	elseif (StringMatch(Device, "LedController"))
		DeviceCommands=" baud=9600, stopbits=1, databits=8, parity=0"
	endif
		// is the port available in the computer?
	if (WhichListItem(com,sports)!=-1)
		cmd = "VDT2 /P=" + com + DeviceCommands
		Execute cmd
		cmd = "VDTOperationsPort2 " + com
		Execute cmd
		cmd = "VDTOpenPort2 " + com
		Execute cmd
		flag = 1
	else
		//Error Message with an OK button
		string smsg="Problem openning port:" +com+". Try the following:\r"
		smsg+="0.- TURN IT ON!\r"
		smsg+="1.- Verify is not being used by another program\r"
		smsg+="2.- Verify the PORT is available in Device Manager (Ports COM). If not, rigth-click and scan hardware changes or disable and enable it.\r"
		DoAlert /T="Unable to open Serial Port" 0, smsg
		Abort "Execution aborted.... Restart IGOR"
	endif
	return flag 
end

//Different from getSerialPorts() (PROCEDURE serialcom.ipf)
Function /S getSerialPort()

	VDTGetPortList2
	string ports = S_VDT
	if (strlen(ports) == 0 )	//Checking we got every available port
		Abort "ERROR getSerialPorts(). No COM Available"		
	endif
	//We dont use an aux variable, not necessary
	return ports
end

Function checkMagicBoxInit()
	
	SetDataFolder root:MagicBox:
	svar com
	svar Device
	svar name
	
	string cmd = ""
	
	string command = name
	command = upperstr(command)	
	command = trimstring (command)
	name = command
	variable i
	variable longitud = strlen (command)
	//Opening Serial Port -> Optional, not really needed. Ensure Port's working well
	cmd = "VDTOpenPort2 " + com
	Execute cmd
	for (i = 0; i<longitud; i+=1)
		VDTWrite2 command[i]
		dalay (5)		//Delay dont really needed, but the PIC and serialport gets a better syncronization
		//I dont know why i need to close the serial-port to ensure the character is sent
		cmd = "VDTClosePort2 " + com
		Execute cmd 
		if (V_VDT != 1)
			string str = "Reestart the device and the program"
			DoAlert /T="Unable to write in serial port", 0, str
			Abort  "Execution aborted.... Restart IGOR"
		endif
	endfor
	
	
//Wonderful String : abzcdzefzghzijzklzmnzopzazbzczdzezfzgzhzizjzkzlzmznzozpzaeimzbfjn
//Wonderful string v2.0 : bczdczhjzgabpghjghzialo
//The commented things are good. Trying shit things of vdtgetstatus
//VDTGetStatus2 0,1,1
//	print V_VDT
end

Function dalay(ms)
	Variable ms
 	Variable delay = ms*1000
 	Variable start = StopMSTimer(-2)
	do //wait
	while(StopMSTimer(-2) - start < delay)
end

Function ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			strswitch (ba.ctrlName)// click code here
				case "button0":
					CheckMagicBoxInit()
					break
				case "button1":
					Exit()
					break					
			endswitch
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function Serial_Panel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(549,144,849,344) /N=SerialPanel as "CommandPanel"
	Button button0,pos={94.00,118.00},size={81.00,43.00},proc=ButtonProc,title="Send"
	Button button1,pos={246.00,176.00},size={50.00,20.00},proc=ButtonProc, title="Exit"
	SetVariable setvar0,pos={53.00,54.00},size={158.00,18.00},title="Command"
	SetVariable setvar0, value = root:MagicBox:name
	TitleBox title0,pos={226.00,10.00},size={64.00,22.00}, variable = root:MagicBox:sports
End

//Not needed. We can do DoWindow/F and bring to the front the existing panel 
//Instead of killing it 
//Function DoIExist()
//	if (WinType("SerialPanel") == 7)
//		killwindow SerialPanel
//		print "Killed CommandPanel"
//	endif
//end

Function Exit ()
	
	SetDataFolder root:MagicBox:
	svar com
	string cmd
	cmd = "VDTClosePort2 " + com
	Execute cmd
	killwindow SerialPanel
	SetDataFolder root:
end

Window SerialPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(549,144,849,344) as "CommandPanel"
	ShowTools/A
	Button button0,pos={94.00,118.00},size={81.00,43.00},proc=ButtonProc,title="Send"
	Button button1,pos={246.00,176.00},size={50.00,20.00},proc=ButtonProc,title="Exit"
	SetVariable setvar0,pos={53.00,54.00},size={158.00,18.00},title="Command"
	SetVariable setvar0,value= name
	
EndMacro
