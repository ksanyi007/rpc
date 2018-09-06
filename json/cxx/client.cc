#include <iostream>
#include <string>

#include "base64.h"

#include <jsonrpccpp/client/connectors/httpclient.h>
#include "rpcbenchclient.h"

using std::string;

int main(int argc, char** argv)
{
	const string serverUrl = "http://" + string(argv[1]) + ":50051/RPC2";
	const string methodName = "request";

	bool photo = string(argv[2]) == "true";
	int start = std::stoi(string(argv[3]));
	int end = stoi(string(argv[4]));

	jsonrpc::HttpClient httpclient(serverUrl);
	RpcbenchClient client(httpclient);

	for (int i = start; i <= end; i++) {
		Json::Value res = client.request(i, photo);

		//std::cout << res["first_name"].asString() << std::endl;

		if (photo)
			res["photo"] = base64_decode(res["photo"].asString());
	}

	return 0;
}
