import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class Sink implements MessageListener {

  private MoteIF moteIF;
  
  public Sink(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new SerialMsg(), this);
  }

  public int rssiToDbm(int rssi){
      return rssi - 45; //45 might not be correct...
  }


  public void messageReceived(int to, Message message) {
    SerialMsg msg = (SerialMsg)message;
    System.out.println(
        "" + msg.get_counter() + ": id=" + 
        msg.getElement_motes_id(0) + 
        " count=" + msg.getElement_motes_count(0) +
        " rssi=" + msg.getElement_motes_rssi(0));
  }
  
  private static void usage() {
    System.err.println("usage: Sink [-comm <source>]");
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    if (args.length == 2) {
      if (!args[0].equals("-comm")) {
	usage();
	System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }

    MoteIF mif = new MoteIF(phoenix);
    Sink sink = new Sink(mif);
  }


}
