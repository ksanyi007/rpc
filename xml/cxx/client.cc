#include <string>

#include <xmlrpc-c/base.hpp>
#include <xmlrpc-c/client_simple.hpp>

using std::string;

int main(int argc, char** argv)
{
	const string serverUrl = "http://" + string(argv[1]) + ":50051/RPC2";
	const string methodName = "database.request";

	bool photo = string(argv[2]) == "true";
	int start = std::stoi(string(argv[3]));
	int end = std::stoi(string(argv[4]));

	xmlrpc_limit_set(XMLRPC_XML_SIZE_LIMIT_ID, 5 * 1024 * 1024);

	xmlrpc_c::clientSimple client;

	for (int i = start; i <= end; i++) {
		xmlrpc_c::value result;
		client.call(serverUrl, methodName, "ib", &result, i, photo);
	}

	return 0;
}
