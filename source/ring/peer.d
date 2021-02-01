module ring.peer;

import std.socket;
import ring.address;
import bmessage;
import ring.identity;
import gogga;

public final class RingPeer
{
    /**
    * My details
    */
    private RingIdentity identity;

    /**
    * Peer's connection
    */
    private Socket socket;
    private RingAddress peerAddress;

    this(RingAddress peerAddress, RingIdentity identity)
    {
        this.peerAddress = peerAddress;
        this.identity = identity;
    }

    public void doConnect()
    {
        /* Intialize a new socket and connect */
        socket = new Socket(peerAddress.getAdress().addressFamily, SocketType.STREAM, ProtocolType.TCP);
        socket.connect(peerAddress.getAdress());  
    }

    public RingPeer authenticate()
    {
        /* TODO: Send (our) [nameLen, name] as per README.md */
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
        gprintln("Node replied with name "~name);




        /* TODO: Send message to this RingPeer asking for his right-hand side peer */
        RingPeer rightHandPeer;

        
        

        /* TODO: Receive [keyLen, key] as per README.md */



        return rightHandPeer;
    }

    private void worker()
    {

    }
}