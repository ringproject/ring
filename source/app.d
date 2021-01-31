import std.stdio;
import gogga;
import ring.client;
import std.socket;
import ring.address;
import std.json;

void main(string[] args)
{
	gprintln("Welcome to Ring");

	if(args.length >= 2)
	{
		configStart(args[1]);
	}
	else
	{
		configStart("ring.json");
	}
}

private void configStart(string filename)
{
	/* Open the config file, read and parse it */
	File configFile;
	configFile.open(filename, "rb");
	byte[] data;
	data.length = configFile.size();
	configFile.rawRead(data);
	configFile.close();
	JSONValue config = parseJSON(cast(string)data);
	
	/* Read the configuration file */
	RingAddress[] peers;
	
	
	
	
	/* Create the client and start it */
	RingClient ringClient = new RingClient(null, getAddress("0.0.0.0", 7777)[0], peers);

	


}