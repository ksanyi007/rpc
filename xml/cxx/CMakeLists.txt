cmake_minimum_required(VERSION 3.0)
project(rpcbench)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_BUILD_TYPE Release)

add_executable(server server.cc)
add_executable(client client.cc)

find_package(XMLRPC REQUIRED c++2 abyss-server client)
if (XMLRPC_FOUND)
  include_directories(${XMLRPC_INCLUDE_DIRS})
  target_link_libraries(server ${XMLRPC_LIBRARIES})
  target_link_libraries(client ${XMLRPC_LIBRARIES})
else()
  message(FATAL_ERROR "xmlrpc-c required and not found")
endif (XMLRPC_FOUND)
