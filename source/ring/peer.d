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

    private void doConnect()
    {
        /* Intialize a new socket and connect */
        socket = new Socket(peerAddress.getAdress().addressFamily, SocketType.STREAM, ProtocolType.TCP);
        socket.connect(peerAddress.getAdress());
    }

    public RingPeer getRightHandPeer()
    {
        /* TODO: Send message to this RingPeer asking for his right-hand side peer */
        RingPeer rightHandPeer;



        return rightHandPeer;
    }

    private void worker()
    {

    }
}