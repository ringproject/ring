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
                handlePeerInbound_process(recvPayload);
            }
            /* If not, then stop the listening post */
            else
            {
                gprintln("Client on RingListener has a receive error", DebugType.ERROR);
                break;
            }
        }
    }

    private void handlePeerInbound_process(byte[] payload)
    {
        ubyte command = payload[0];
        gprintln("Processing: " ~ to!(string)(payload));

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

        /* TODO: Send (our) [nameLen, name] as per README.md (auth-init) */
        byte[] authMessage;
        authMessage ~= [0, cast(byte) identity.getName().length];
        authMessage ~= identity.getName();
        sendMessage(socket, authMessage);

        /* TODO: Receive (their) [nameLen, name] as per README.md */
        byte[] authMessageRemote;
        receiveMessage(socket, authMessageRemote);
        gprintln(authMessageRemote);
        ubyte nameLen = authMessageRemote[0];
        string name = cast(string) authMessageRemote[1 .. 1 + nameLen];
        gprintln("(Outgoing) Node replied with name " ~ name);
        peerName = name;

        /* TODO: Receive [keyLen, key] as per README.md */

        /**
        * If both are empty then L=newPeer and R=newPeer
        *
        * TODO: Check for mutex use if really needed here
        */
        if (client.left is null && client.right is null)
        {
            client.right = this;
            client.left = client.right;

            gprintln("(client.d) Both L=null and R=null case", DebugType.WARNING);
        }
        else
        {
            client.right = this;
            gprintln("(client.d) R=null case", DebugType.WARNING);
        }

        gprintln("(client.d) State now: " ~ client.toString());

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

        ubyte nameLen = payload[1];
        string name = cast(string) payload[2 .. 2 + nameLen];
        gprintln("(Ingoing) Node wants to authenticate with name " ~ name);

        /* TODO: Send (our) [nameLen, name] as per README.md */
        byte[] authMessage;
        authMessage ~= [cast(byte) client.getIdentity().getName().length];
        authMessage ~= client.getIdentity().getName();
        sendMessage(socket, authMessage);

        /**
            * If both are empty then L=newPeer and R=newPeer
            *
            * TODO: Check for mutex use if really needed here
            */
        RingPeer chosenPeer = this;
        if (client.left is null && client.right is null)
        {
            client.right = chosenPeer;
            client.left = client.right;

            gprintln("(remote.d) Both L=null and R=null case", DebugType.WARNING);
        }
        else
        {
            client.right = chosenPeer;
            gprintln("(remote.d) R=null case", DebugType.WARNING);
        }

        gprintln("(remote.d) State now: " ~ client.toString());

        /* Unlock the peering mutex */
        client.unlockPeering();
    }

    public override string toString()
    {
        /* If we are an inbound node */
        if(peerAddress is null)
        {
            return socket.toString();
        }
        /* If we are an outbound node */
        else
        {
            return peerAddress.toString();
        }
    }
}
