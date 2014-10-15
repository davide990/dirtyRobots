package davide.robots;

import cartago.*;

public class Room extends Artifact 
{
	public class Point
	{
		public int X;
		public int Y;
		
		public Point(int x, int y)
		{
			X=x;
			Y=y;
		}
	}
	
	private static final int FLOOR_WIDTH 	= 4;
	private static final int FLOOR_HEIGHT 	= 4;
	private boolean[][] floor;
	private Point rechargerPos;
	
	
	void init() 
	{
		//defineObsProperty("count", 	0);
		
		floor 			= new boolean[FLOOR_WIDTH][FLOOR_HEIGHT];
		rechargerPos 	= new Point(1, 3);
		
		for (int i=0;i<FLOOR_HEIGHT;i++)
		{
			for (int j=0;j<FLOOR_WIDTH;j++)
				floor[i][j] = true;
		}
		
		//metto "sporcizia" nel pavimento....
		floor[0][0] = false;
		floor[1][1] = false;
		floor[3][3] = false;
		
		defineObsProperty("floorWidth", 	FLOOR_WIDTH);
		defineObsProperty("floorHeight", 	FLOOR_HEIGHT);
		defineObsProperty("rechargerPosX", 	1);
		defineObsProperty("rechargerPosY", 	3);
		System.out.println("[ARTEFATTO STANZA] artefatto creato.");
	}

	/**
	 * Determines if floor cell at (X,Y) is clean.
	 * @param X
	 * @param Y
	 * @param clean state of cleanliness at (X,Y)
	 */
	@OPERATION
	void isClean(int X, int Y, OpFeedbackParam<Boolean> clean)
	{
		clean.set(floor[X][Y]); 
	}
	
	/**
	 * Set the cleanliness state of the floor cell at (X,Y)
	 * @param cleanliness True if cell at (X,Y) is clean, false otherwise.
	 */
	@OPERATION
	void setCleanliness(int X, int Y, boolean cleanliness)
	{
		floor[X][Y] = cleanliness;
	}
	
	
	/**
	 * Return the X,Y coordinates of the next cell.
	 * @param currentX
	 * @param currentY
	 * @param newX
	 * @param newY
	 */
	@OPERATION
	void getNextCellCoordinates(int currentX, int currentY, OpFeedbackParam<Integer> newX, OpFeedbackParam<Integer> newY)
	{
		int _newX=0, _newY=0;
		
		if(currentY == FLOOR_WIDTH-1 && currentX == FLOOR_HEIGHT-1) //ultima cella
		{
			_newX=currentX;
			_newY=currentY;
		}
		else
		if(currentY == FLOOR_WIDTH-1 && currentX < FLOOR_HEIGHT)	//ultima cella di una riga che non sia l'ultima
		{
			_newX=currentX+1;
			_newY=0;
		}
		else
		{
			_newX=currentX;
			_newY=currentY+1;
		}
		
		newX.set(_newX);
		newY.set(_newY);
		
		//check the cleanliness state of the cell
		if(!floor[currentX][currentY])
			defineObsProperty("dirty", currentX, currentY);
	}
	
	/**
	 * Clean the floor cell at X,Y
	 */
	@OPERATION
	void cleanCell(int X, int Y)
	{
		if(!floor[X][Y])
		{
			floor[X][Y] = true;
			removeObsPropertyByTemplate("dirty", X, Y);
		}
	}
	
	//da eliminare
	@OPERATION
	void inc() 
	{
		ObsProperty prop = getObsProperty("count");
		prop.updateValue(prop.intValue()+1);
		signal("tick");
	}
	
	@OPERATION
	void moveTorwards(int currentX, int currentY, int destX, int destY, OpFeedbackParam<Integer> movementX, OpFeedbackParam<Integer> movementY)
	{
		movementX.set((int)Math.signum(currentX-destX));
		movementY.set((int)Math.signum(currentY-destY));
	}
	
	/**
	 * Get the distance between the agent (at x,y) and the recharger. d is the resulting distance. 
	 */
	@OPERATION
	void distanceFromRecharger(int x, int y, OpFeedbackParam<Integer> d)
	{
		d.set((int)Math.round(Math.sqrt(Math.pow(x-rechargerPos.X, 2) + Math.pow(y-rechargerPos.Y, 2))));
	}
	
	
}


