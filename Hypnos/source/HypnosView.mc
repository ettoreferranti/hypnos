using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Sensor as Sensor;
using Toybox.Timer as Timer;
using Toybox.System as Sys;

class HypnosView extends Ui.View {

	var accel;
	var dataTimer;
	var width;

    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
	    width = dc.getWidth();
        dataTimer = new Timer.Timer();
        dataTimer.start( method(:timerCallback), 100, true );
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
            dc.drawText( width / 2,  3, Gfx.FONT_TINY, "Ax = " + accel[0], Gfx.TEXT_JUSTIFY_CENTER );
            dc.drawText( width / 2, 23, Gfx.FONT_TINY, "Ay = " + accel[1], Gfx.TEXT_JUSTIFY_CENTER );
            dc.drawText( width / 2, 43, Gfx.FONT_TINY, "Az = " + accel[2], Gfx.TEXT_JUSTIFY_CENTER );
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
        }
        Ui.requestUpdate(); 
        
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

}
