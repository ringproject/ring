module ring.client;

import ring.address;
import ring.identity;
import core.thread;
import std.socket;

public final class RingClient : Thread
{
    /**
    * Client details
    */
    private RingIdentity identity;
    private Socket listeningPost;

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
    this(RingIdentity identity, Address listeningAddress, RingAddress[] peers)
    {
        /* Set the worker function */
        super(&worker);

        /* Save details */
        this.identity = identity;
        availablePeers = peers;

        /* Initiate the listeneing post */
        initListeningPost(listeningAddress);
    }

    /**
    * Initialize the listening socket
    */
    private void initListeningPost(Address address)
    {
        /* TODO: Don't forget to catch an exception here */
        listeningPost = new Socket(address.addressFamily, SocketType.STREAM, ProtocolType.TCP);
    }

    /**
    * Main loop
    *
    * Initiate outbound peerings here
    * This should create to RingPeers
    * These two RingPeers will have a main loop too
    * for processing
    * After initiating we then go back here and
    * continue to accept connections to join the ring
    */
    private void worker()
    {

    }
}