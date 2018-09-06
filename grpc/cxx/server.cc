#include <csignal>

#include <libgen.h>

#include <iostream>
#include <fstream>
#include <memory>
#include <string>
#include <map>
#include <unordered_map>

#include <grpc++/grpc++.h>

#define CSV_IO_NO_THREAD
#include "csv.h"

#include "rpcbench.grpc.pb.h"

using std::string;

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::Status;

using rpcbench::Info;
using rpcbench::InfoRequest;
using rpcbench::InfoList;
using rpcbench::InfoListRequest;
using rpcbench::Database;

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

// Logic and data behind the server's behavior.
class DatabaseServiceImpl final : public Database::Service {
private:
	std::shared_ptr<Db> db_;

public:
	DatabaseServiceImpl(std::shared_ptr<Db> db)
		: db_(db) {
	}

	Status Request(ServerContext* context, const InfoRequest* request,
		       Info* reply) override {
		Entry &entry = db_->entries.at(request->id());
		reply->set_id(entry.id);
		reply->set_first_name(entry.first_name);
		reply->set_last_name(entry.last_name);
		reply->set_age(entry.age);
		reply->set_email(entry.email);
		reply->set_phone(entry.phone);
		reply->set_newsletter(entry.newsletter);
		reply->set_latitude(entry.latitude);
		reply->set_longitude(entry.longitude);
		if (request->photo())
			reply->set_photo(entry.photo);
		return Status::OK;
	}

	Status RequestAll(ServerContext* context, const InfoListRequest* request,
		       InfoList* reply) override {
		for (int i = 1; i <= db_->entries.size(); i++) {
			Entry &entry = db_->entries[i];
			Info* info = reply->add_infos();
			info->set_id(entry.id);
			info->set_first_name(entry.first_name);
			info->set_last_name(entry.last_name);
			info->set_age(entry.age);
			info->set_email(entry.email);
			info->set_phone(entry.phone);
			info->set_newsletter(entry.newsletter);
			info->set_latitude(entry.latitude);
			info->set_longitude(entry.longitude);
			if (request->photo())
				info->set_photo(entry.photo);
		}

		return Status::OK;
	}
};

void RunServer(std::shared_ptr<Db> db) {
	std::string server_address("0.0.0.0:50051");
	DatabaseServiceImpl service(db);

	ServerBuilder builder;
	// Listen on the given address without any authentication mechanism.
	builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
	// Register "service" as the instance through which we'll communicate with
	// clients. In this case it corresponds to an *synchronous* service.
	builder.RegisterService(&service);
	// Finally assemble the server.
	std::unique_ptr<Server> server(builder.BuildAndStart());
	std::cout << "Server listening on " << server_address << std::endl;

	// Wait for the server to shutdown. Note that some other thread must be
	// responsible for shutting down the server for this call to ever return.
	server->Wait();
}

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
		std::string content( (std::istreambuf_iterator<char>(ifs) ),
				     (std::istreambuf_iterator<char>()    ) );

		entry.photo = content;
	}

	return std::move(db);
}

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

	RunServer(db);

	return 0;
}
