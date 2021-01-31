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

        while (true)
        {
            /* Block to receive a message */
            byte[] recvPayload;
            bool recvStatus = receiveMessage(socket, recvPayload);

            /* If the receive was successful then process the command */
            if (recvStatus)
            {
                process(recvPayload);
            }
            /* If not, then stop the listening post */
            else
            {
                gprintln("Client on RingListener has a receive error", DebugType.ERROR);
                break;
            }

        }
    }

    /**
    * Processes commands incoming from the listening post
    */
    private void process(byte[] payload)
    {
        ubyte command = payload[0];
        gprintln("Processing: "~to!(string)(payload));

    }
}
