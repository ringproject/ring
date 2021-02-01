module ring.client;

import ring.address;
import ring.identity;
import ring.peer;
import ring.remote;
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
    private RingRemoteClient[] remoteClients;
    private Mutex remoteClientsLock;
    private RingListener listeningPost;
    private Mutex peeringLock; /* TODO: See if we need this */

    /**
    * Peer info
    */
    private RingPeer left;
    private RingPeer right;

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
        /* Start the listening post (Accept inbound connections (for peering) */
        listeningPost.start();

        /* TODO: Initiate outbound peerings here */
        RingAddress chosenPeer = selectRandomPeer();
        gprintln("Selected peer for connecting to ring network: "~chosenPeer.toString());
        establishLRPeers(chosenPeer);
    }

    /**
    * Given a single node, this will establish our
    * left-hand side and right-hand side nodes
    *
    *
    */
    private void establishLRPeers(RingAddress initialPeer)
    {
        /* Get a working RingPeer (connection) */
        RingPeer selectedPeer = getAvailablePeering();

        while(selectedPeer is null)
        {
            gprintln("No peers were available for a connection, sleeping a little zzz...", DebugType.WARNING);
            Thread.sleep(dur!("seconds")(2));

            selectedPeer = getAvailablePeering();
        }

        gprintln("Selected peer (connect-success): "~selectedPeer.toString());

        /* TODO: Authenticate */
        lockPeering();


        /**
        * If both are empty then L=newPeer and R=newPeer
        *
        * TODO: Check for mutex use if really needed here
        */
        if(left is null && right is null)
        {
            right = selectedPeer.authenticate();
            left = right;

            gprintln("(client.d) Both L=null and R=null case", DebugType.WARNING);
        }
        else
        {
            right = selectedPeer.authenticate();
            gprintln("(client.d) R=null case", DebugType.WARNING);
        }
        

        gprintln("(client.d) State now: "~this.toString());
        unlockPeering();

        
    }

    /**
    * Set the left peer (unsafe, not memory unsafe but it must be locked for algorithmn)
    *
    * a.k.a. use this within `client.lockPeering() <-> (your code) <-> client.unlockPeering()`
    */
    public void setLeft(RingPeer left)
    {
        this.left = left;
    }

    /**
    * Set the right peer (unsafe, not memory unsafe but it must be locked for algorithmn)
    *
    * a.k.a. use this within `client.lockPeering() <-> (your code) <-> client.unlockPeering()`
    */
    public void setRight(RingPeer right)
    {
        this.right = right;
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

    /**
    * Returns a random peer address from the available
    * ones provided
    */
    private RingAddress selectRandomPeer()
    {
        RingAddress chosenPeer;

        // import std.random : dice;
        // dice()

        chosenPeer = availablePeers[0];

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

    public bool unsafe_isPeered()
    {
        /* TODO: Implement me */
        return true;
    }


    public override string toString()
    {
        return "RingClient [L: "~to!(string)(left)~", R: "~to!(string)(right)~"]";
    }
}