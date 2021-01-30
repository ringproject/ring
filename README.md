# ring
Ring client and daemon

## Protocol

A client, say now **Alice**, connects to **Bob** with an address that looks like this:

````
bob:<key>@<address>
````

or (without the custom name):

```
<key>@<address>
```

Where `<key>` is **Bob's** public key.