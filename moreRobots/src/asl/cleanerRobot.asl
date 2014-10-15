// Agent cleanerRobot in project moreRobots

/*
 * 
 * Il robot pulitore scorre la stanza dalla posizione in alto a sinistra alla posizione in basso a destra. 
 * 
 */

/* Initial beliefs and rules */
at(0, 0).
battery(2).
distFromRecharger(0).

/* Initial goals */

//!enterRoom.
!hello.
/* Plans */


+!hello <-
	.my_name(N);
	.print("Ciao, il mio nome è ", N);
.
	
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
/**
 * sono tornato al punto di partenza
 */
+!rechargeBattery
	:
		at(X,Y)				&
		lastPos(LastX,LastY) 	&
		X==LastX & Y==LastY 	&
		batteryRecharged
	<-
		.print("torno a muovermi...");
		-lastPos(LX,LY);
		-batteryRecharged;
		
		.wait(1000);
	.

/**
 * mi muovo verso il punto di partenza
 */
+!rechargeBattery
	:
		at(X,Y)	&
		lastPos(LastX,LastY) &
		(X\==LastX | Y\==LastY) &
		batteryRecharged
	<-
		moveTorwards(X, Y, LastX, LastY, DX, DY);
		.print("mi muovo verso il punto di partenza, sono in ",X-DX,",",Y-DY);
		-+at(X-DX, Y-DY);
		
		!rechargeBattery;
	.

/**
 * Sono nella stessa cella del carica batteria
 */
+!rechargeBattery
	:
		at(X,Y)	&
		rechargerPosX(RX)	&
		rechargerPosY(RY)	&
		X==RX & Y==RY &
		not batteryRecharged
		
	<-
		+batteryRecharged;
		.print("ricarico!");
		.wait(2000);
		?battery(Bl);
		-+battery(Bl+10);
		
		!rechargeBattery;
	.

/**
 * Mi muovo verso il carica batteria
 */
+!rechargeBattery
	:
		at(X,Y)	&
		rechargerPosX(RX)	&
		rechargerPosY(RY)	&
		(X\==RX | Y\==RY)	&
		not batteryRecharged
	<-
		moveTorwards(X, Y, RX, RY, DX, DY);
		.wait(100);
		-+at(X-DX, Y-DY);
		.print("mi muovo verso il caricatore, sono in ",X-DX,",",Y-DY);
		
		!rechargeBattery;
	.

//---------------------------------------------------------------------
//---------------------------------------------------------------------

/*
 * mi trovo in corridoio
 */
+!move
	:	current_wsp(_,Name,_) &
		Name=="default"			
	<-
		.wait(1500);
		!!move;
	.
	
/**
 * Sono sull'ultima cella e questa non è sporca
 */	
+!move
	: 	at(X,Y) &
		floorHeight(H) & floorWidth(W) &
		X==H-1 & Y==W-1 &
		not dirty(X,Y)				//ho terminato la pulizia della stanza
	<-
		.print("ho finito. Torno in corridoio!");
		quitWorkspace;
		joinWorkspace("default",_);
	.
		
/**
 * Sono sull'ultima cella e questa è sporca
 */
+!move	
	: 	at(X,Y) &
		floorHeight(H) & floorWidth(W) &
		X==H-1 & Y==W-1 			
	<-
		getNextCellCoordinates(X, Y, NewX, NewY);
		.print("mi trovo in posizione ",X,",",Y);
	.

/**
 * Batteria scarica
 */
+!move	//ho intenzione di muovermi ma ho la batteria scarica
	: 	at(X,Y)	&
		battery(Bl) &
		distFromRecharger(D) &
		Bl < D		//mi muovo verso il caricatore quando la durata della batteria è minore della distanza
	<-
		.print("ho finito la carica....");
		
		//conservo l'ultima posizione
		+lastPos(X,Y);
		
		//vado a ricaricare la batteria
		!rechargeBattery;
		
		!!move;
	.

/**
 * Mi muovo nella stanza
 */
+!move
	: 	at(X,Y) &  					//mi trovo in una certa posizione
		not garbage 					//non ho raccolto olio
	<-
		.print("mi trovo in posizione ",X,",",Y); 		
   		getNextCellCoordinates(X, Y, NewX, NewY);
   		
   		-+at(NewX, NewY);
   		
   	  	.wait(100);
   	  	
   	  	-+battery(Bl-1);	//decremento di un'unità l'energia della batteria
   	  	distanceFromRecharger(NewX, NewY, D);
   	  	
   	  	-+distFromRecharger(D);
   	  	!!move
   	  	.
 
 /*
  * cerco di muovermi ma sono in una cella sporca.
  */
+!move
	: 	garbage			
	<-
   	  	!!move
   	  	.

//------------------------------------------------------
//------------------------------------------------------

/*
 * Trovo dello sporco in posizione X,Y. Pulisco la cella.
 */
+dirty(X,Y) 
	<-
	+garbage;
	.print("---");
	.print("la cella ",X,",",Y," e' sporca. Ora la pulisco...");
	.wait(500);
	
	cleanCell(X,Y);
	
	.print("la cella ",X,",",Y," e' stata pulita");
	.print("---");
	//.wait(10000);
	-garbage;
	.

/*
 *	Questo evento viene triggerato quando il controllore incarica un agente di pulire una stanza. 
 */
+toClean(WsName, RoomName)[source(X)]
	<-
		joinWorkspace(WsName, WspID);
		lookupArtifact(RoomName, RoomID);
		focus(RoomID);
		
		distanceFromRecharger(0, 0, D);
		-+distFromRecharger(D);
		.print("La mia distanza dal caricatore è ",D);
		!!move;
	.