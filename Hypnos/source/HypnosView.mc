using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Sensor;
using Toybox.Timer as Timer;
using Toybox.System as Sys;
using Toybox.Communications as Comm;

class HypnosView extends Ui.View {

	var accel;
	var dataTimer;
	var width;

	var timeStep = 500;
	var windowSize = 60;
	
	var currentTotal = 0;

    // To print max, min, avg accel	
	var maxAccel = 0;
	var minAccel = 999999999;
	var avgAccel = 0;
	var totalTimeSteps = 0;
	var totAccel = 0;
	
	/* The idea is: we store an array of (x,y,z) acceleration components. Every timeStep we 
	   measure a new vector and we compare with the old one, adding the modulo of the
       difference to an array of acceleration modules over a window.
	*/
	var oldAcceleration = new [3];
	var accelerationsArray = new [windowSize];
	
	// Used to launch computation every windowSize step.
	var timeStepCounter = 0; 
	
	function jsonCallback(responseCode, data)
    {
    	Sys.println("Response code: " + responseCode);
    	Sys.println("-------------");
    	Sys.println("Data: " + data);
    }
	
    function initialize() {
        View.initialize();
        // FIXME: shoud be initialised to correct current value
        oldAcceleration[0] = 0;
        oldAcceleration[1] = 0;
        oldAcceleration[2] = 0;
        
        // FIXME: this is just a test
        //Comm.makeJsonRequest("http://jsonplaceholder.typicode.com/posts/1", null, null, method(:jsonCallback));
		
		var options = { :method => Comm.HTTP_REQUEST_METHOD_GET }; 
		Comm.makeJsonRequest("http://ta.mdx.ac.uk:8080/things", null, null, method(:jsonCallback));
    }
    
    

    //! Load your resources here
    function onLayout(dc) {
	    width = dc.getWidth();
        dataTimer = new Timer.Timer();
        dataTimer.start( method(:timerCallback), timeStep, true );
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        
		if( accel != null )
        {
            dc.drawText( width / 2, 23, Gfx.FONT_TINY, "Current = " + currentTotal, Gfx.TEXT_JUSTIFY_CENTER );
            dc.drawText( width / 2, 46, Gfx.FONT_TINY, "Max = " + maxAccel, Gfx.TEXT_JUSTIFY_CENTER );
            dc.drawText( width / 2, 69, Gfx.FONT_TINY, "Min = " + minAccel, Gfx.TEXT_JUSTIFY_CENTER );
            dc.drawText( width / 2, 92, Gfx.FONT_TINY, "Avg = " + avgAccel, Gfx.TEXT_JUSTIFY_CENTER );
            dc.drawText( width / 2, 115, Gfx.FONT_TINY, "Time steps = " + totalTimeSteps, Gfx.TEXT_JUSTIFY_CENTER );
        }
        else
        {
            dc.drawText( 100, 3, Gfx.FONT_TINY, "no Accel", Gfx.TEXT_JUSTIFY_CENTER );
        }
    }
    
    function timerCallback() {
        var info = Sensor.getInfo();

        if( info has :accel && info.accel != null )
        {
            accel = info.accel;
            
            // Compute the modulo of the difference wrt to previous accel. values
            var accModulo = (accel[0] - oldAcceleration[0])*(accel[0] - oldAcceleration[0]) +
                        (accel[1] - oldAcceleration[1])*(accel[1] - oldAcceleration[1]) +
                        (accel[2] - oldAcceleration[2])*(accel[2] - oldAcceleration[2]);

            // Add this to the array
            accelerationsArray[timeStepCounter] = accModulo;
            

	        // replace previous time step with current values                        
            oldAcceleration[0] = accel[0];
            oldAcceleration[1] = accel[1];
            oldAcceleration[2] = accel[2]; 
            
           timeStepCounter++;
             	    
            if ( timeStepCounter > (windowSize - 1) ) {
            	// We compute the total and display it on screen
            	currentTotal = 0;            	
            	for (var i=0; i<timeStepCounter; i++) {
            		currentTotal += accelerationsArray[i];
            	} 
            	currentTotal = currentTotal / 1000;
            	timeStepCounter = 0;
            	totalTimeSteps++;
            	
            	if  ( currentTotal < minAccel ) {
            		minAccel = currentTotal;
            	}
            	if ( currentTotal > maxAccel ) {
            		maxAccel = currentTotal;
            	}
            	avgAccel = (avgAccel*(totalTimeSteps-1)+currentTotal)/totalTimeSteps;
            }            
        }
	   	Ui.requestUpdate();
 	    
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

}
