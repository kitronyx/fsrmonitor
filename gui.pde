import java.util.Arrays;

// gui controls
DropdownList dSerial;
Button bStartStop;
Button bLog;
Button bType;
boolean do_data_acquisition = false;
boolean do_data_log = false;
boolean do_device_aduino = true;

void changeAppIcon(PImage img)
{
    final PGraphics pg = createGraphics(48, 48, JAVA2D);
    pg.beginDraw();
    pg.image(img, 0, 0, 48, 48);
    pg.endDraw();
    frame.setIconImage(pg.image);
}


void drawGraph()
{
    getDataToDraw();
    
    pushMatrix(); 
    visualization2D();
    popMatrix();
}

void getDataToDraw()
{
    // decorate data to visualize using obtained sensor data.
    // here data in the range of display is picked up and
    // stored in `data_to_draw`.
    for (int i = 0; i < 16; i++)
    {
        for (int j = 0; j < 10; j++)
        {
            data_to_draw[i][j] = int(zscale*float(data[i][j]));
        }
    }
}




void setupControl()
{
    int controlXPos0 = 10;
    int controlYPos0 = 25;
    int controlWidth = 80;
    int controlHeight = 20;
    int controlXStep = controlWidth + 20;
    int controlYStep = controlHeight + 5;
    int row = 0;
    //ControlP5 cp5;
    cp5 = new ControlP5(this);
    // 2nd row
    row = 2;
    bStartStop = cp5.addButton("Start (s)", 0, controlXPos0, controlYPos0 + (row-1)*controlYStep, controlWidth, controlHeight);
    // 3rd row
    row = 3;
    bLog = cp5.addButton("Start Logging", 0, controlXPos0, controlYPos0 + (row-1)*controlYStep, controlWidth, controlHeight);
    // 4rd row
    row = 4;
    bType =cp5.addButton("With aduino", 0, controlXPos0, controlYPos0 + (row-1)*controlYStep, controlWidth, controlHeight);
    
    
    dSerial = cp5.addDropdownList("Serial").setPosition(controlXPos0, controlYPos0).setWidth(controlWidth);
    dSerial.captionLabel().set("Choose Port");
    for (int i=0; i<Serial.list ().length; i++)
    {
        dSerial.addItem(Serial.list()[i], i);
    }
    cp5.setAutoDraw(false);
}

void controlEvent(ControlEvent theEvent)
{
    if (theEvent.isGroup())
    {
        // check if the Event was triggered from a ControlGroup
        if (theEvent.getGroup() == dSerial)
        {
            comPort = dSerial.getItem(int(theEvent.getGroup().getValue())).getName();
        }
        
    } 
    else if (theEvent.isController())
    {
        if (theEvent.controller() == bStartStop)
        {
            if (do_data_acquisition) stopDevice();
            else startDevice();
        }
        else if (theEvent.controller() == bLog)
        {
            if (do_data_log) stopLog();
            else startLog();
        }
        else if (theEvent.controller() == bType)
        {
          if (!do_device_aduino) stringType();
            else binaryType();
        }
       
    }
}

void stringType()
{
  bType.setCaptionLabel("With aduino");
  packetType="string";
  baudRate=115200;
  do_device_aduino = true;
}
void binaryType()
{
  bType.setCaptionLabel("Snowforce2 alone");
  packetType="binary";
  baudRate=1497600;
  do_device_aduino = false;
}

void startDevice()
{
    bStartStop.setCaptionLabel("Stop (s)");
                
    if (!comPort.equals("Not Found"))
    {
        startSerial();
        do_data_acquisition = true;
    }
    else
    {
        do_data_acquisition = false;
    }
}

void stopDevice()
{
    bStartStop.setCaptionLabel("Start (s)");
    a_port.stop();
    do_data_acquisition = false;
}

void startLog()
{
    bLog.setCaptionLabel("Stop Logging");
    dataLogger.createFileNameBasedOnTime();
    dataLogger.startLog(data.length, data[0].length);
    do_data_log = true;
}

void stopLog()
{
    bLog.setCaptionLabel("Start Logging");
    dataLogger.stopLog();
    do_data_log = false;
}



