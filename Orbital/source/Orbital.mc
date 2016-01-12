//!
//! Copyright 2015 Ettore Ferranti.
//! ettore.ferranti@gmail.com
//!

using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.ActivityMonitor as ActivityMonitor;

//! This watch face displays the time and other info as planets' orbits
class Orbital extends Ui.WatchFace
{
    var font;
	var sleeping = false;
    var timer;

    //! Constructor
    function initialize()
    {
    }

    //! Load resources
    function onLayout()
    {
        font = Gfx.FONT_MEDIUM;
    }

    function onShow()
    {
    }

    //! Nothing to do when going away
    function onHide()
    {
    }
    
    //! Draw the planet
    //! @param dc Device Context to Draw
	//! @param originX Origin X
	//! @param originY Origin Y
    //! @param angle Angle to draw the planet
    //! @param radius Radius of the planet orbit
    //! @param size Planet's size
    function drawPlanetOrigin(dc, originX, originY, angle, radius, size)
    {   
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        var x = originX - (radius * cos);
        var y = originY - (radius * sin);
        
        dc.fillCircle(x,y,size);
		
		return [x,y];
    }

    //! Draw the planet
    //! @param dc Device Context to Draw
    //! @param angle Angle to draw the planet
    //! @param radius Radius of the planet orbit
    //! @param size Planet's size
    function drawPlanet(dc, angle, radius, size)
    {
    	// Map out the coordinates of the watch hand
        var centerX = dc.getWidth() / 2.0;
        var centerY = dc.getHeight() / 2.0;
        
        return drawPlanetOrigin(dc, centerX, centerY, angle, radius, size);
		
    }

    //! Handle the update event
    function onUpdate(dc)
    {
    	// Colours
		var backgroundColour = Gfx.COLOR_WHITE;
        var foregroundColour = Gfx.COLOR_BLACK;
        var secondColour = Gfx.COLOR_BLACK;
        var minuteColour = Gfx.COLOR_RED;
        var hourColour = Gfx.COLOR_DK_BLUE;
        var sunColour = Gfx.COLOR_YELLOW;
        var batteryBackColour = Gfx.COLOR_LT_GRAY;
        
        // Sizes
		var width = dc.getWidth();
        var height = dc.getHeight();
        var minuteRadius = 80.0;
        var hourRadius = 50.0;
        var secondRadius = 20;
        var minuteSize = 10.0;
        var hourSize = 10.0;
        var secondSize = 3;
        var sunSize = 30.0;
        var fontHeight = 30.0;
        var halfFontHeight = fontHeight/2.0;
        var targetBackground = false;
        
        // Time and Date
        var clockTime = Sys.getClockTime();
        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);
        //var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);
        var dateStr = Lang.format("$1$\n$2$", [info.day_of_week, info.day.format("%.02d")]);
        
        // Info
        var batteryStatus = Sys.getSystemStats().battery;
        var steps = ActivityMonitor.getInfo().steps;
        var stepsGoal = ActivityMonitor.getInfo().stepGoal;
        var stepsPercentage = (steps*100.0) / stepsGoal;

		// Business Logic

        // Draw the background
		dc.setPenWidth(1);
        dc.setColor(backgroundColour, foregroundColour);
        dc.fillCircle(width/2.0,height/2.0,width/2.0);
        if (targetBackground)
        {
	        dc.setColor(Gfx.COLOR_BLACK, foregroundColour);
	        dc.drawCircle(width/2.0,height/2.0,hourRadius);
	        dc.drawCircle(width/2.0,height/2.0,minuteRadius);
	        dc.drawLine(width/2.0, 28, width/2.0, height-28);
	        dc.drawLine(28, height/2.0, width-28, height/2.0);
        }
        
        //in case SDK < 1.20
        if ((dc has :drawArc) == false) 
        {
			dc.setColor(Gfx.COLOR_BLACK, foregroundColour);
			dc.drawLine(width/2.0+1, 0, width/2.0+1, height);
        	dc.setColor(batteryBackColour, foregroundColour);
        	//steps (on the left)
			if (stepsPercentage > 100)
			{
				stepsPercentage = 100.0;
			}
        	dc.fillRectangle((width/2.0)-((width/2.0)*(stepsPercentage/100.0)), 0, (width/2.0)*(stepsPercentage/100.0), height);
        	//battery (on the right)
        	dc.fillRectangle(width/2.0, 0.0, (width/2.0)*(batteryStatus/100.0), height);
        }
        
