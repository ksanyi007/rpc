cmake_minimum_required(VERSION 3.0)
project(rpcbench)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_BUILD_TYPE Release)

add_custom_command(OUTPUT abstractrpcbenchserver.h
                   COMMAND jsonrpcstub spec.json --cpp-server=AbstractRpcbenchServer
                   DEPENDS spec.json
                   COMMENT "Generating Server stub")

add_custom_target(ServerStub DEPENDS abstractrpcbenchserver.h
                  COMMENT "Checking if re-generation of server stub is required")

add_custom_command(OUTPUT rpcbenchclient.h
                   COMMAND jsonrpcstub spec.json --cpp-client=RpcbenchClient
                   DEPENDS spec.json
                   COMMENT "Generating Client stub")

add_custom_target(ClientStub DEPENDS rpcbenchclient.h
                  COMMENT "Checking if re-generation of client stub is required")


add_executable(server server.cc base64.cpp)
add_dependencies(server ServerStub)
add_executable(client client.cc base64.cpp)
add_dependencies(client ClientStub)

find_package(PkgConfig REQUIRED)

pkg_search_module(LIBJSONRPCCPPS REQUIRED libjsonrpccpp-server)
if (LIBJSONRPCCPPS_FOUND)
  include_directories(${LIBJSONRPCCPPS_INCLUDE_DIRS})
  target_link_libraries(server ${LIBJSONRPCCPPS_LIBRARIES})
endif (LIBJSONRPCCPPS_FOUND)

pkg_search_module(LIBJSONRPCCPPC REQUIRED libjsonrpccpp-client)
if (LIBJSONRPCCPPC_FOUND)
  include_directories(${LIBJSONRPCCPPC_INCLUDE_DIRS})
  target_link_libraries(client ${LIBJSONRPCCPPC_LIBRARIES})
endif (LIBJSONRPCCPPC_FOUND)
