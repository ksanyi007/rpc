package com.rpcbench.jsonrpc;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.ArrayList;
import java.util.Base64;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.thetransactioncompany.jsonrpc2.JSONRPC2Request;
import com.thetransactioncompany.jsonrpc2.JSONRPC2Response;
import com.thetransactioncompany.jsonrpc2.client.JSONRPC2Session;

import net.minidev.json.JSONObject;

public class RpcbenchClient {
    private static final Logger logger = Logger.getLogger(RpcbenchClient.class.getName());

    private final JSONRPC2Session client;

    public RpcbenchClient(String url) throws MalformedURLException {
        client = new JSONRPC2Session(new URL(url));
    }

    public void doRequest(boolean photo, int start, int end) {
        for (int i = start; i <= end; i++) {
            try {
                List<Object> params = new ArrayList<>();
                params.add(i);
                params.add(photo);
                JSONRPC2Request req = new JSONRPC2Request("request", params, i);

                JSONRPC2Response res = client.send(req);

                if (res.indicatesSuccess()) {
                    JSONObject json = (JSONObject)res.getResult();
                    if (photo) {
                        String photoEnc = (String) json.get("photo");
                        byte[] photoData = Base64.getDecoder().decode(photoEnc);
                    }
                } else {
                    throw new IllegalArgumentException("RPC fail no success");
                }
            } catch (Exception e) {
                logger.log(Level.WARNING, "RPC failed: {0}", e.getMessage());
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) throws Exception {
        final String url = "http://" + args[0] + ":50051/RPC2";

        RpcbenchClient client = new RpcbenchClient(url);

        boolean photo = Boolean.parseBoolean(args[1]);
        int start = Integer.parseInt(args[2]);
        int end = Integer.parseInt(args[3]);
        client.doRequest(photo, start, end);
    }
}
