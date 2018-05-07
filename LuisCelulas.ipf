#pragma TextEncoding = "Windows-1252"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <InsertSubwindowInGraph>
#include "IV_Lab_v1"
#include "gpibcom"
//#include "Spectroscopic_Lab"
#include "serialcom"

Menu "ProgramaLuis"
	"Modelar Curva I-V/0", StartProcessing()
End

Function StartProcessing()
	
	DoIExist()
	Initialize()	
	//Windowexist, panel exist
	//svar output = root:variph
	//PauseForUser tmp_PauseforPrep
End

Function Initialize ()

	SetDataFolder root:	
	NewDatafolder/O/S variables
	NewDatafolder /O/S subcell_1
	variable/G varIph_1, varm1_1, varm2_1, varI01_1, varI02_1, rs_1, rp_1	
	SetDataFolder root:variables:
	NewDataFolder /O/S subcell_2
	variable/G varIph_2, varm1_2, varm2_2, varI01_2, varI02_2, rs_2, rp_2
	SetDataFolder root:variables:
	NewDataFolder /O/S subcell_3
	variable/G varIph_3, varm1_3, varm2_3, varI01_3, varI02_3, rs_3, rp_3
	SetDataFolder root:variables:
	NewDataFolder /O/S subcell_4
	variable/G varIph_4, varm1_4, varm2_4, varI01_4, varI02_4, rs_4, rp_4
	SetDataFolder root:variables:	
	variable/G hold, popup, axis1, axis2, axis3, axis4
		
	SetDataFolder root:
	NewDataFolder/O/S strings
	string/G fich_name
	
	SetDataFolder root:
	NewDataFolder /O/S waves
	make/O/D/N=(500,2) waveprueba
	make/O/D/N=(100,2) matrix_data
	make/O/D nn1coefs, nn2coefs, nn3coefs, nn4coefs	
	
	SetDataFolder root:
	NewDataFolder/O loadedWaves
		
	varIph_1 = 0.0014;  varm1_1= 1; varm2_1= 2; varI01_1= 1e-25; varI02_1= 1e-30; rs_1 = 0.001; rp_1 = 200000
	varIph_2 = 0.0014;  varm1_2= 1; varm2_2= 2; varI01_2= 2e-25; varI02_2= 1e-30 ;rs_2 = 0.001; rp_2 = 200000
	varIph_3 = 0.0014;  varm1_3= 1; varm2_3= 2; varI01_3= 3e-25; varI02_3= 1e-30; rs_3 = 0.001; rp_3 = 200000
	varIph_4 = 0.0014;  varm1_4= 1; varm2_4= 2; varI01_4= 4e-25; varI02_4= 1e-30; rs_4 = 0.001; rp_4 = 200000
		
	hold = 0
	popup=1
	axis1 = -0.76
	axis2 = 5.6
	axis3 = -0.0034
	axis4 = 0.0045
	
	fich_name ="No loaded document"
	
	waveprueba = Nan
	matrix_data= Nan
	nn1coefs=Nan; nn2coefs=Nan; nn3coefs=Nan; nn4coefs=Nan
	

	PauseUpdate; Silent 1
	DoWindow/K controlPanel
	Newpanel /N=controlPanel /W=(100, 100, 1200, 600) as "Muestreador de Curvas I-V"	//Aparece un panel
	//modifypanel cbRGB=(0,30000,30000),fixedsize=1 //color of panel
	//Setdrawlayer/K userback
	//Setdrawenv fsize=20,fstyle=1//,textrgb=(65535,65535,65535)
	//Help Button to give help about how to use the program. This will be implemented soon
