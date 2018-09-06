#!/usr/bin/env bash

REPEATS=3
SERVER="<ip address>"
START=1
END=100

read -rsp $'Start grpc java server\n'
echo grpc-java-java-nopic.log
perf stat -r $REPEATS -o grpc-java-java-nopic.log -d ./run.sh grpc java client $SERVER false $START $END
echo grpc-java-ruby-nopic.log
perf stat -r $REPEATS -o grpc-java-ruby-nopic.log -d ./run.sh grpc ruby client $SERVER false $START $END
echo grpc-java-cxx-nopic.log
perf stat -r $REPEATS -o grpc-java-cxx-nopic.log -d ./run.sh grpc cxx client $SERVER false $START $END

echo grpc-java-java-pic.log
perf stat -r $REPEATS -o grpc-java-java-pic.log -d ./run.sh grpc java client $SERVER true $START $END
echo grpc-java-ruby-pic.log
perf stat -r $REPEATS -o grpc-java-ruby-pic.log -d ./run.sh grpc ruby client $SERVER true $START $END
echo grpc-java-cxx-pic.log
perf stat -r $REPEATS -o grpc-java-cxx-pic.log -d ./run.sh grpc cxx client $SERVER true $START $END

read -rsp $'Start grpc ruby server\n'
echo grpc-ruby-java-nopic.log
perf stat -r $REPEATS -o grpc-ruby-java-nopic.log -d ./run.sh grpc java client $SERVER false $START $END
echo grpc-ruby-ruby-nopic.log
perf stat -r $REPEATS -o grpc-ruby-ruby-nopic.log -d ./run.sh grpc ruby client $SERVER false $START $END
echo grpc-ruby-cxx-nopic.log
perf stat -r $REPEATS -o grpc-ruby-cxx-nopic.log -d ./run.sh grpc cxx client $SERVER false $START $END

echo grpc-ruby-java-pic.log
perf stat -r $REPEATS -o grpc-ruby-java-pic.log -d ./run.sh grpc java client $SERVER true $START $END
echo grpc-ruby-ruby-pic.log
perf stat -r $REPEATS -o grpc-ruby-ruby-pic.log -d ./run.sh grpc ruby client $SERVER true $START $END
echo grpc-ruby-cxx-pic.log
perf stat -r $REPEATS -o grpc-ruby-cxx-pic.log -d ./run.sh grpc cxx client $SERVER true $START $END

read -rsp $'Start grpc cxx server\n'
echo grpc-cxx-java-nopic.log
perf stat -r $REPEATS -o grpc-cxx-java-nopic.log -d ./run.sh grpc java client $SERVER false $START $END
echo grpc-cxx-ruby-nopic.log
perf stat -r $REPEATS -o grpc-cxx-ruby-nopic.log -d ./run.sh grpc ruby client $SERVER false $START $END
echo grpc-cxx-cxx-nopic.log
perf stat -r $REPEATS -o grpc-cxx-cxx-nopic.log -d ./run.sh grpc cxx client $SERVER false $START $END

echo grpc-cxx-java-pic.log
perf stat -r $REPEATS -o grpc-cxx-java-pic.log -d ./run.sh grpc java client $SERVER true $START $END
echo grpc-cxx-ruby-pic.log
perf stat -r $REPEATS -o grpc-cxx-ruby-pic.log -d ./run.sh grpc ruby client $SERVER true $START $END
echo grpc-cxx-cxx-pic.log
perf stat -r $REPEATS -o grpc-cxx-cxx-pic.log -d ./run.sh grpc cxx client $SERVER true $START $END


read -rsp $'Start xmlrpc java server\n'
echo xmlrpc-java-java-nopic.log
perf stat -r $REPEATS -o xmlrpc-java-java-nopic.log -d ./run.sh xmlrpc java client $SERVER false $START $END
echo xmlrpc-java-ruby-nopic.log
perf stat -r $REPEATS -o xmlrpc-java-ruby-nopic.log -d ./run.sh xmlrpc ruby client $SERVER false $START $END
echo xmlrpc-java-cxx-nopic.log
perf stat -r $REPEATS -o xmlrpc-java-cxx-nopic.log -d ./run.sh xmlrpc cxx client $SERVER false $START $END

echo xmlrpc-java-java-pic.log
perf stat -r $REPEATS -o xmlrpc-java-java-pic.log -d ./run.sh xmlrpc java client $SERVER true $START $END
echo xmlrpc-java-ruby-pic.log
perf stat -r $REPEATS -o xmlrpc-java-ruby-pic.log -d ./run.sh xmlrpc ruby client $SERVER true $START $END
echo xmlrpc-java-cxx-pic.log
perf stat -r $REPEATS -o xmlrpc-java-cxx-pic.log -d ./run.sh xmlrpc cxx client $SERVER true $START $END

read -rsp $'Start xmlrpc ruby server\n'
echo xmlrpc-ruby-java-nopic.log
perf stat -r $REPEATS -o xmlrpc-ruby-java-nopic.log -d ./run.sh xmlrpc java client $SERVER false $START $END
echo xmlrpc-ruby-ruby-nopic.log
perf stat -r $REPEATS -o xmlrpc-ruby-ruby-nopic.log -d ./run.sh xmlrpc ruby client $SERVER false $START $END
echo xmlrpc-ruby-cxx-nopic.log
perf stat -r $REPEATS -o xmlrpc-ruby-cxx-nopic.log -d ./run.sh xmlrpc cxx client $SERVER false $START $END

