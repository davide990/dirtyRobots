// Agent supervisor in project moreRobots

/* Initial beliefs and rules */

/* Initial goals */
!hello.
!esaminaStanze.

/* Plans */

+!hello
	<-
		.print("Ciao! Sono il controllore :)");
	.

+!esaminaStanze 
	: true 
	<- 
		createWorkspace("stanza");
		
		joinWorkspace("stanza",WspID);
		makeArtifact("room", "davide.robots.Room", [], RoomID);	//verrà creato dentro il wsp "stanza"
		
		.print("-");
		.print("Controllo una stanza...");
		.print("-");
		.wait(1000);
		
		/* 
		 * dovrei mandare un messaggio in broadcast? In questo modo i pulitori sapranno che una stanza
		 * deve essere pulita, ma il primo che arriva se entra e la pulisce, mentre gli altri restano
		 * in corridoio in attesa. 
		 */
		
		.send(cleanerRobot1, tell, toClean("stanza","room"));
		
		quitWorkspace;
		joinWorkspace("default",_);
	.
