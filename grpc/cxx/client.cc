#include <iostream>
#include <memory>
#include <string>

#include <grpc++/grpc++.h>

#include "rpcbench.grpc.pb.h"

using std::string;

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;

using rpcbench::Info;
using rpcbench::InfoRequest;
using rpcbench::InfoList;
using rpcbench::InfoListRequest;
using rpcbench::Database;

class RpcbenchClient {
public:
	RpcbenchClient(std::shared_ptr<Channel> channel)
		: stub_(Database::NewStub(channel)) {}

	// Assambles the client's payload, sends it and presents the response back
	// from the server.
	void Request(int id, bool photo) {
		// Data we are sending to the server.
		InfoRequest request;

		request.set_id(id);
		request.set_photo(photo);

		// Container for the data we expect from the server.
		Info reply;

		// Context for the client. It could be used to convey extra information to
		// the server and/or tweak certain RPC behaviors.
		ClientContext context;

		// The actual RPC.
		Status status = stub_->Request(&context, request, &reply);

		// Act upon its status.
		if (!status.ok()) {
			std::cerr << status.error_code() << ": " << status.error_message()
				<< std::endl;
		}
	}

private:
	std::unique_ptr<Database::Stub> stub_;
};

int main(int argc, char** argv) {
	// Instantiate the client. It requires a channel, out of which the actual RPCs
	// are created. This channel models a connection to an endpoint (in this case,
	// localhost at port 50051). We indicate that the channel isn't authenticated
	// (use of InsecureChannelCredentials()).
	RpcbenchClient rpcbench(grpc::CreateChannel(
		string(argv[1]) + ":50051",
		grpc::InsecureChannelCredentials()));

	bool photo = string(argv[2]) == "true";
	int start = std::stoi(string(argv[3]));
	int end = stoi(string(argv[4]));

	for (int i = start; i <= end; i++) {
		rpcbench.Request(i, photo);
	}

	return 0;
}