echo xmlrpc-ruby-java-pic.log
perf stat -r $REPEATS -o xmlrpc-ruby-java-pic.log -d ./run.sh xmlrpc java client $SERVER true $START $END
echo xmlrpc-ruby-ruby-pic.log
perf stat -r $REPEATS -o xmlrpc-ruby-ruby-pic.log -d ./run.sh xmlrpc ruby client $SERVER true $START $END
echo xmlrpc-ruby-cxx-pic.log
perf stat -r $REPEATS -o xmlrpc-ruby-cxx-pic.log -d ./run.sh xmlrpc cxx client $SERVER true $START $END

read -rsp $'Start xmlrpc cxx server\n'
echo xmlrpc-cxx-java-nopic.log
perf stat -r $REPEATS -o xmlrpc-cxx-java-nopic.log -d ./run.sh xmlrpc java client $SERVER false $START $END
echo xmlrpc-cxx-ruby-nopic.log
perf stat -r $REPEATS -o xmlrpc-cxx-ruby-nopic.log -d ./run.sh xmlrpc ruby client $SERVER false $START $END
echo xmlrpc-cxx-cxx-nopic.log
perf stat -r $REPEATS -o xmlrpc-cxx-cxx-nopic.log -d ./run.sh xmlrpc cxx client $SERVER false $START $END

echo xmlrpc-cxx-java-pic.log
perf stat -r $REPEATS -o xmlrpc-cxx-java-pic.log -d ./run.sh xmlrpc java client $SERVER true $START $END
echo xmlrpc-cxx-ruby-pic.log
perf stat -r $REPEATS -o xmlrpc-cxx-ruby-pic.log -d ./run.sh xmlrpc ruby client $SERVER true $START $END
echo xmlrpc-cxx-cxx-pic.log
perf stat -r $REPEATS -o xmlrpc-cxx-cxx-pic.log -d ./run.sh xmlrpc cxx client $SERVER true $START $END


read -rsp $'Start jsonrpc java server\n'
echo jsonrpc-java-java-nopic.log
perf stat -r $REPEATS -o jsonrpc-java-java-nopic.log -d ./run.sh jsonrpc java client $SERVER false $START $END
echo jsonrpc-java-ruby-nopic.log
perf stat -r $REPEATS -o jsonrpc-java-ruby-nopic.log -d ./run.sh jsonrpc ruby client $SERVER false $START $END
echo jsonrpc-java-cxx-nopic.log
perf stat -r $REPEATS -o jsonrpc-java-cxx-nopic.log -d ./run.sh jsonrpc cxx client $SERVER false $START $END

echo jsonrpc-java-java-pic.log
perf stat -r $REPEATS -o jsonrpc-java-java-pic.log -d ./run.sh jsonrpc java client $SERVER true $START $END
echo jsonrpc-java-ruby-pic.log
perf stat -r $REPEATS -o jsonrpc-java-ruby-pic.log -d ./run.sh jsonrpc ruby client $SERVER true $START $END
echo jsonrpc-java-cxx-pic.log
perf stat -r $REPEATS -o jsonrpc-java-cxx-pic.log -d ./run.sh jsonrpc cxx client $SERVER true $START $END

read -rsp $'Start jsonrpc ruby server\n'
echo jsonrpc-ruby-java-nopic.log
perf stat -r $REPEATS -o jsonrpc-ruby-java-nopic.log -d ./run.sh jsonrpc java client $SERVER false $START $END
echo jsonrpc-ruby-ruby-nopic.log
perf stat -r $REPEATS -o jsonrpc-ruby-ruby-nopic.log -d ./run.sh jsonrpc ruby client $SERVER false $START $END
echo jsonrpc-ruby-cxx-nopic.log
perf stat -r $REPEATS -o jsonrpc-ruby-cxx-nopic.log -d ./run.sh jsonrpc cxx client $SERVER false $START $END

echo jsonrpc-ruby-java-pic.log
perf stat -r $REPEATS -o jsonrpc-ruby-java-pic.log -d ./run.sh jsonrpc java client $SERVER true $START $END
echo jsonrpc-ruby-ruby-pic.log
perf stat -r $REPEATS -o jsonrpc-ruby-ruby-pic.log -d ./run.sh jsonrpc ruby client $SERVER true $START $END
echo jsonrpc-ruby-cxx-pic.log
perf stat -r $REPEATS -o jsonrpc-ruby-cxx-pic.log -d ./run.sh jsonrpc cxx client $SERVER true $START $END

read -rsp $'Start jsonrpc cxx server\n'
echo jsonrpc-cxx-java-nopic.log
perf stat -r $REPEATS -o jsonrpc-cxx-java-nopic.log -d ./run.sh jsonrpc java client $SERVER false $START $END
echo jsonrpc-cxx-ruby-nopic.log
perf stat -r $REPEATS -o jsonrpc-cxx-ruby-nopic.log -d ./run.sh jsonrpc ruby client $SERVER false $START $END
echo jsonrpc-cxx-cxx-nopic.log
perf stat -r $REPEATS -o jsonrpc-cxx-cxx-nopic.log -d ./run.sh jsonrpc cxx client $SERVER false $START $END

echo jsonrpc-cxx-java-pic.log
perf stat -r $REPEATS -o jsonrpc-cxx-java-pic.log -d ./run.sh jsonrpc java client $SERVER true $START $END
echo jsonrpc-cxx-ruby-pic.log
perf stat -r $REPEATS -o jsonrpc-cxx-ruby-pic.log -d ./run.sh jsonrpc ruby client $SERVER true $START $END
echo jsonrpc-cxx-cxx-pic.log
perf stat -r $REPEATS -o jsonrpc-cxx-cxx-pic.log -d ./run.sh jsonrpc cxx client $SERVER true $START $END
