/* DataLogger.pde
 Log data in CSV format
 Copyright (c) 2014-2016 Kitronyx http://www.kitronyx.com
 contact@kitronyx.com
 GPL V3.0
 */
import java.io.BufferedWriter;
import java.io.FileWriter;

class DataLogger
{
  String filename_1d;
    PrintWriter pw_1d = null;
    boolean is_logging = false;
    int log_index = 0;
    final int buffer_size = 10000;
    int data_length = NDRIVE*NSENSE;
    int ts = 0; // ms
    boolean log_frame_interval = true;
    
    void createFileNameBasedOnTime()
    {
        String date = String.format("%04d%02d%02dT%02d%02d%02d", year(), month(), day(), hour(), minute(), second());
        println(date);
        filename_1d = dataPath(date + "-1d.csv");
    }
    
    void startLog(int nrow, int ncol)
    {
        try
        {
            pw_1d = new PrintWriter(new FileWriter(filename_1d, true));
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        finally
        {
            is_logging = true;
            log_index = 0;
            
            // make header for 1d log data
            if (log_frame_interval != true)
                pw_1d.print("Frame Index,");
            else
                pw_1d.print("Frame Interval(ms),");
            
            for (int i = 0; i < 10; i++)
            {
               
                pw_1d.print((i+1)+"Th,");                
            }
        }
    }
    void logData(int[][] d)
    {
        if (is_logging == true)
        {
            if (log_frame_interval == true)
            {
                pw_1d.println(ts + "," + convert2DArrayTo1DString(d));
            }
            else
            {
                pw_1d.println(log_index + "," + convert2DArrayTo1DString(d));
            }
            log_index++;
        }
    }
  
    String convert2DArrayTo1DString(int[][] d)
    {
        String out = "";
        
        for (int i = 0; i < 8; i++){
                out = out + d[i][0] + ",";
                print(d[i][0]+", ");
        }
        out = out + d[15][0] + ",";
        out = out + d[14][0] ;       
        return out;
    }
    void stopLog()
    {
        if (pw_1d != null) {
            pw_1d.flush();
            pw_1d.close();
        }        
        is_logging = false;
    }
    void logFrameInterval()
    {
        log_frame_interval = true;
    }
    
    void logFrameIndex()
    {
        log_frame_interval = false;
    }
    
    void toggleFrameUnit()
    {
        log_frame_interval = !log_frame_interval;
    }
    
    boolean frameUnit()
    {
        return log_frame_interval; 
    }
    
    void setTs(int telapsed)
    {
        ts = telapsed;
    }
}