        // Draw the clock external frame (with numbers)
        dc.setColor(foregroundColour, Gfx.COLOR_TRANSPARENT);
        dc.drawText((width/2),0,font,"XII",Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(width-5,(height/2)-halfFontHeight,font,"III", Gfx.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width/2,height-fontHeight,font,"VI", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(5,(height/2)-halfFontHeight,font,"IX",Gfx.TEXT_JUSTIFY_LEFT);
        for (var i = 0; i<Math.PI * 2.0; i+=Math.PI/6.0)
        {
        	drawPlanet(dc, i, width/2, 3);
        }
        
        // Draw the sun
        dc.setColor(sunColour, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(width/2.0, height/2.0, sunSize);

		// Draw the date
		dc.setColor(foregroundColour, Gfx.COLOR_TRANSPARENT);
        dc.drawText(width/2,(height/2)-25,Gfx.FONT_TINY, dateStr, Gfx.TEXT_JUSTIFY_CENTER);

        // Draw the hour. Convert it to minutes and
        // compute the angle.
        var hour = ( ( ( clockTime.hour % 12 ) * 60.0 ) + clockTime.min );
        hour = hour / (12.0 * 60.0);
        hour = hour * Math.PI * 2.0;
        hour += Math.PI/2;
        
        // Draw the minute
        var min = ( clockTime.min / 60.0) * Math.PI * 2.0;
        min += Math.PI/2.0;
        
        // Draw the second
		var second = ( clockTime.sec / 60.0) * Math.PI * 2.0;
        second += Math.PI/2.0;
        
        // Draw the orbits
        var minuteDegrees = ((-min+Math.PI)*57.2958);
		var hourDegrees = ((-hour+Math.PI)*57.2958);
		
        dc.setPenWidth(1);
        if (dc has :drawArc) 
        {
        	dc.drawArc(width/2,height/2,minuteRadius+3,dc.ARC_COUNTER_CLOCKWISE,minuteDegrees,minuteDegrees+100);
        	dc.drawArc(width/2,height/2,minuteRadius-2,dc.ARC_COUNTER_CLOCKWISE,minuteDegrees,minuteDegrees+100);
        	dc.drawArc(width/2,height/2,hourRadius+3,dc.ARC_COUNTER_CLOCKWISE,hourDegrees,hourDegrees+100);
        	dc.drawArc(width/2,height/2,hourRadius-2,dc.ARC_COUNTER_CLOCKWISE,hourDegrees,hourDegrees+100);
        	if (targetBackground)
        	{
        		dc.setPenWidth(4);
        		dc.setColor(Gfx.COLOR_WHITE, backgroundColour);
        		dc.drawArc(width/2,height/2,minuteRadius,dc.ARC_COUNTER_CLOCKWISE,minuteDegrees,minuteDegrees+100);
        		dc.drawArc(width/2,height/2,hourRadius,dc.ARC_COUNTER_CLOCKWISE,hourDegrees,hourDegrees+100);
        	}
        }
        dc.setPenWidth(4);
        dc.setColor(minuteColour, backgroundColour);
        if (dc has :drawArc) 
        {
        	dc.drawArc(width/2,height/2,minuteRadius,dc.ARC_COUNTER_CLOCKWISE,minuteDegrees+(100-batteryStatus),minuteDegrees+100);
        }
        
        var minCoordinates = drawPlanet(dc, min, minuteRadius, minuteSize);
        if ( Sys.getDeviceSettings().alarmCount==0 )
        {
        	dc.setColor(Gfx.COLOR_WHITE, backgroundColour);
        	drawPlanet(dc, min, minuteRadius, minuteSize-(minuteSize/2.0));
        }
        
        if(sleeping == false)
        {
        	dc.setColor(secondColour, backgroundColour);
        	drawPlanetOrigin(dc, minCoordinates[0], minCoordinates[1], second, secondRadius, secondSize);
        }
        
        dc.setColor(hourColour, backgroundColour);
        if(stepsPercentage>2)
        {
        	if (dc has :drawArc) 
        	{
        		dc.drawArc(width/2,height/2,hourRadius,dc.ARC_COUNTER_CLOCKWISE,hourDegrees+(100-stepsPercentage),hourDegrees+100);
        	}
        }
        drawPlanet(dc, hour, hourRadius, hourSize);
        if ( !Sys.getDeviceSettings().phoneConnected )
        {
        	dc.setColor(Gfx.COLOR_WHITE, backgroundColour);
        	drawPlanet(dc, hour, hourRadius, hourSize-(hourSize/2.0));
        }
		
    }
    
    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() 
    {
        sleeping = false;
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() 
    {
        sleeping = true;
        Ui.requestUpdate();
    }
}


class OrbitalWatch extends App.AppBase
{
    function onStart()
    {
    }

    function onStop()
    {
    }

    function getInitialView()
    {
        return [new Orbital()];
    }
}
