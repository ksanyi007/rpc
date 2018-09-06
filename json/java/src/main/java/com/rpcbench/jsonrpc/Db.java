package com.rpcbench.jsonrpc;

import java.util.HashMap;
import java.util.Map;

public class Db {
    private Map<Integer, Entry> entries = new HashMap<>();

    /**
     * @return the entries
     */
    public Map<Integer, Entry> getEntries() {
        return entries;
    }
}
