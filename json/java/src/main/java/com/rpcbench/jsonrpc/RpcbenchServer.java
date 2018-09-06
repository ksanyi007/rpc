package com.rpcbench.jsonrpc;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;

import com.thetransactioncompany.jsonrpc2.JSONRPC2Error;
import com.thetransactioncompany.jsonrpc2.JSONRPC2ParamsType;
import com.thetransactioncompany.jsonrpc2.JSONRPC2ParseException;
import com.thetransactioncompany.jsonrpc2.JSONRPC2Request;
import com.thetransactioncompany.jsonrpc2.JSONRPC2Response;
import com.thetransactioncompany.jsonrpc2.server.Dispatcher;
import com.thetransactioncompany.jsonrpc2.server.MessageContext;
import com.thetransactioncompany.jsonrpc2.server.RequestHandler;
import com.thetransactioncompany.jsonrpc2.util.PositionalParamsRetriever;

import fi.iki.elonen.NanoHTTPD;
import fi.iki.elonen.NanoHTTPD.Response.Status;

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
        Dispatcher dispatcher = new Dispatcher();
        dispatcher.register(new DatabaseRequestHandler(db));

        RpcApp app = new RpcApp(dispatcher);
        System.out.println("Listening on 50051");
        app.start(NanoHTTPD.SOCKET_READ_TIMEOUT, false);
    }

    public static class RpcApp extends NanoHTTPD {
        private final Dispatcher dispatcher;

        public RpcApp(Dispatcher dispatcher) throws IOException {
            super(50051);
            this.dispatcher = dispatcher;
        }

        @Override
        public Response serve(IHTTPSession session) {
            Map<String, String> m = new HashMap<>();
            try {
                session.parseBody(m);
            } catch (IOException | ResponseException e) {
                e.printStackTrace();
            }

            String str = m.get("postData");
            // Ruby client compat?
            if (str == null) {
                str = (String) session.getParms().keySet().toArray()[0];
            }

            JSONRPC2Request req;
            try {
                req = JSONRPC2Request.parse(str);
            } catch (JSONRPC2ParseException e) {
                e.printStackTrace();
                throw new RuntimeException(e);
            }

            JSONRPC2Response res = dispatcher.process(req, new MessageContext());

            return newFixedLengthResponse(Status.OK, "application/json", res.toString());
        }
    }

    public static class DatabaseRequestHandler implements RequestHandler {
        private final Db db;

        public DatabaseRequestHandler(Db db) {
            this.db = db;
        }

        @Override
        public String[] handledRequests() {
            return new String[] {"request"};
        }

        @Override
        public JSONRPC2Response process(JSONRPC2Request request, MessageContext requestCtx) {
            JSONRPC2ParamsType paramsType = request.getParamsType();
            if (paramsType != JSONRPC2ParamsType.ARRAY) {
                throw new IllegalArgumentException();
            }

            List<Object> params = request.getPositionalParams();
            PositionalParamsRetriever np = new PositionalParamsRetriever(params);

            Integer id;
            Boolean photo;
            try {
                id = np.getInt(0);
                photo = np.getOptBoolean(1, false);
            } catch (JSONRPC2Error e) {
                e.printStackTrace();
                throw new RuntimeException(e);
            }

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
                res.put("photo",
                        Base64.getEncoder().encodeToString(
                            source.getPhoto()
                        ).toString());
            }
            return new JSONRPC2Response(res, request.getID());
        }
    }
}
