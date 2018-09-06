package com.rpcbench.xmlrpc;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Hashtable;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.apache.xmlrpc.WebServer;

public class RpcbenchServer {
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

    public static void main(String[] args) throws FileNotFoundException, IOException {
        System.out.println("Reading database...");
        Db db = readDb(args[0]);

        System.out.println("Starting server...");
        WebServer server = new WebServer(50051);
        server.addHandler("database", new RpcbenchServer(db));
        System.out.println("Listening on 50051");
        server.start();
    }

    private final Db db;

    public RpcbenchServer(Db db) {
        this.db = db;
    }

    public Hashtable<String, Object> request(int id, boolean photo) {
        Entry source = db.getEntries().get(id);
        Hashtable<String, Object> res = new Hashtable<>();
        res.put("id", source.getId());
        res.put("first_name", source.getFirstName());
        res.put("last_name", source.getLastName());
        res.put("age", source.getAge());
        res.put("email", source.getEmail());
        res.put("phone", source.getPhone());
        res.put("newsletter", source.getNewsletter());
        res.put("latitude", source.getLatitude());
        res.put("longitude", source.getLongitude());
        if (photo) {
            res.put("photo", source.getPhoto());
        }
        return res;
    }
}
