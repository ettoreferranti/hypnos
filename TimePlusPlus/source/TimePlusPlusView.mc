using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Calendar;

class TimePlusPlusView extends Ui.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        //setLayout(Rez.Layouts.WatchFace(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Draw hand
	function drawHand(dc, length, angle)
	{
		var diamondWidth = Math.PI/30;
		// Center of the display
        var centerX = dc.getWidth() / 2.0;
        var centerY = dc.getHeight() / 2.0;
        
        // Calculate the 4 points to draw a diamond
		var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        var x = centerX - (length * cos);
        var y = centerY - (length * sin);
        
        var cos1 = Math.cos(angle-diamondWidth);
        var sin1 = Math.sin(angle-diamondWidth);

        var x1 = centerX - ((length/2.0) * cos1);
        var y1 = centerY - ((length/2.0) * sin1);
        
        var cos2 = Math.cos(angle+diamondWidth);
        var sin2 = Math.sin(angle+diamondWidth);

        var x2 = centerX - ((length/2.0) * cos2);
        var y2 = centerY - ((length/2.0) * sin2);
        
        // Draw the diamond
        dc.fillPolygon([[centerX,centerY],[x1,y1],[x,y],[x2,y2]]);
	}	

    //! Update the view
    function onUpdate(dc) {
    
    	// Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
    	// Info
        var batteryStatus = Sys.getSystemStats().battery;
        var steps = ActivityMonitor.getInfo().steps;
        var stepsGoal = ActivityMonitor.getInfo().stepGoal;
        var stepsPercentage = (steps*1.0) / stepsGoal;
        var clockTime = Sys.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);
        var dateStr = Lang.format("$1$ $2$", [info.day_of_week, info.day.format("%.02d")]);
        
        // Design variables
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        var stepsColour = Gfx.COLOR_BLUE;
        var stepsReachedColour = Gfx.COLOR_GREEN;
        var stepsWidth = 8;
        var batteryColour = Gfx.COLOR_RED;
        var batteryWidth = 8;
        
        var step = 2.0*Math.PI/60.0;
        var hourFont = Gfx.FONT_TINY;
        var fontCorrection = dc.getFontHeight(hourFont)/2.0;
        var hourRadius = 80;
        var minuteRadius = 100;
        var tickRadius = 100;
        var hourHandColour = Gfx.COLOR_BLUE;
        var minuteHandColour = Gfx.COLOR_RED;
        var hourTextColour = Gfx.COLOR_WHITE;
        var tickColour = Gfx.COLOR_WHITE;
        var tickHourColour = Gfx.COLOR_RED;
        var dateColour = Gfx.COLOR_WHITE;
        var alarmColour = Gfx.COLOR_RED;
        var connectedColour = Gfx.COLOR_BLUE;
        var backgroundColour = Gfx.COLOR_TRANSPARENT;
        
        // Draw the background
		dc.setColor(stepsColour,backgroundColour);
		
		dc.clear();

		// Draw the steps percentage arc
        dc.setColor(stepsColour,Gfx.COLOR_TRANSPARENT);
        
        dc.setPenWidth(stepsWidth);
        
        if (stepsPercentage > 0.02 && stepsPercentage < 1.0)
        {
        	dc.drawArc(width/2.0, height/2, width/2.0-4.0, Gfx.ARC_CLOCKWISE, 210.0, 210.0-(240.0*stepsPercentage));
        }
        else if(stepsPercentage >= 1.0)
        {
        	dc.setColor(stepsReachedColour,Gfx.COLOR_TRANSPARENT);
        	dc.drawArc(width/2.0, height/2, width/2.0-4.0, Gfx.ARC_CLOCKWISE, 210.0, 210.0-(240.0));
        }
        
        // Draw the battery status arc
        dc.setColor(batteryColour,Gfx.COLOR_TRANSPARENT);
        
        dc.setPenWidth(batteryWidth);
        
        dc.drawArc(width/2.0, height/2, width/2.0-4.0, Gfx.ARC_COUNTER_CLOCKWISE, 210, 210+(120*(batteryStatus/100.0)));
        
        // Draw the minute hand
		dc.setColor(minuteHandColour, Gfx.COLOR_TRANSPARENT);
        
        var min = ( clockTime.min / 60.0) * Math.PI * 2.0;
        min += Math.PI/2.0;
        
        drawHand(dc, minuteRadius, min);
        
        // Draw the hour hand
		dc.setColor(hourHandColour, Gfx.COLOR_TRANSPARENT);

        var hour = ( ( ( clockTime.hour % 12 ) * 60.0 ) + clockTime.min );
        hour = hour / (12.0 * 60.0);
        hour = hour * Math.PI * 2.0;
        hour += Math.PI/2;
        
        drawHand(dc, hourRadius-10, hour);
        
        //Draw the date
        dc.setColor(dateColour,Gfx.COLOR_TRANSPARENT);
        dc.drawText(width/2.0, 130, Gfx.FONT_MEDIUM, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw the bezel
        dc.setPenWidth(2);
        for (var i = 1; i<=60; i++)
        {
        	var cos = Math.cos((step*i)+(Math.PI/2.0));
        	var sin = Math.sin((step*i)+(Math.PI/2.0));

        	var x = (width/2.0) - (hourRadius * cos);
        	var y = (height/2.0) - (hourRadius * sin);
        	
        	if (i % 5 == 0)
        	//write hour
        	{
        		dc.setColor(hourTextColour,Gfx.COLOR_TRANSPARENT);
        		y = y - fontCorrection;
        	
        		dc.drawText(x, y, hourFont, Lang.format("$1$", [(i/5).format("%02d")]), Gfx.TEXT_JUSTIFY_CENTER);
        		
        		dc.setColor(tickHourColour,Gfx.COLOR_TRANSPARENT);
        	}
        	else
        	{
        		dc.setColor(tickColour,Gfx.COLOR_TRANSPARENT);
        	}
        	//draw tick
    		var x1 = (width/2.0) - ((tickRadius) * cos);
    		var y1 = (height/2.0) - ((tickRadius) * sin);
    		var x2 = (width/2.0) - ((tickRadius-4) * cos);
    		var y2 = (width/2.0) - ((tickRadius-4) * sin);
    
    		dc.drawLine(x1, y1, x2, y2);
        	
        }

		// Draw the alarms icon (if there are alarms set)
		if ( Sys.getDeviceSettings().alarmCount>0 )
        {
			dc.setColor(alarmColour,Gfx.COLOR_TRANSPARENT);
			dc.drawText(67, 53, Gfx.FONT_MEDIUM, "A", Gfx.TEXT_JUSTIFY_CENTER);
		}
		
		// Draw the phone connected icon (if a phone is connected)
		if ( Sys.getDeviceSettings().phoneConnected )
        {
			dc.setColor(connectedColour,Gfx.COLOR_TRANSPARENT);
			dc.drawText(151, 53, Gfx.FONT_MEDIUM, "B", Gfx.TEXT_JUSTIFY_CENTER);
		}
		
		// Draw the boundaries of battery and steps
		dc.setColor(tickColour,Gfx.COLOR_TRANSPARENT);
		var cosA = Math.cos(7*Math.PI/6);
    	var sinA = Math.sin(7*Math.PI/6);

    	var xA1 = (width/2.0) - (tickRadius * cosA);
    	var yA1 = (height/2.0) - (tickRadius * sinA);
    	
    	var xA2 = (width/2.0) - ((tickRadius+10) * cosA);
    	var yA2 = (height/2.0) - ((tickRadius+10) * sinA);

    	dc.drawLine(xA1,yA1,xA2,yA2);
    	
    	var cosB = Math.cos(-Math.PI/6);
    	var sinB = Math.sin(-Math.PI/6);

    	var xB1 = (width/2.0) - (tickRadius * cosB);
    	var yB1 = (height/2.0) - (tickRadius * sinB);
    	
    	var xB2 = (width/2.0) - ((tickRadius+10) * cosB);
    	var yB2 = (height/2.0) - ((tickRadius+10) * sinB);

    	dc.drawLine(xB1,yB1,xB2,yB2);
        
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