//	DrawPICT 1053,19,0.1875,0.171875,blue_help_button_icon_24517_p
//	Button buttonhelp, pos={1053, 40}, size={47, 15}, picture=blue_help_button_icon_24517_p
	Button button1, pos={20, 20}, size={60,30}, proc = buttonproc, title="LOAD"
	Button button2, pos={100, 350}, size={70,50}, proc = buttonproc, title="UPDATE"
	Button button3, pos={105.00,463.00},size={60.00,30.00}, proc=buttonproc, title="CLEAN"
	CheckBox checkhold, pos={415.00,30.00},size={47.00,15.00}, proc = CheckProc , title="HOLD", value = 0
	CheckBox checklog,  pos={483.00,474.00}, size={47.00,15.00}, proc = CheckProc, title="Log Scale", value = 0
	CheckBox checkinvy, pos={555.00,474.00}, size={65.00,15.00}, proc = CheckProc, title="Inv Y", value = 0
	CheckBox checkinvx, pos={604.00,474.00}, size={65.00,15.00}, proc = CheckProc, title="Inv X", value = 0
	CheckBox checkauto, pos={652.00,474.02}, size={65.00,15.00}, proc = CheckProc, title="AutoScale", value = 0	
	Button button4, pos={727.00,471.00}, size={122.00,18.00}, proc=buttonproc, title="Copy Current Axes"
	Button button5, pos={878.00,482.00}, size={65.00,16.00}, proc=buttonproc, title="Reset Axes"
	PopupMenu popup0,pos={355.00,332.00},size={112.00,19.00}, proc = PopMenuProc, title="Conection "
	PopupMenu popup0,fStyle=1,mode=1,popvalue="Serial",value= #"\"Serial;Parallel\""
	
	TitleBox tbname variable=fich_name, pos={100,25}, fixedsize=1, size= {300, 25}
	
	//Subcell_1
	SetVariable svIph1,pos={5.00,114.00},size={114.00,22.00},title="Iph_1",fSize=14
	SetVariable svIph1,limits={-inf,inf,0.0001},value= root:variables:subcell_1:varIph_1
	SetVariable svm11,pos={5.00,144.00},size={114.00,22.00},title="m1_1",fSize=14
	SetVariable svm11,limits={-inf,inf,0.1},value= root:variables:subcell_1:varm1_1
	SetVariable svm21,pos={5.00,174.00},size={114.00,22.00},title="m2_1",fSize=14
	SetVariable svm21,limits={-inf,inf,0.1},value= root:variables:subcell_1:varm2_1
	SetVariable svi011,pos={5.00,204.00},size={114.00,22.00},title="I01_1",fSize=14
	SetVariable svi011,limits={-inf,inf,1e-008},value= root:variables:subcell_1:varI01_1
	SetVariable svi021,pos={5.00,234.00},size={114.00,22.00},title="I02_1",fSize=14
	SetVariable svi021,limits={-inf,inf,1e-008},value= root:variables:subcell_1:varI02_1
	SetVariable svrs1,pos={11.00,264.00},size={108.00,22.00},title="Rs_1",fSize=14
	SetVariable svrs1,limits={-inf,inf,0.01},value= root:variables:subcell_1:rs_1
	SetVariable svrp1,pos={10.00,294.00},size={109.00,22.00},title="Rp_1",fSize=14
	SetVariable svrp1,limits={-inf,inf,1000},value= root:variables:subcell_1:rp_1
	
	//Subcell_2
	SetVariable svIph2,pos={124.00,114.00},size={114.00,22.00},title="Iph_2", fSize=14
	SetVariable svIph2,limits={-inf,inf,0.0001},value= root:variables:subcell_2:varIph_2
	SetVariable svm12,pos={124.00,144.00},size={114.00,22.00},title="m1_2",fSize=14
	SetVariable svm12,limits={-inf,inf,0.1},value= root:variables:subcell_2:varm1_2
	SetVariable svm22,pos={124.00,174.00},size={114.00,22.00},title="m2_2",fSize=14
	SetVariable svm22,limits={-inf,inf,0.1},value= root:variables:subcell_2:varm2_2
	SetVariable svi012,pos={124.00,204.00},size={114.00,22.00},title="I01_2",fSize=14
	SetVariable svi012,limits={-inf,inf,1e-008},value= root:variables:subcell_2:varI01_2
	SetVariable svi022,pos={124.00,234.00},size={114.00,22.00},title="I02_2",fSize=14
	SetVariable svi022,limits={-inf,inf,1e-008},value= root:variables:subcell_2:varI02_2
	SetVariable svrs2,pos={130.00,264.00},size={108.00,22.00},title="Rs_2",fSize=14
	SetVariable svrs2,limits={-inf,inf,0.01},value= root:variables:subcell_2:rs_2
	SetVariable svrp2,pos={129.00,294.00},size={109.00,22.00},title="Rp_2",fSize=14
	SetVariable svrp2,limits={-inf,inf,1000},value= root:variables:subcell_2:rp_2
	
	//Subcell_3
	SetVariable svIph3,pos={243.00,114.00},size={114.00,22.00},title="Iph_3", fSize=14
	SetVariable svIph3,limits={-inf,inf,0.0001},value= root:variables:subcell_3:varIph_3
	SetVariable svm13,pos={243.00,144.00},size={114.00,22.00},title="m1_3",fSize=14
	SetVariable svm13,limits={-inf,inf,0.1},value= root:variables:subcell_3:varm1_3
	SetVariable svm23,pos={243.00,174.00},size={114.00,22.00},title="m2_3",fSize=14
	SetVariable svm23,limits={-inf,inf,0.1},value= root:variables:subcell_3:varm2_3
	SetVariable svi013,pos={243.00,204.00},size={114.00,22.00},title="I01_3",fSize=14
	SetVariable svi013,limits={-inf,inf,1e-008},value= root:variables:subcell_3:varI01_3
	SetVariable svi023,pos={243.00,234.00},size={114.00,22.00},title="I02_3",fSize=14
	SetVariable svi023,limits={-inf,inf,1e-008},value= root:variables:subcell_3:varI02_3
	SetVariable svrs3,pos={249.00,264.00},size={108.00,22.00},title="Rs_3",fSize=14
	SetVariable svrs3,limits={-inf,inf,0.01},value= root:variables:subcell_3:rs_3
	SetVariable svrp3,pos={248.00,294.00},size={109.00,22.00},title="Rp_3",fSize=14
	SetVariable svrp3,limits={-inf,inf,1000},value= root:variables:subcell_3:rp_3
	
	//Subcell_4
	SetVariable svIph4,pos={362.00,114.00},size={114.00,22.00},title="Iph_4", fSize=14
	SetVariable svIph4,limits={-inf,inf,0.0001},value= root:variables:subcell_4:varIph_4
	SetVariable svm14,pos={362.00,144.00},size={114.00,22.00},title="m1_4",fSize=14
	SetVariable svm14,limits={-inf,inf,0.1},value= root:variables:subcell_4:varm1_4
	SetVariable svm24,pos={362.00,174.00},size={114.00,22.00},title="m2_4",fSize=14
	SetVariable svm24,limits={-inf,inf,0.1},value= root:variables:subcell_4:varm2_4
	SetVariable svi014,pos={362.00,204.00},size={114.00,22.00},title="I01_4", fSize=14
	SetVariable svi014,limits={-inf,inf,1e-008},value= root:variables:subcell_4:varI01_4
	SetVariable svi024,pos={362.00,234.00},size={114.00,22.00},title="I02_4", fSize=14
	SetVariable svi024,limits={-inf,inf,1e-008},value= root:variables:subcell_4:varI02_4
	SetVariable svrs4,pos={368.00,264.00},size={108.00,22.00},title="Rs_4",fSize=14
	SetVariable svrs4,limits={-inf,inf,0.01},value= root:variables:subcell_4:rs_4
	SetVariable svrp4,pos={367.00,294.00},size={109.00,22.00},title="Rp_4",fSize=14
	SetVariable svrp4,limits={-inf,inf,1000},value= root:variables:subcell_4:rp_4
	
	
	//ShowTools/A
	SetDrawLayer UserBack
	SetDrawEnv fstyle= 3
	DrawText 47,103,"SubCell_1"
	SetDrawEnv fstyle= 3
	DrawText 166,103,"SubCell_2"
	SetDrawEnv fstyle= 3
	DrawText 285,103,"SubCell_3"
	SetDrawEnv fstyle= 3
	DrawText 404,103,"SubCell_4"
	SetDrawEnv fstyle = 1
	DrawText 861,480,"Set Axis Scale"	
	SetDrawEnv fstyle= 7
	DrawText 1002,497,"Eje X"		
	SetDrawEnv fstyle= 7
	DrawText 1052,414,"Eje Y"
	//negative axis are called "1", positive "2"
	SetVariable svax1, title = "X1", pos={955, 462.00}, size={60.00,18.00}, live = 1, proc=SetVarProc, limits={-inf, inf, 0.02}, value = root:variables:axis1	
	SetVariable svax2, title = "X2", pos={1018,462.00}, size={60.00,18.00}, live = 1, proc=SetVarProc, limits={-inf, inf, 0.05}, value = root:variables:axis2
	SetVariable svax3, title = "Y2", pos={1042,438.00}, size={60.00,18.00}, live = 1, proc=SetVarProc, limits={-inf, inf, 0.0005}, value = root:variables:axis3
	SetVariable svax4, title = "Y1", pos={1042,418.00}, size={60.00,18.00}, live = 1, proc=SetVarProc, limits={-inf, inf, 0.0005}, value = root:variables:axis4
	
	
	createGraph() 
	
