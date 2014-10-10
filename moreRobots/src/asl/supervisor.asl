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
		.print("-");
		.print("Controllo una stanza...");
		.print("-");
		.wait(2000);
		createWorkspace("Stanzino");
		
		/* 
		 * dovrei mandare un messaggio in broadcast? In questo modo i pulitori sapranno che una stanza
		 * deve essere pulita, ma il primo che arriva se entra e la pulisce, mentre gli altri restano
		 * in corridoio in attesa. 
		 */
		.send(cleanerRobot1, tell, toClean("Stanzino"));
	.
