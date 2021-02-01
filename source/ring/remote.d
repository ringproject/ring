module ring.remote;

import std.socket;
import core.thread;
import bmessage;
import gogga;
import ring.client;
import std.conv : to;

public final class RingRemoteClient : Thread
{
    /**
    * Peer details
    */
    private Socket socket;

    /**
    * Client details
    */
    private RingClient client;

    this(Socket socket, RingClient client)
    {
        /* Set the worker */
        super(&worker);

        this.socket = socket;
        this.client = client;
    }

    private void worker()
    {

        
    }

    /**
    * Processes commands incoming from the listening post
    */
    
}