end


Function createGraph()
	
	SetDataFolder root:waves
	wave waveprueba
	SetDataFolder root:variables
	nvar axis1
	nvar axis2
	nvar axis3
	nvar axis4
	SetDataFolder root:
	string nameDisplay="controlPanel#graph"
	
	Display /HOST=controlPanel /N=graph /W=(480, 30, 1040, 460)  :waves:waveprueba[][0] vs :waves:waveprueba[][1]
	
	string wave_name = NameofWave (waveprueba)
	ModifyGraph /W=$nameDisplay rgb($wave_name)=(10000,10000,45535)
	ModifyGraph  /W=$nameDisplay mirror=1, tick=2, zero=2, minor = 1, standoff=0
	
	Label /W=$nameDisplay bottom "Voltage (V)"
	Label /W=$nameDisplay left "Intensity (A)"
	
	SetAxis  /W=$nameDisplay left axis3, axis4
	SetAxis  /W=$nameDisplay bottom axis1, axis2

	
	SetDataFolder root:
		
End

Function buttonproc(ba)  : ButtonControl

	struct WMButtonAction &ba
	
	if (ba.eventcode == 1 || ba.eventcode == 2 || ba.eventcode == 6)
		ba.blockReentry=1
				
		switch (ba.eventCode)
		case 2:		//Ratón up click
			//Run the implementation of buttons in only one function.
			strswitch(ba.ctrlname)
			case "button1": 	//Load
				LoadmyWave()
				break
			case "button2": 	//Update
				NVar popup = root:variables:popup
				Calculate(popup)
				break
			case "button3": 	//Clean
				Clean()	
				break
			case "button4":	//GetCurrentAxis
				ModifyAxis(6)
				break
			case "button5": 	//ResetAxis
				ModifyAxis(7)
				break
			endswitch
			break
		endswitch
	endif 
	return 0
