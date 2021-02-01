module ring.client;

import ring.address;
import ring.identity;
import ring.peer;
import core.thread;
import std.socket;
import core.sync.mutex;
import gogga;
import std.conv;
import ring.listener;

public final class RingClient : Thread
{
    /**
    * Client details
    */
    private RingIdentity identity;
    private RingPeer[] remoteClients;
    private Mutex remoteClientsLock;
    private RingListener listeningPost;
    private Mutex peeringLock; /* TODO: See if we need this */

    /**
    * Peer info
    */
    public RingPeer left;
    public RingPeer right;
    public bool isConnected;

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

        /* Initialize the mutexes */
        initLocks();

        /* Initiate the listeneing post */
        initListeningPost(listeningAddress);

        /* Start the worker */
        start();
    }

    /**
    * Initialize the mutexex
    */
    private void initLocks()
    {
        peeringLock = new Mutex();
    }

    /**
    * Initialize the listening socket
    */
    private void initListeningPost(Address address)
    {
        /* Create a new listening post here */
        listeningPost = new RingListener(address, this);
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
        /* Start the listening post (Accept inbound connections (for peering)) */
        listeningPost.start();
        

        /* TODO: Try connect to any available peer */
        RingPeer connectedPeer = getOnlineOutboundPeer();
        gprintln("(Outbound-Initiate) Connected to peer @ "~connectedPeer.toString());

        /* Authenticate the peer (outbound) */
        connectedPeer.authenticateOutbound();
    }

    /**
    * This will return a peer to us with a connect socket
    * (so an outbound peer) from the list of available peers
    * provided to us (originally from the configuration file).
    */
    private RingPeer getOnlineOutboundPeer()
    {
        /* Get a working RingPeer (connection) */
        RingPeer chosenPeer = getAvailablePeering();

        while(chosenPeer is null)
        {
            gprintln("No peers were available for a connection, sleeping a little zzz...", DebugType.WARNING);
            Thread.sleep(dur!("seconds")(2));

            chosenPeer = getAvailablePeering();
        }

        return chosenPeer;
    }  

    /**
    * Goes through each peer in availablePeers and attempts to
    * connect to them, cycles to the next if the current peer
    * fails to connect
    *
    * TODO: On failure, total, return null
    */
    private RingPeer getAvailablePeering()
    {
        /* Try connecting to one of the peers, move to next if fail */
        RingPeer chosenPeer;
        foreach(RingAddress ringAddress; availablePeers)
        {
            /* Create a RingPeer */
            RingPeer ringPeer = new RingPeer(ringAddress, identity, this);

            try
            {
                ringPeer.doConnect();
                chosenPeer = ringPeer;
                break;
            }
            catch(SocketOSException e)
            {
                gprintln("Moving to next node, as "~ringPeer.toString()~" failed to connect", DebugType.WARNING);
            }
        }

        return chosenPeer;
    }

    public RingIdentity getIdentity()
    {
        return identity;
    }

    public void lockPeering()
    {
        peeringLock.lock();
    }

    public void unlockPeering()
    {
        peeringLock.unlock();
    }


    public override string toString()
    {
        return "RingClient [L: "~to!(string)(left)~", R: "~to!(string)(right)~"]";
    }
}