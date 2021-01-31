import std.stdio;
import gogga;
import ring.client;
import std.socket;
import ring.address;
import std.json;
import std.string;
import std.conv;

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

	try
	{
		JSONValue config = parseJSON(cast(string)data);
		gprintln("Config file is:\n"~config.toPrettyString());

		/* Read the configuration file */

		/* Read the peers */

		RingAddress[] peers = getPeersConfig(config["peers"]);
	
	
	
	
		/* Create the client and start it */
		RingClient ringClient = new RingClient(null, getAddress("0.0.0.0", 7777)[0], peers);
	}
	catch(JSONException e)
	{
		gprintln("Fatal error whilst parsing configurstion file:\n"~e.toString());
	}
}

private RingAddress[] getPeersConfig(JSONValue peerBlock)
{
	/* Read the peers */
	RingAddress[] peers;

	foreach(JSONValue peer; peerBlock.array())
	{
		string[] peerData = split(peer.str(), "@");

		/* SKip the peer if no @ symbol present */
		if(peerData.length == 2)
		{
			string key = peerData[0];
			/* TODO: Catch parsing exception here */
			string[] addressPort = split(peerData[1], ":");
			Address address = parseAddress(addressPort[0]);
			ushort port = to!(ushort)(addressPort[1]);

			/* Create the RingAddress */
			RingAddress ringAddress = new RingAddress(key, address, port);
			gprintln("Adding peer "~to!(string)(ringAddress));
			peers ~= ringAddress;
		}
		else
		{
			gprintln("Invalid peer \""~peer.str()~"\"", DebugType.WARNING);
		}

	}

	return peers;
}