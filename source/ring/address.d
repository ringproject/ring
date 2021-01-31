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

    this(string key, Address address)
    {
        this.key = key;
        this.address = address;
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
        return "RingPeer [Key: "~key~", Address: "~address.toString()~"]";
    }
}