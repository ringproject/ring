import std.stdio;
import gogga;
import ring.client;
import std.socket;
import ring.address;

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
	File configFile;
	configFile.open(filename, "rb");
	byte[] data;
	data.length = configFile.size();
	configFile.rawRead(data);
	configFile.close();
	
	RingAddress[] peers;
	
	
	
	
	
	RingClient ringClient = new RingClient(null, getAddress("0.0.0.0", 7777)[0], peers);




}