End

Function CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	SetDataFolder root:variables
	nvar hold
	SetDataFolder root:
	variable buff = cba.eventCode
	switch( cba.eventCode )
		case 2: // mouse up
			strswitch(cba.ctrlName)
				case "checkhold": 
					hold = cba.checked
					break
				case "checklog":	 
				//The check log scale mark will chang the scale depending on the state of hold
					ModifyAxis (!cba.checked)				
					break				
				case "checkinvy": 	//Here we invert the axes
					ModifyAxis(3)
					break
				case "checkinvx":
					ModifyAxis(4)
					break						
				case "checkauto":
					ModifyAxis(5)	
			endswitch
			break
		case -1: // control being killed
			break
	endswitch
	SetDataFolder root:
	
	return 0
End

Function PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			//Variable popNum = pa.popNum
			//String popStr = pa.popStr
			nvar popup = root:variables:popup
			popup = pa.popNum
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function Clean ()
	SetDataFolder root:waves:
	wave waveprueba
	wave matrix_data
	SetDataFolder root:
	
//	Variable nheaders=numVarOrDefault("gnheaders",4)
////	variable jhg =numVarordefault("gjhg")
//	Prompt nheaders, "Number of headers"
//	Doprompt "Import 2-column data"
//	
	SetDataFolder root:LoadedWaves:
	if (strlen(wavelist("*",";","")) != 0)
		killwaves/A/Z
	endif
	
	waveprueba = NaN
	matrix_data = NaN
	
	AppendtoGraph /W=controlPanel#graph matrix_data
	//Not necesarry to appendtograph waveprueba
