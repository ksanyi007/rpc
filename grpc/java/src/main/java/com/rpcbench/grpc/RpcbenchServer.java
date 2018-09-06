package com.rpcbench.grpc;

import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.stub.StreamObserver;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.logging.Logger;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;

import com.google.protobuf.ByteString;
import com.rpchbench.grpc.DatabaseGrpc;
import com.rpchbench.grpc.Info;
import com.rpchbench.grpc.InfoList;
import com.rpchbench.grpc.InfoListRequest;
import com.rpchbench.grpc.InfoRequest;

public class RpcbenchServer {
    private static final Logger logger = Logger.getLogger(RpcbenchServer.class.getName());

    /* The port on which the server should run */
    private int port = 50051;
    private Server server;

    private void start(Db db) throws IOException {
        server = ServerBuilder.forPort(port).addService(new DatabaseImpl(db)).build().start();
        logger.info("Server started, listening on " + port);
        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                // Use stderr here since the logger may have been reset by its JVM shutdown hook.
                System.err.println("*** shutting down gRPC server since JVM is shutting down");
                RpcbenchServer.this.stop();
                System.err.println("*** server shut down");
            }
        });
    }

    private void stop() {
        if (server != null) {
            server.shutdown();
        }
    }

    private void blockUntilShutdown() throws InterruptedException {
        if (server != null) {
            server.awaitTermination();
        }
    }

    public static Db readDb(String dbpath) throws FileNotFoundException, IOException {
        Db db = new Db();

        try (FileReader file = new FileReader(dbpath)) {
            try (BufferedReader buffered = new BufferedReader(file)) {
                for (CSVRecord record : CSVFormat.DEFAULT.withFirstRecordAsHeader().parse(buffered)) {
                    Entry entry = new Entry();
                    entry.setId(Integer.parseInt(record.get("id")));
                    entry.setFirstName(record.get("first_name"));
                    entry.setLastName(record.get("last_name"));
                    entry.setAge(Integer.parseInt(record.get("age")));
                    entry.setEmail(record.get("email"));
                    entry.setPhone(record.get("phone"));
                    entry.setNewsletter(Boolean.parseBoolean(record.get("newsletter")));
                    entry.setLatitude(Float.parseFloat(record.get("latitude")));
                    entry.setLongitude(Float.parseFloat(record.get("longitude")));

                    String configDir = new File(dbpath).getAbsoluteFile().getParent();
                    byte[] bytes = Files.readAllBytes(
                            Paths.get(
                                configDir + "/" +
                                String.format("img%04d.png", entry.getId())));

                    entry.setPhoto(bytes);

                    db.getEntries().put(entry.getId(), entry);
                }
            }
        }

        return db;
    }

    public static void main(String[] args) throws IOException, InterruptedException {
        final RpcbenchServer server = new RpcbenchServer();

        System.out.println("Reading database...");

        Db db = readDb(args[0]);

        System.out.println("Starting server...");

        server.start(db);

        System.out.println("Listening on 50051");

        server.blockUntilShutdown();
    }

    private static class DatabaseImpl extends DatabaseGrpc.DatabaseImplBase {
        private final Db db;

        public DatabaseImpl(Db db) {
            this.db = db;
        }

        @Override
        public void request(InfoRequest request, StreamObserver<Info> responseObserver) {
            int id = request.getId();
            boolean photo = request.getPhoto();

            Entry entry = db.getEntries().get(id);

            Info.Builder builder = Info.newBuilder()
                .setId(entry.getId())
                .setFirstName(entry.getFirstName())
                .setLastName(entry.getLastName())
                .setAge(entry.getAge())
                .setEmail(entry.getEmail())
                .setPhone(entry.getPhone())
                .setNewsletter(entry.getNewsletter())
                .setLatitude(entry.getLatitude())
                .setLongitude(entry.getLongitude());

            if (photo) {
                builder.setPhoto(ByteString.copyFrom(entry.getPhoto()));
            }

            Info info = builder.build();

            responseObserver.onNext(info);
            responseObserver.onCompleted();
        }

        @Override
        public void requestAll(InfoListRequest request, StreamObserver<InfoList> responseObserver) {
            boolean photo = request.getPhoto();

            InfoList.Builder listBuilder = InfoList.newBuilder();

            for (int i = 1; i <= db.getEntries().size(); i++) {
                Entry entry = db.getEntries().get(i);

                Info.Builder infoBuilder = Info.newBuilder()
                    .setId(entry.getId())
                    .setFirstName(entry.getFirstName())
                    .setLastName(entry.getLastName())
                    .setAge(entry.getAge())
                    .setEmail(entry.getEmail())
                    .setPhone(entry.getPhone())
                    .setNewsletter(entry.getNewsletter())
                    .setLatitude(entry.getLatitude())
                    .setLongitude(entry.getLongitude());

                if (photo) {
                    infoBuilder.setPhoto(ByteString.copyFrom(entry.getPhoto()));
                }

                listBuilder.setInfos(i - 1, infoBuilder);
            }

            responseObserver.onNext(listBuilder.build());
            responseObserver.onCompleted();
        }

    }
}
