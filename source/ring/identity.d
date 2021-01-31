module ring.identity;

public final class RingIdentity
{
    /**
    * Cryptographic requirements
    */
    private string publicKey;
    private string privateKey;

    /**
    * Name
    */
    private string name;

    /**
    * Constructs a new identity with the given keys
    * and name (which will be sent to peers for identification)
    */
    this(string publicKey, string privateKey, string name)
    {
        this.publicKey = publicKey;
        this.privateKey = privateKey;
        this.name = name;
    }

    public string getName()
    {
        return name;
    }

    public override string toString()
    {
        return "RingIdentity [Name: "~name~", PublicKey: "~publicKey~", PrivateKey: (hidden)]";
    }
}