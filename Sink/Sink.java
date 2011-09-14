import java.io.BufferedWriter;
import java.io.FileWriter;

/**
 *
 * @author Thomas
 */
import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class Sink implements MessageListener {

  private MoteIF moteIF;

  // Create file
  static FileWriter fstream;
  static BufferedWriter out;

  public Sink(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new AggregateMsg(), this);
  }

  public int rssiToDbm(int rssi){
      return rssi - 45; //45 might not be correct...
  }


  public void messageReceived(int to, Message message) {
    AggregateMsg msg = (AggregateMsg)message;
    System.out.println(
        "From=" + msg.get_from() +
        " msgNr=" + msg.get_counter() +
        " id=" + msg.getElement_motes_id(0) +
        " count=" + msg.getElement_motes_count(0) +
        " rssi=" + msg.getElement_motes_rssi(0));

      try{

  out.append(msg.get_from()+","+msg.get_counter()+","+msg.getElement_motes_id(0)+","+msg.getElement_motes_count(0)+","+
          msg.getElement_motes_rssi(0));
  out.newLine();
  out.flush();
      
 // out.close();
  }catch (Exception e){//Catch exception if any
  System.err.println("Error: " + e.getMessage());
  }
  }

  private static void usage() {
    System.err.println("usage: Sink [-comm <source>]");
  }

  public static void main(String[] args) throws Exception {

            try{
  // Create file
  fstream = new FileWriter("out.txt");
  out = new BufferedWriter(fstream);
      } catch (Exception e){

      }

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
