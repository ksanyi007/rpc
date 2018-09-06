package com.rpcbench.grpc;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.StatusRuntimeException;

import java.util.logging.Level;
import java.util.logging.Logger;

import com.rpchbench.grpc.DatabaseGrpc;
import com.rpchbench.grpc.Info;
import com.rpchbench.grpc.InfoRequest;

public class RpcbenchClient {
    private static final Logger logger = Logger.getLogger(RpcbenchClient.class.getName());

    private final ManagedChannel channel;
    private final DatabaseGrpc.DatabaseBlockingStub blockingStub;

    /** Construct client connecting to HelloWorld server at {@code host:port}. */
    public RpcbenchClient(String host, int port) {
        channel = ManagedChannelBuilder.forAddress(host, port)
            .usePlaintext(true).build();
        blockingStub = DatabaseGrpc.newBlockingStub(channel);
    }

    public void shutdown() throws InterruptedException {
        channel.shutdownNow();
    }

    public void doRequest(boolean photo, int start, int end) {
        for (int i = start; i <= end; i++) {
            InfoRequest inforeq = InfoRequest.newBuilder()
                .setId(i).setPhoto(photo).build();
            try {
                blockingStub.request(inforeq);
            } catch (StatusRuntimeException e) {
                logger.log(Level.WARNING, "RPC failed: {0}", e.getStatus());
                return;
            }
        }
    }

    public static void main(String[] args) throws Exception {
        RpcbenchClient client = new RpcbenchClient(args[0], 50051);
        try {
            boolean photo = Boolean.parseBoolean(args[1]);
            int start = Integer.parseInt(args[2]);
            int end = Integer.parseInt(args[3]);
            client.doRequest(photo, start, end);
        } finally {
            client.shutdown();
        }
    }
}