end 


//----------------------------------------------------------------------------------------------------------------------------------------
//
//Function Calculate ()
//	
//	SetDataFolder root:variables:
//	nvar varm1
//	nvar varm2
//	nvar varIph
//	nvar varI01
//	nvar varI02
//	nvar rs
//	nvar rp
//	
//	SetDataFolder root:waves:
//	wave waveprueba
//	wave nn1coefs
	

 	//FINDROOTS
 	
 	//this works with 2 columns of data (V and V_Root, x and y )
 	//for repeats 500 times ( from -2 to 3 V)
 	//for each "for" iteration, i(V) has a different value depending on V (increasing). This single i(V) value 
 	//is obtained from the non explicit equation of 2 exponentials. Its solved by FindRoots that calls a function with the non explicit 
 	//equation several times ( 100 times for each "for" iteration ) and also iterates with the sigle V value of the i(V) formula,
 	//to give a good aproximation of where the function has a root -zero- if we made the explicit formula, totally implicit.
 	
 	
// 	variable i
// 	variable V=-2
//
// 	for (i=0; i<500; i+=1)
// 		V+=0.01
// 		// 			  0  	    1		 2		  3			4	   5  6   7
//		nn1coefs={varIph, varm1, varm2, varI01, varI02, V, rs, rp}
// 		waveprueba[i][1]=V
// 		FindRoots/Q MyFunc, nn1coefs
// 		waveprueba[i][0] = V_Root
// 	endfor
// 	 		
// 	//AppendToGraph /W=controlPanel#graph waveprueba
//	//Crategraph is always displaying waveprueba. This function just calculate the wave's values
//	//No need to Append here any trace
//end
//
//Function MyFunc (w, x)
//	
//	wave w
//	variable x
//	
//	//Return root value for f(x) = 0
//	return -x -w[0] +(w[5] - x*w[6])/(w[7]) + w[4] *( exp ( (w[5] - x*w[6]) / (w[2] * 0.025 ) ) -1 ) + w[3] *( exp ( (w[5] - x*w[6] ) /(w[1] * 0.025 ) ) -1 )
//
//end

//------------------------------------------------------------------------------------------------------------------------------------------------------------


