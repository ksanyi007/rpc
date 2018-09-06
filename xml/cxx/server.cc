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

#include <xmlrpc-c/base.hpp>
#include <xmlrpc-c/registry.hpp>
#include <xmlrpc-c/server_abyss.hpp>

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
	std::vector<unsigned char> photo;
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
		entry.photo = std::vector<unsigned char>(
			(std::istreambuf_iterator<char>(ifs) ),
			(std::istreambuf_iterator<char>()    ) );

	}

	return std::move(db);
}

class databaseRequestMethod : public xmlrpc_c::method2 {
private:
	std::shared_ptr<Db> db_;
public:
	databaseRequestMethod(std::shared_ptr<Db> db)
		: db_(db)
	{}

	virtual void execute(
		xmlrpc_c::paramList const& paramList,
		const xmlrpc_c::callInfo* const callInfoP,
		xmlrpc_c::value* const retval) override
	{
		const int id = paramList.getInt(0);
		const bool photo = paramList.getBoolean(1);
		paramList.verifyEnd(2);

		Entry &entry = db_->entries.at(id);

		std::map<string, xmlrpc_c::value> m;

		m.emplace("id", xmlrpc_c::value_int(entry.id));
		m.emplace("first_name", xmlrpc_c::value_string(entry.first_name));
		m.emplace("last_name", xmlrpc_c::value_string(entry.last_name));
		m.emplace("age", xmlrpc_c::value_int(entry.age));
		m.emplace("email", xmlrpc_c::value_string(entry.email));
		m.emplace("phone", xmlrpc_c::value_string(entry.phone));
		m.emplace("newsletter", xmlrpc_c::value_boolean(entry.newsletter));
		m.emplace("latitude", xmlrpc_c::value_double(entry.latitude));
		m.emplace("longitude", xmlrpc_c::value_double(entry.longitude));
		if (photo)
			m.emplace("photo", xmlrpc_c::value_bytestring(entry.photo));

		xmlrpc_c::value_struct strct(m);

		*retval = strct;
	}
};

int main(int argc, char** argv)
{
	std::cout << "Loading database..." << std::endl;

	std::shared_ptr<Db> db = read_db(argv[1]);

	std::cout << "Starting server..." << std::endl;

	xmlrpc_c::registry reg;

	const xmlrpc_c::methodPtr databaseRequest(
		new databaseRequestMethod(db));

	reg.addMethod("database.request", databaseRequest);

	xmlrpc_c::serverAbyss abyss(
		reg,
		50051,
		"/dev/null"
	);

	std::cout << "Listening on 50051" << std::endl;

	abyss.run();
}
