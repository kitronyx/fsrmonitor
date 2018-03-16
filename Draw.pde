int drawCount = 0;
int nLogInterval = 5;
int logIntervalIndex = 0;
int[] logInterval = {1, 100, 1000, 2000, 3000};
int tstart = 0;
int[] baseline;

void draw()
{
  if (0 == drawCount % logInterval[logIntervalIndex]) tstart = millis();
  if (do_data_acquisition && !comPort.equals("Not Found")) getData(); 
  background(0, 255, 255);
  
  drawGraph();
  
  drawControl();
  drawLogo();
  drawInfo();
  
  if (0 == drawCount % logInterval[logIntervalIndex])
    {
        int telapsed = millis() - tstart;
        dataLogger.setTs(telapsed);
        dataLogger.logData(data);
        drawCount = 0;
    }
}

void drawControl()
{
    hint(DISABLE_DEPTH_TEST);
    cp5.draw();
    hint(ENABLE_DEPTH_TEST);
}
void drawLogo()
{
    fill(255);
    rect(width/2-100, 0, 200, 50, 0, 0, 100, 100);
    textAlign(CENTER);
    textSize(25);
    fill(0);
    text("KITRONYX", width/2, 30);
    fill(255);
}
void drawInfo()
{
    textSize(15);
    textAlign(RIGHT, TOP); 
    fill(0);
    String strInfo = "Port: " + comPort + "\n" +
        "Baud Rate: " + baudRate + "\n" +       
        "Log Interval: " + logInterval[logIntervalIndex] +"\n"+
        "Scale: " + zscale+"\n"+"Up/Down: Scale Z Axis\n";
    text(strInfo, width-10, 10);
}
void drawgraphinfo()
{
    textSize(10);
    strokeWeight(4);
    //0th location 
    text(0, 20, height - 25);    
    rect(20, height - 20, width-20, 1);
    rect(20, height - 110, width-20, 1);
    
    
    for (int i = 0; i < 10; i++)
    {
      String numbername= (i+1)+"th";
      text(((i+1)*50), 20, height - 15-(i+1)*50);          
      rect(20, height - 10-(i+1)*50, width-20, 1);
      text(numbername, (2*i+1)*float(width) / float(2*10+1)+30, height - 15);
    }
    
}
void visualization2D()
{
    drawgraphinfo();
    
    int nsensor =10;
    
    for (int i = 0; i < 8; i++)
    {
        //float data_reverse = data[i] - baseline[i];
        
        float horizontal_step = float(width) / float(2*nsensor+1);
        float rect_a = (2*i+1)*horizontal_step;
        float rect_b = height - 20;
        float rect_w = horizontal_step;
        float rect_h = (-data_to_draw[i][0]+baseline[i]);
        
        fill(255, 0, 0);
        noStroke();
        rect(rect_a, rect_b, rect_w, rect_h);
        
    }
   //i==8
    float horizontal_step = float(width) / float(2*nsensor+1);
    float rect_a = (2*8+1)*horizontal_step;
    float rect_b = height - 20;
    float rect_w = horizontal_step;
    float rect_h = (-data_to_draw[15][0]+baseline[8]);    
    fill(255, 0, 0);
    noStroke();
    rect(rect_a, rect_b, rect_w, rect_h);
    
    //i==9
    horizontal_step = float(width) / float(2*nsensor+1);
    rect_a = (2*9+1)*horizontal_step;
    rect_b = height - 20;
    rect_w = horizontal_step;
    rect_h = (-data_to_draw[14][0]+baseline[9]);    
    fill(255, 0, 0);
    noStroke();
    rect(rect_a, rect_b, rect_w, rect_h);
}