Function Calculate (popup)

		variable popup
	SetDataFolder root:variables:subcell_1:
		nvar varIph_1, varm1_1, varm2_1, varI01_1, varI02_1, rs_1, rp_1
	SetDataFolder root:variables:subcell_2:
		nvar varIph_2, varm1_2, varm2_2, varI01_2, varI02_2, rs_2, rp_2
	SetDataFolder root:variables:subcell_3:
		nvar varIph_3, varm1_3, varm2_3, varI01_3, varI02_3, rs_3, rp_3
	SetDataFolder root:variables:subcell_4:
		nvar varIph_4, varm1_4, varm2_4, varI01_4, varI02_4, rs_4, rp_4
	SetDataFolder root:waves:
		wave waveprueba
		wave nn1coefs, nn2coefs, nn3coefs, nn4coefs

	//FINDROOTS
	
	if (popup == 1) 	//Serial Conection among Subcells -> Sum of Voltages		
		
		make/O/D/N=(500) V1, V2, V3, V4	
		V1=Nan; V2=Nan; V3=Nan; V4=Nan
		variable i=-0.013
		variable j
		for (j=0; i<0.037; j+=1)	//Same as j<500 // 500 iterations //  -25 < i < 25 [mA]
			waveprueba[j][0]=i
			nn1coefs={varIph_1, varm1_1, varm2_1, varI01_1, varI02_1, i, rs_1, rp_1}
			nn2coefs={varIph_2, varm1_2, varm2_2, varI01_2, varI02_2, i, rs_2, rp_2}
			nn3coefs={varIph_3, varm1_3, varm2_3, varI01_3, varI02_3, i, rs_3, rp_3}
			nn4coefs={varIph_4, varm1_4, varm2_4, varI01_4, varI02_4, i, rs_4, rp_4}
			Findroots/Q MyFuncV, nn1coefs
			V1[j]=V_Root
			Findroots/Q MyFuncV, nn2coefs
			V2[j]=V_Root
			Findroots/Q MyFuncV, nn3coefs
			V3[j]=V_Root
			Findroots/Q MyFuncV, nn4coefs
			V4[j]=V_Root
			waveprueba[j][1]=V1[j]+V2[j]+V3[j]+V4[j]	
			i +=0.0001	
		endfor
		
	elseif (popup == 2 ) 	//Parallel Conection among Subcells -> Sum of Intensity
		
		make/O/D/N=(500) I1, I2, I3, I4
		I1=Nan; I2=Nan; I3=Nan; I4=Nan
		variable v = -1
		variable k
		wave I1, I2, I3, I4
		for (k=0; v<4.988; k+=1) //Same as k<500 // 500 iterations // -1 < v < 4.988 [V]
			waveprueba[k][1]=v
			nn1coefs={varIph_1, varm1_1, varm2_1, varI01_1, varI02_1, v, rs_1, rp_1}
			nn2coefs={varIph_2, varm1_2, varm2_2, varI01_2, varI02_2, v, rs_2, rp_2}
			nn3coefs={varIph_3, varm1_3, varm2_3, varI01_3, varI02_3, v, rs_3, rp_3}
			nn4coefs={varIph_4, varm1_4, varm2_4, varI01_4, varI02_4, v, rs_4, rp_4}
			Findroots/Q MyFuncI, nn1coefs
			I1[k]=V_Root
			Findroots/Q MyFuncI, nn2coefs
			I2[k]=V_Root
			Findroots/Q MyFuncI, nn3coefs
			I3[k]=V_Root
			Findroots/Q MyFuncI, nn4coefs
			I4[k]=V_Root
			waveprueba[k][0]=I1[k]+I2[k]+I3[k]+I4[k]
			v+=0.012
		endfor
	endif
end

Function MyFuncV (w, x)

	wave w
	variable x
	
	//Return root value for f(x) = 0
	return -w[5] -w[0] +(x + w[5]*w[6])/(w[7]) + w[4] *( exp ( (x + w[5]*w[6]) / (w[2] * 0.025 ) ) -1 ) + w[3] *( exp ( (x + w[5]*w[6] ) /(w[1] * 0.025 ) ) -1 )

end

