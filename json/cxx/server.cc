#include <csignal>
#include <cstring>

#include <libgen.h>

#include <iostream>
#include <fstream>
#include <memory>
#include <string>
#include <map>
#include <unordered_map>

#define CSV_IO_NO_THREAD
#include "csv.h"

#include "base64.h"

#include <jsonrpccpp/server/connectors/httpserver.h>
#include "abstractrpcbenchserver.h"

using std::string;

struct Entry {
	int id;
	string first_name;
	string last_name;
	int age;
	string email;
	string phone;
	bool newsletter;
	float latitude;
	float longitude;
	string photo;
};

struct Db {
	std::unordered_map<int, Entry> entries;
};

std::unique_ptr<Db> read_db(const string& path)
{
	std::unique_ptr<Db> db = std::make_unique<Db>();

	io::CSVReader<9> in(path);
	in.read_header(io::ignore_extra_column,
		       "id",
		       "first_name",
		       "last_name",
		       "age",
		       "email",
		       "phone",
		       "newsletter",
		       "latitude",
		       "longitude");

	for (int i = 1; i <= 1000; i++) {
		Entry &entry = db->entries[i];
		string newsletter;
		in.read_row(entry.id,
			    entry.first_name,
			    entry.last_name,
			    entry.age,
			    entry.email,
			    entry.phone,
			    newsletter,
			    entry.latitude,
			    entry.longitude);

		entry.newsletter = newsletter == "true";

		string dir;
		{
			char *cfpath = strdup(path.c_str());
			char *cdir = dirname(cfpath);
			dir = string(cdir);
			free(cfpath);
			cfpath = nullptr;
			cdir = nullptr;
		}

		string filename;
		{
			char *cfilename;
			asprintf(&cfilename, "img%04d.png", entry.id);
			filename = string(cfilename);
			free(cfilename);
			cfilename = nullptr;
		}

		string photoFileName = "";
		photoFileName += dir;
		photoFileName += "/";
		photoFileName += filename;

		std::ifstream ifs(photoFileName);
		entry.photo = string(
			(std::istreambuf_iterator<char>(ifs) ),
			(std::istreambuf_iterator<char>()    ) );

	}

	return db;
}

class RpcbenchServer : public AbstractRpcbenchServer {
private:
	std::shared_ptr<Db> db_;
public:
	RpcbenchServer(std::shared_ptr<Db> db, jsonrpc::AbstractServerConnector& connector)
		: AbstractRpcbenchServer(connector), db_(db)
	{
	}

        virtual Json::Value request(int id, bool photo) override
	{
		Json::Value root;

		Entry &entry = db_->entries.at(id);

		root["id"] = entry.id;
		root["first_name"] = entry.first_name;
		root["last_name"] = entry.last_name;
		root["age"] = entry.age;
		root["email"] = entry.email;
		root["phone"] = entry.phone;
		root["newsletter"] = entry.newsletter;
		root["latitude"] = entry.latitude;
		root["longitude"] = entry.longitude;
		if (photo)
			root["photo"] = base64_encode((unsigned const char*) entry.photo.c_str(), entry.photo.size());

		return root;
	}
};

void int_handler(int x)
{
	exit(0);
}

int main(int argc, char** argv)
{
	signal(SIGINT, int_handler);

	std::cout << "Loading database..." << std::endl;

	std::shared_ptr<Db> db = read_db(argv[1]);

	std::cout << "Starting server..." << std::endl;

	jsonrpc::HttpServer httpServer(50051);
	RpcbenchServer server(db, httpServer);

	std::cout << "Listening on 50051" << std::endl;
	server.StartListening();

	for(;;) pause();

	return 0;
}
