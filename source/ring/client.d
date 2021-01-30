module ring.client;

import ring.address;
import ring.identity;

public final class RingClient
{
    /**
    * Client details
    */
    private RingIdentity identity;

    /**
    * Peering info
    */
    private RingAddress[] availablePeers;
    private RingAddress selectedPeer;

    /**
    * Constructs a new RingClient with the
    * given RingIdentity and a list of peers
    * to use for connecting
    */
    this(RingIdentity identity, RingAddress[] peers)
    {
        this.identity = identity;
        availablePeers = peers;
    }
}