Function MyFuncI (w, x)

	wave w
	variable x
	
	//Return root value for f(x) = 0
	return -x -w[0] +(w[5] + x*w[6])/(w[7]) + w[4] *( exp ( (w[5] + x*w[6]) / (w[2] * 0.025 ) ) -1 ) + w[3] *( exp ( (w[5] + x*w[6] ) /(w[1] * 0.025 ) ) -1 )
end

Function LoadmyWave ()

	SetDataFolder root:strings:
	svar fich_name	
	SetDataFolder root:variables:
	nvar hold	
	SetDataFolder root:waves:
	wave matrix_data	
	SetDataFolder root:loadedWaves:
	NewPath/O/Q path1, "D:Luis:UNIVERSIDAD:Prácticas Empresa:Igor:Curvas I-V"	
	//Using Macintosh nomenclature becouse its better (following Wavemetrics' advise)
	//O overwrite symbolic existing path
	//Q do not show the path in the command window
	
	
	variable layer = DimSize(matrix_data, 2)
	
	//Here i try to remove traces and implement the "HOLD CHECKBOX"
	
	string cadena
	if (layer >= 1 && !hold)
		String traceList = TraceNameList("controlPanel#graph", ";", 1)
		if(strlen(tracelist))
			variable i			
			for (i=0; strlen(cadena)!=0; i+=1)
				cadena = (StringFromList(i, traceList))
				if(stringmatch(cadena, "waveprueba"))
					continue
				endif
				if(strlen(cadena))
					RemoveFromgraph /W=controlPanel#graph matrix_data
				endif
				
			endfor
		endif
	endif

	//Loading wave as general text with auto name ( matrix ). read 2 columns from the .txt
	//The first one is used without matrix.
	//The second one is becouse of the matrix we use to store all the waves we are loading 
	
	//LoadWave/G/A=data/D/W/K=0 /P=path1 /O	//This loadwave is usefull for simple reading columns
	LoadWave/G/M/D/A=matrix/L={0,2,0,0,2} /P=path1	//this loadwave gives us the 2 column's marix
	//I: forze over-save the existing path
	//O: over-save the existing name if there's a name conflict
	//W with A creates the wave with the fichname as wave name ( S_FileName )
	//Q avoid text in the command shell
	
	string wavenames = S_wavenames
	if (V_flag)	//This avoid problems if we cancel the fich-loading ( have you load somethg or not? )
		fich_name = S_FileName
		if (strlen(wavenames) == 0) //The fich has no name. Error 
			print "Error in the fich-loading"
		else
			wave loadedwave = $(StringFromList(0, wavenames))
		endif
		
		//Because of the concatate, we need to be sure the columns and rows are the same
		variable a = DimSize (loadedwave, 0)
		variable b = DimSize (loadedwave, 1)
				
		if (a != 100 || b != 2)
			redimension/N=(100, 2) loadedwave
		endif
		
		//Creates the layer of matrix_data that stores different 2D waves in a 3D wave		
		SetDataFolder root:waves:
		if (DimSize(matrix_data, 2) == 0)
			concatenate/O {loadedwave}, matrix_data
		else
			concatenate {loadedwave}, matrix_data
		endif
		
		//Search for the extensions of the name fich and changes the graph to diferent axes (scaling log or not log)
		if (stringmatch (fich_name, "*0X.txt"))
			ModifyAxis(0)
		elseif (stringmatch (fich_name, "*1X.txt"))
			ModifyAxis(1)
		endif
		
		//Repeat the layer operation after the concatenate command to see if there's had changes in the layer of matrix_data
		layer = DimSize(matrix_data, 2)
		if (layer == 0)	//If layer dimension of matrix_data doesnt exist
			print "WARNING LoadWave. There's no layer in matrix_data"
		endif
		
		AppendToGraph /W=controlPanel#graph  matrix_data [*][1][layer-1] vs matrix_data [*][0][layer-1]
		

	endif
	SetDataFolder root:
	
end

