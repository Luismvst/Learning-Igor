#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Menu "Puerto Serie"
	"InicializarPuertoSerie/0",/Q, init_SPort()
End

Function init_SPort()
	
	if (ItemsinList (WinList("SerialPanel", ";", "")) > 0)
		SetDrawLayer /W=SerialPanel Progfront
		DoWindow /F SerialPanel
		return 0
	endif
	DFRef saveDFR=GetDataFolderDFR()
	string path = "root:SerialLuis"
	if(!DatafolderExists(path))
		genDFolders(path)
		string/G root:SerialLuis:com 
		string/G root:SerialLuis:Device
		string/G root:SerialLuis:Name
	endif
	//IF ERROR/ALERT: comment aux and com, discoment COM and select the com manually (i.e. "COM1")	
	string aux = getSerialPort()	
	string com = cleanedPort(aux)
	print com
	Serial_Panel()	//Plot the Panel
End

Function/S cleanedPort(aux)
//This is becouse the getSerialPort() introduce some extra ports normally. Trying to avoid that.
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

//It crashes with LedsController function. Uncomment when needed
//Function init_OpenSerial (com, Device)
//
//	string com, Device
//	string cmd, DeviceCommands
//	//string reply
//	variable flag
//	string/G sports=getSerialPort()
//		//print sports
//	if(StringMatch(Device,"MagicBox"))	//It looks for the Word in the DeviceStr
//		DeviceCommands=" baud=1200, stopbits=1, databits=8, parity=0"
//	elseif (StringMatch(Device, "LedController"))
//		DeviceCommands=" baud=9600, stopbits=1, databits=8, parity=0"
//	endif
//		// is the port available in the computer?
//	if (WhichListItem(com,sports)!=-1)
//		cmd = "VDT2 /P=" + com + DeviceCommands
//		Execute cmd
//		cmd = "VDTOperationsPort2 " + com
//		Execute cmd
//		cmd = "VDTOpenPort2 " + com
//		Execute cmd
//		flag = 1
//	else
//		//Error Message with an OK button
//		string smsg="Problem openning port:" +com+". Try the following:\r"
//		smsg+="0.- TURN IT ON!\r"
//		smsg+="1.- Verify is not being used by another program\r"
//		smsg+="2.- Verify the PORT is available in Device Manager (Ports COM). If not, rigth-click and scan hardware changes or disable and enable it.\r"
//		DoAlert /T="Unable to open Serial Port" 0, smsg
//		Abort "Execution aborted.... Restart IGOR"
//	endif
//	return flag 
//end

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

Function Send()
	
	SetDataFolder root:SerialLuis:
	svar com
	svar Device
	svar name
	string cmd = ""
	
	string command = name
	//Future checkboxes to this 
	command = upperstr(command)	
	//command = trimstring (command) //White space are eliminated 
	name = command
	//Opening Serial Port -> Optional, not really needed. Ensure Port's working well
	//VDTOpenPort2 com
	cmd = "VDTOpenPort2 " + com
	Execute cmd
	VDTWrite2 name
	cmd = "VDTWrite2 " + name
	//Execute cmd
	//VDTClosePort2 com
	cmd = "VDTClosePort2 " + com
	//Execute cmd 
//	if (V_VDT != 1)
//		string str = "Reestart the device and the program"
//		DoAlert /T="Unable to write in serial port", 0, str
//		Abort  "Execution aborted.... Restart IGOR"
//	endif
end

//The same as delay but we dont want the function crashes
Function dalay(ms)
	Variable ms
 	Variable delay = ms*1000
 	Variable start = StopMSTimer(-2)
	do //wait
	while(StopMSTimer(-2) - start < delay)
end

Function Exit_SerialLuis ()
	svar com = root:SerialLuis:com
	string cmd
	cmd = "VDTClosePort2 " + com
	Execute cmd
	killwindow SerialPanel
end

Function SetVarProc_SerialLuis(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	if (sva.eventCode == 7 )
		return 0
	endif
	switch( sva.eventCode )
	//EventCode 7 -> Pinchar
		case 1: // mouse up
		case 2: // Enter key
			Send()
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function PopMenuProc_SerialLuis(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			strswitch (pa.ctrlname)				
				case "popup0":
					svar Device = root:SerialLuis:Device							
					Device = popStr				
				break
				case "popup1":
					svar com = root:SerialLuis:com
					com = "COM" + num2str(popNum)	
					if ( stringmatch ( com, "USB*") )
						string smsg = "USB will be implemented soon.\n"
						DoAlert /T="Unable to open the program" 1, smsg
					endif
				break
			endswitch
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonProc_SerialLuis(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			strswitch (ba.ctrlName)// click code here
				case "button0":
					Send()
				break
				case "button1":
					Exit_SerialLuis()
				break	
				case "button2":
					svar com = root:SerialLuis:com
					svar Device = root:SerialLuis:Device
					init_OpenSerial(	com, Device)
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
	NewPanel /W=(928,56,1228,192) as "Hyper-Terminal"
	DoWindow /C SerialPanel
	Button button0,pos={228.00,102.00},size={62.00,26.00},proc=ButtonProc_SerialLuis,title="Send"
	Button button0,help={"Press Enter to Send"},fColor=(52428,52425,1)
	Button button1,pos={6.00,112.00},size={50.00,20.00},proc=ButtonProc_SerialLuis,title="Exit"
	Button button1,fColor=(26411,1,52428)
	Button button2,pos={242.00,21.00},size={51.00,20.00},proc=ButtonProc_SerialLuis,title="Init"
	Button button2,fColor=(65535,0,0)
	SetVariable setvar0,pos={14.00,59.00},size={269.00,18.00},proc=SetVarProc_SerialLuis,title="Command"
	SetVariable setvar0,value= root:SerialLuis:name
	PopupMenu popup0,pos={12.00,21.00},size={132.00,19.00},proc=PopMenuProc_SerialLuis,title="Device"
	PopupMenu popup0,mode=1,popvalue="LedController",value= #"\"LedController;MagicBox\""
	PopupMenu popup1,pos={152.00,21.00},size={81.00,19.00},proc=PopMenuProc_SerialLuis,title="Port"
	PopupMenu popup1,mode=1,popvalue="COM1",value= #"\"COM1;COM2;COM3;COM4;COM5;COM6;COM7;COM8;USB\""
End


