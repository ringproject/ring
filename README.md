# ring
Ring client and daemon

## Protocol

A client, say now **Alice**, connects to **Bob** with an address that looks like this:

```
<key>@<address>
```

Where `<key>` is **Bob's** public key and `<address>` is the IP address and port that goes to **Bob's** ring client.

### Notes

Clock-wise peering