Function ModifyAxis (mode)
	
	variable mode
	SetDataFolder root:variables:
	nvar axis1, axis2, axis3, axis4
	SetDataFolder root:
	string graphname="controlPanel#graph"
	
	if (mode==0) //Logarithmic Scale (0X)
		ModifyGraph /W=$graphname log(left)=1; DelayUpdate
		ModifyGraph /W=$graphname tick=0, zero=0, minor = 0
//		SetAxis  /W=$graphname left 5e-10, 1e^1
//		SetAxis  /W=$graphname bottom 0.5, 1.8
		axis3=5e-10
		axis4=1e^1
		ModifyAxis (2)
	
	elseif (mode==1)	 //Normal Scale (1X)
		ModifyGraph  /W=$graphname log(left) = 0; DelayUpdate
		ModifyGraph  /W=$graphname tick=2, zero=2, minor = 1
//		SetAxis  /W=$graphname left -0.2, 1
//		SetAxis  /W=$graphname bottom -0.5, 1.8
		ModifyAxis (2)
	
	elseif (mode==2) //Refresh axes 
		SetAxis  /W=$graphname left axis3, axis4
		SetAxis  /W=$graphname bottom axis1, axis2
	
	elseif (mode==3) //Invert Y
		variable aux
		aux = axis3
		axis3 = axis4
		axis4 = aux
		ModifyAxis(2)
	
	elseif (mode == 4) //Invert X
		variable aux1
		aux1 = axis1
		axis1 = axis2
		axis2 = aux1
		ModifyAxis(2)
		
	elseif (mode == 5) //AutoScale
		SetAxis /W=$graphname /A  
		
	elseif (mode == 6)	//GetCurrentAxis
		GetAxis /W=$graphname left
		if(!V_flag)		//If the axis we want to change is being used, V_Flag = 0. V_Flag = 1 if it doesn´t
			axis3 = V_min
			axis4 = V_max
		endif					
		GetAxis /W=$graphname bottom
		if(!V_flag)
			axis1 = V_min
			axis2 = V_max
		endif	
		
	elseif (mode == 7)	//resetAxis
		ControlInfo checklog
		if(V_Value)	//if logarithmic scale is being activited
			//Logarithmic Scale
			axis1 = -0.76; axis2 = 5.6; axis3=5e-10; axis4=1e^1
			
		else 
			//Normal
			axis1 = -0.76; axis2 = 5.6; axis3 = -0.0034; axis4 = 0.0045
		endif
		ModifyAxis(2)	
			//The complete implementation is missing. It has to detect if we are in logarithmic scale and
			//try do its best
	else
		print "ERROR in function Modify_Axes"

	endif
	
end

Function DoIExist()	//this function is called at the begining
	
	if (WinType("controlPanel")==7) //True if controlPanel exists as a name of a Panel "explicitly" ( non a graph or anythg else)
		killWindow controlPanel
		print "ControlPanel is dead now"
	endif
	
	SetDataFolder root:LoadedWaves:
	if (strlen(wavelist("*",";","")) != 0)
		SetDataFolder root:
		//Another option is to use KillWave/A, that erase all the waves in the folder loadedwaves
		killdataFolder loadedwaves
	endif
		
	
end

//With this function SetVarProc, we can update the values of the new axis in the graph each time the values 
//are being changed. I could use reference, but im still learning how to do that

Function SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	
	if (sva.eventcode == 1 || sva.eventcode == 2 || sva.eventcode == 3 )
		sva.blockReentry=1
		
		switch( sva.eventCode )
			case 1: // mouse up
			case 2: // Enter key
			case 3: // Live update
			
			strswitch (sva.ctrlname)
				case "svax1": 
				case "svax2":
				case "svax3":
				case "svax4": 
					ModifyAxis(2)
					break	
			endswitch
			
			case -1: // control being killed
				break
		endswitch
		
	endif

	return 0
End
