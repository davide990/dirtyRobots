// Agent cleanerRobot in project moreRobots

/*
 * 
 * Il robot pulitore scorre la stanza dalla posizione in alto a sinistra alla posizione in basso a destra. 
 * 
 */

/* Initial beliefs and rules */
at(cleanerRobot, 0, 0).
battery(100).

/* Initial goals */

//!enterRoom.
!hello.
/* Plans */


+!hello <-
	.my_name(N);
	.print("Ciao, il mio nome è ", N);
.

+!enterRoom
	: true
	<-
		makeArtifact("room", "davide.robots.Room", [], RoomID);
		.print("stanza ",RoomID );
		.print("artefatto stanza ",RoomID," creato!");
		//lookupArtifact("c0",CounterId)........
		focus(RoomID);	//se non facessi il focus sulla stanza, le proprietà osservabili
						//non verrebbero mappate nella belief base del robot pulitore.
		!move;
	. 

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
		
+!move
	: 	at(_,X,Y) &
		floorHeight(H) & floorWidth(W) &
		X==H-1 & Y==W-1 &
		not dirty(X,Y)				//ho terminato la pulizia della stanza
	<-
		.print("ho finito. Torno in corridoio!");
		quitWorkspace;
		joinWorkspace("default",_);
	.
		
/*
 * mi muovo nella stanza.
 */		
+!move
	: 	at(_,X,Y) &
		floorHeight(H) & floorWidth(W) &
		X==H-1 & Y==W-1 			
	<-
		moveToward(X, Y, NewX, NewY);
		.print("mi trovo in posizione ",X,",",Y);
		.


+!move
	: 	at(_,X,Y) &  					//mi trovo in una certa posizione
		not garbage &					//non ho raccolto olio
		(battery(Bl) & Bl>0) 			//ho ancora carica
	<-
		.print("mi trovo in posizione ",X,",",Y," (carica batteria: ",Bl,")"); 		
   		moveToward(X, Y, NewX, NewY);   		
   		-+at(C,NewX,NewY);
   		
   	  	.wait(100);
   	  	
   	  	//B = Bl-1;				//decremento di un'unità l'energia della batteria
   	  	-+battery(Bl-1);
   	  	
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

/*
 *	Questo evento viene triggerato quando il controllore incarica un agente di pulire una stanza. 
 */
+toClean(RoomName)[source(X)]		
	<-
		.print("entro nella stanza ", RoomName);
		joinWorkspace(RoomName, WspID);
		!!enterRoom;
	.

/*
 * Trovo dello sporco in posizione X,Y. Pulisco la cella.
 */
+dirty(X,Y) <-
	+garbage;
	.print("---");
	.print("la cella ",X,",",Y," e' sporca. Ora la pulisco...");
	.wait(500);
	
	cleanCell(X,Y);
	
	.print("la cella ",X,",",Y," e' stata pulita");
	.print("---");
	-garbage;
.