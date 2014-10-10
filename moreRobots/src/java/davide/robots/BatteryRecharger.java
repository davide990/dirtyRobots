// CArtAgO artifact code for project moreRobots

package davide.robots;

import cartago.*;

public class BatteryRecharger extends Artifact 
{
	void init(int initialValue) 
	{
		//defineObsProperty("count", initialValue);
	}
	
	@OPERATION
	void recharge()
	{
		//...
		
	}
	
	
	
	@OPERATION
	void inc() 
	{
		ObsProperty prop = getObsProperty("count");
		prop.updateValue(prop.intValue()+1);
		signal("tick");
	}
}

