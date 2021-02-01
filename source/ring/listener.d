module ring.listener;

import core.thread;
import std.socket;
import ring.listener;
import gogga;
import ring.client;
import std.conv : to;
import ring.peer;

public final class RingListener : Thread
{
    private Socket listeningPost;
    private RingClient client;

    /**
    * Constructs a new RingListener to accept inbound
    * connections
    *
    * Requires the `address` to bind to and listen on
    * along with the associated RingClient, `client`
    */
    this(Address address, RingClient client)
    {
        super(&listenPost);
        this.client = client;
        initListeningPost(address);
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
            RingPeer remoteClient = new RingPeer(remoteSocket, client);

            /* TODO: Add to connection queue */

            /* Start the connection handler */
            remoteClient.start();
        }
    }
}