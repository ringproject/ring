module ring.address;

import std.socket : Address;
import std.conv : to;

public final class RingAddress
{
    /**
    * Peer details
    */
    private string key;
    private Address address;
    private ushort port;

    this(string key, Address address, ushort port)
    {
        this.key = key;
        this.address = address;
        this.port = port;
    }

    public string getKey()
    {
        return key;
    }

    public Address getAdress()
    {
        return address;
    }

    public override string toString()
    {
        return "RingPeer [Key: "~key~", Address: "~address.toString()~", Port: "~to!(string)(port)~"]";
    }
}