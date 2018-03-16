import processing.serial.*; // import the Processing serial library
import controlP5.*;
import peasy.*;
import java.awt.event.*;

ControlP5 cp5;
PeasyCam cam;
CameraState state;
DataLogger dataLogger;

// icon and title
final static String ICON = "snowforce.png";
final static String TITLE = "snowforce";
final int MAXVAL = 255;
int MAXDRIVE = 16;
int MAXSENSE = 10;

boolean fillGrid; // fill grid or not
Serial a_port;
String PORT = "auto"; // com port
String comPort = "Not Found";
boolean is_serial_read = false;
String requestCommand = "A";
String packetType="string";
String DEVICE = "snowboard";

int current_time = millis();
float sensorFrameRate;
String strSensorData;

int[][] data;
int[][] data_to_draw;


int minFrame = 0;
int maxFrame = 0;
int sumFrame = 0;
int baudRate=115200;
int NDRIVE =16;
int NSENSE = 10;
float zscale = 1;


int[] driveindex = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
int[] senseindex = {0,1,2,3,4,5,6,7,8,9};

void setup(){
    // initialize screen
    size(800, 600);
    cam = new PeasyCam(this, width/2, height/2, 0, (width/800)*1000);
    cam.setMinimumDistance(50);
    cam.setMaximumDistance(15500);
    state = cam.getState();
    cam.lookAt(frame.getWidth()/2, frame.getHeight()/2, 0, (width/800)*1000);
    
    //icon and Title
    changeAppIcon( loadImage(ICON) );
    frame.setTitle(TITLE);
    
    setupSerial(); // initialize serial communication.
    setupControl(); // setup gui controls
    
    data = new int[NDRIVE][NSENSE];
    data_to_draw = new int[16][10];
    dataLogger = new DataLogger();
    
    baseline = new int[10];
    for(int i=0;i<10;++i)baseline[i]=0;
}

void stop()
{
    if (dataLogger.is_logging == true) dataLogger.stopLog();
}
void setupSerial()
{
    if (Serial.list().length == 0) // no device.
    {
        comPort = "Not Found";
        println("Device not attached.");
    } else
    {
        if (PORT.equals("auto")) comPort = Serial.list()[0];
        else comPort = PORT;

        println(comPort);
    }
}

void startSerial()
{
    if (comPort.equals("Not Found"))
    { // create virtual data if serial port or device is not available.
        for (int i = 0; i < data.length; i++)
        {
            for (int j = 0; j < data[0].length; j++)
            {
                data[i][j] = int(random(0, 50));
            }
        }
    } else
    {
        // serial port initialization with error handling
        a_port = new Serial(this, comPort, baudRate, 'N', 8, 1);
        println(comPort);
        println(baudRate);

        println("Initializing communication");
        int comm_init_start = millis();
        int comm_init_wait_time = 5000; // ms;
    }
}

// data acquisition
boolean getData()
{
    // lock buffer.
    is_serial_read = true;
    // request data
    a_port.write(requestCommand);
    
    // read the serial buffer:
    int [] sensors = new int[NDRIVE*NSENSE];    
    int[] resp = new int[NDRIVE*NSENSE];
    byte[] buffer = new byte[NDRIVE*NSENSE];
    int nread = 0;
    int offset = 0;
    if (packetType.equals("string"))
    {
        String myString = a_port.readStringUntil('\n');
        if (myString == null) return false;
    
        // if you got any bytes other than the linefeed:
        myString = trim(myString);
    
        // split the string at the commas
        // and convert the sections into integers:
        sensors = int(split(myString, ','));
    }
    else if (packetType.equals("binary"))
    {
      while (true)
      {
          if (a_port.available() > 0)
          {
              nread = a_port.readBytes(buffer);              
              for (int i = 0; i < nread; i++) resp[offset + i] = (int)(buffer[i]) & 0xFF;              
              offset += nread;              
          }
          
          if(nread==0)return false;
          if (offset == NDRIVE*NSENSE) break;
      }    
      if (offset != NDRIVE*NSENSE) return false;    
      for (int i = 0; i < sensors.length; i++) sensors[i] = resp[i];  
    }
    
    // statistics of sensor data.
    // get min and max value of current frame.
    minFrame = 100000;
    maxFrame = 0;
    sumFrame = 0;
    for (int i = 0; i < sensors.length; i++)
    {
        sumFrame += sensors[i];
        if (sensors[i] < minFrame) minFrame = sensors[i];
        if (sensors[i] > maxFrame) maxFrame = sensors[i];
    }
    // error checking.
    if (sensors.length != MAXDRIVE*MAXSENSE)
    {
        print("Incorrect data: ");
        print(sensors.length);
        println(" bytes");

        // unlock buffer
        is_serial_read = false;
        return false;
    }

    // create information for gui.     
    strSensorData = "";
    sensorFrameRate = millis() - current_time;

    // copy sensor data to variables for gui
    // preprocessing (filtering) is done here.
    int k = 0;
    
    for (int i = 0; i < data.length; i++)
    {
        for (int j = 0; j < data[0].length; j++)
        {
            data[driveindex[i]][senseindex[j]] = sensors[k++];            
            strSensorData += data[driveindex[i]][senseindex[j]] + ",";
        }
        strSensorData += "\n";
    }

    // update curren time
    current_time = millis();

    // unlock buffer
    is_serial_read = false;

    return true;
}

void keyPressed()
{
  if (key == CODED)
    {
        if (keyCode == UP) zscale = 2.0f * zscale;
        if (keyCode == DOWN) zscale = zscale / 2.0f;
    }
    if (key == 'u') dataLogger.toggleFrameUnit();
}
