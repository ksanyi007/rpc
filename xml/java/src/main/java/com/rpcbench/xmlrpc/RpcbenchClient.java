package com.rpcbench.xmlrpc;

import java.io.IOException;
import java.net.MalformedURLException;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.xmlrpc.XmlRpcClient;
import org.apache.xmlrpc.XmlRpcException;

public class RpcbenchClient {
    private static final Logger logger = Logger.getLogger(RpcbenchClient.class.getName());

    private final XmlRpcClient client;

    public void doRequest(boolean photo, int start, int end) throws IOException {
        for (int i = start; i <= end; i++) {
            Vector<Object> params = new Vector<>();
            params.addElement(i);
            params.addElement(photo);
            Object res;
            try {
                res = client.execute("database.request", params);
            } catch (XmlRpcException e) {
                logger.log(Level.WARNING, "RPC failed: {0}", e.getMessage());
                e.printStackTrace();
            }
        }
    }

    public RpcbenchClient(String host) throws MalformedURLException {
        client = new XmlRpcClient(host);
    }

    public static void main(String[] args) throws Exception {
        RpcbenchClient client = new RpcbenchClient("http://" + args[0] + ":50051/RPC2");
        try {
            boolean photo = Boolean.parseBoolean(args[1]);
            int start = Integer.parseInt(args[2]);
            int end = Integer.parseInt(args[3]);
            client.doRequest(photo, start, end);
        } finally {
        }
    }
}
