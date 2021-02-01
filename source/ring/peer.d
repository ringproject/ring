module ring.peer;

import std.socket;
import ring.address;
import bmessage;
import ring.identity;
import gogga;
import ring.client;
import core.thread;

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
        gprintln("Processing: "~to!(string)(payload));

        /* Authentication */
        if(command == 0)
        {
            /* Lock the peering mutex */
            client.lockPeering();

            ubyte nameLen = payload[1];
            string name = cast(string)payload[2..2+nameLen];
            gprintln("(Ingoing) Node wants to authenticate with name "~name);

            /* TODO: Send (our) [nameLen, name] as per README.md */
            byte[] authMessage;
            authMessage ~= [cast(byte)client.getIdentity().getName().length];
            authMessage ~= client.getIdentity().getName();
            sendMessage(socket, authMessage);




            /**
            * If both are empty then L=newPeer and R=newPeer
            *
            * TODO: Check for mutex use if really needed here
            */
            import ring.peer;
            chosenPeer = new RingPeer();
            if(client.left is null && client.right is null)
            {
                client.right = chosenPeer;
                client.left = client.right;

                gprintln("(remote.d) Both L=null and R=null case", DebugType.WARNING);
            }
            else
            {
                client.right = chosenPeer.authenticate();
                gprintln("(remote.d) R=null case", DebugType.WARNING);
            }
            

            gprintln("(remote.d) State now: "~this.toString());




            /* Unlock the peering mutex */
            client.unlockPeering();
        }
    }

    /**
    * Authenticates with the remote peer (outbound)
    */
    public RingPeer authenticateOutbound()
    {
        /* Lock the peering mutex */
        //client.lockPeering();

        /* TODO: Send (our) [nameLen, name] as per README.md (auth-init) */
        byte[] authMessage;
        authMessage ~= [0, cast(byte)identity.getName().length];
        authMessage ~= identity.getName();
        sendMessage(socket, authMessage);

        /* TODO: Receive (their) [nameLen, name] as per README.md */
        byte[] authMessageRemote;
        receiveMessage(socket, authMessageRemote);
        gprintln(authMessageRemote);
        ubyte nameLen = authMessageRemote[0];
        string name = cast(string)authMessageRemote[1..1+nameLen];
        gprintln("(Outgoing) Node replied with name "~name);
        peerName = name;




        /* TODO: Send message to this RingPeer asking for his right-hand side peer */
        RingPeer rightHandPeer;

        
        

        /* TODO: Receive [keyLen, key] as per README.md */

        /* Unlock the peering mutex */
        //client.unlockPeering();

        return rightHandPeer;
    }

    /**
    * Authenticates with the remote peer (inbound)
    */
    public void authenticateInbound()
    {

    }

    private void worker()
    {

    }

    public override string toString()
    {
        return peerAddress.toString();
    }
}