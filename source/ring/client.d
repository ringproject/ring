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

public final class RingClient : Thread
{
    /**
    * Client details
    */
    private RingIdentity identity;
    private Socket listeningPost;
    private RingRemoteClient[] remoteClients;
    private Mutex remoteClientsLock;

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

        /* Initiate the listeneing post */
        initListeningPost(listeningAddress);

        /* Start the worker */
        start();
    }

    /**
    * Initialize the listening socket
    */
    private void initListeningPost(Address address)
    {
        /* TODO: Don't forget to catch an exception here */
        listeningPost = new Socket(address.addressFamily, SocketType.STREAM, ProtocolType.TCP);
        listeningPost.bind(address);
        listeningPost.listen(0);
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
        /* TODO: Initiate outbound peerings here */
        RingAddress chosenPeer = selectRandomPeer();
        gprintln("Selected peer for connecting to ring network: "~chosenPeer.toString());
        establishLRPeers(chosenPeer);


        /* Accept inbound connections (for peering) */
        listenPost();
    }

    /**
    * Here we listen for incoming connections to our node
    */
    private void listenPost()
    {
        while(true)
        {
            /* Block to dequeue a connection */
            Socket remoteSocket = listeningPost.accept();
            gprintln("ListeningPost: New connection "~to!(string)(remoteSocket));

            /* Create a new connection handler */
            RingRemoteClient remoteClient = new RingRemoteClient(remoteSocket, this);

            /* TODO: Add to connection queue */

            /* Start the connection handler */
            remoteClient.start();
        }
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
        gprintln("Selected peer (connect-success): "~selectedPeer.toString());

        /* TODO: Get right hand peer */
        RingPeer rightHand = selectedPeer.getRightHandPeer();
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
        RingPeer ringPeer;
        foreach(RingAddress ringAddress; availablePeers)
        {
            /* Create a RingPeer */
            ringPeer = new RingPeer(ringAddress);

            try
            {
                ringPeer.doConnect();
                break;
            }
            catch(SocketOSException e)
            {

            }
        }

        return ringPeer;
    }

    /**
    * Returns a random peer address from the available
    * ones provided
    */
    private RingAddress selectRandomPeer()
    {
        RingAddress selectedPeer;

        // import std.random : dice;
        // dice()

        selectedPeer = availablePeers[0];

        return selectedPeer;
    }
}