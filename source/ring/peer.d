module ring.peer;

import std.socket;
import ring.address;
import bmessage;

public final class RingPeer
{
    /**
    * Peer's connection
    */
    private Socket socket;
    private RingAddress peerAddress;

    this(RingAddress peerAddress)
    {
        this.peerAddress = peerAddress;
    }

    public void doConnect()
    {
        /* Intialize a new socket and connect */
        socket = new Socket(peerAddress.getAdress().addressFamily, SocketType.STREAM, ProtocolType.TCP);
        socket.connect(peerAddress.getAdress());
    }

    public RingPeer getRightHandPeer()
    {
        /* TODO: Send message to this RingPeer asking for his right-hand side peer */
        RingPeer rightHandPeer;

        /* TODO: Receive [nameLen, name] as per README.md */
        // byte[] 
        

        /* TODO: Receive [keyLen, key] as per README.md */



        return rightHandPeer;
    }

    private void worker()
    {

    }
}