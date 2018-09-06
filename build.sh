#!/usr/bin/env bash

(cd ./grpc/java; ./compile-docker)
(cd ./grpc/ruby; ./compile-docker)
(cd ./grpc/cxx; ./compile-docker)

(cd ./xml/java; ./compile-docker)
(cd ./xml/ruby; ./compile-docker)
(cd ./xml/cxx; ./compile-docker)

(cd ./json/java; ./compile-docker)
(cd ./json/ruby; ./compile-docker)
(cd ./json/cxx; ./compile-docker)
