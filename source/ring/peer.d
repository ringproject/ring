module ring.peer;

import std.socket;
import ring.address;
import bmessage;
import ring.identity;
import gogga;
import ring.client;
import core.thread;
import std.conv : to;

public final class RingPeer : Thread
{
    /**
    * My details (inbound and outbound)
    */
    private RingIdentity identity;
    private RingClient client;

    /**
    * Peer's connection
    */
    private Socket socket;
    private string peerName;

    /**
    * Peer's connection (outbound)
    */
    private RingAddress peerAddress;

    /**
    * Creates a new RingPeer (outbound)
    */
    this(RingAddress peerAddress, RingIdentity identity, RingClient client)
    {
        this.peerAddress = peerAddress;
        this.identity = identity;
        this.client = client;
    }

    /**
    * Creates a new RingPeer (inbound)
    */
    this(Socket socket, RingClient client)
    {
        super(&handlePeerInbound);
        this.socket = socket;
        this.client = client;
    }

    /**
    * Creates a connection to the remote peer (outbound)
    */
    public void doConnect()
    {
        /* Intialize a new socket and connect */
        socket = new Socket(peerAddress.getAdress().addressFamily, SocketType.STREAM, ProtocolType.TCP);
        socket.connect(peerAddress.getAdress());
        gprintln("(Outbound) Created socket for outbound connection to node @ "~peerAddress.toString());
    }

    /**
    * Handles the connection with the remote peer (inbound)
    */
    private void handlePeerInbound()
    {
        while (true)
        {
            /* Block to receive a message */
            byte[] recvPayload;
            bool recvStatus = receiveMessage(socket, recvPayload);

            /* If the receive was successful then process the command */
            if (recvStatus)
            {
                /* Process the command */
                handlePeerInbound_process(recvPayload);
            }
            /* If not, then stop the listening post */
            else
            {
                gprintln("(Inbound) Receive error occurred, stopping RingPeer", DebugType.ERROR);
                break;
            }
        }
    }

    private void handlePeerInbound_process(byte[] payload)
    {
        ubyte command = payload[0];
        //gprintln("Processing: " ~ to!(string)(payload));

        /* Authentication */
        if (command == 0)
        {
            authenticateInbound(payload);
        }
    }

    /**
    * Authenticates with the remote peer (outbound)
    */
    public void authenticateOutbound()
    {
        /* Lock the peering mutex */
        client.lockPeering();

        /* Check if authenication has already taken place, if so, stop */
        if(client.isConnected)
        {
            gprintln("(Outbound) Already connected, stopping", DebugType.WARNING);
            client.unlockPeering();
            return;
        }
        else
        {
            gprintln("(Outbound) Not connected, attempting...", DebugType.WARNING);
        }

        byte[] authCommand = [0];
        sendMessage(socket, authCommand);
        

        /* Authentication has worked, state it as so */
        client.isConnected = true;


        /* Unlock the peering mutex */
        client.unlockPeering();
    }

    /**
    * Authenticates with the remote peer (inbound)
    */
    public void authenticateInbound(byte[] payload)
    {
        /* Lock the peering mutex */
        client.lockPeering();

        /* Check if authenication has already taken place, if so, stop */
        if(client.isConnected)
        {
            gprintln("(Inbound) Already connected, stopping", DebugType.WARNING);
            client.unlockPeering();
            return;
        }
        else
        {
            gprintln("(Inbound) Not connected, attempting...", DebugType.WARNING);
        }




        /* Authentication has worked, state it as so */
        client.isConnected = true;

        /* Unlock the peering mutex */
        client.unlockPeering();
    }

    public override string toString()
    {
        return "RingPeer ("~peerAddress.toString()~")";
    }
}
