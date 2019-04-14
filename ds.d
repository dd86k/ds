import std.getopt, std.stdio, std.file;
import std.format : format;

enum
	PROJECT_NAME = "ds", /// Project name
	PROJECT_VERSION = "0.0.0"; /// Project version

private:

int main(string[] args) {
	if (args.length <= 1) {
		PrintHelp;
		return 0;
	}

	bool cont, base10;

	GetoptResult r = void;
	try {
		r = getopt(args,
			config.bundling, config.caseSensitive,
			"b", "Use decimal metrics instead of binary.", &base10,
			"c", "Continue on soft symlink.", &cont,
			"v|version", "Print version information.", &PrintVersion);
	} catch (GetOptException ex) {
		stderr.writeln("Error: ", ex.msg);
		return 1;
	}

	if (r.helpWanted) {
		PrintHelp;
		writeln("\nOption             Description");
		foreach (it; r.options) { // "custom" defaultGetoptPrinter
			writefln("%4s, %-12s%s",
				it.optShort, it.optLong, it.help);
		}
		return 0;
	}

	foreach (arg; args[1..$]) {
		if (exists(arg) == false) {
			stderr.writef("Could not find entry: %s\n", arg);
			return 1;
		}

		DirEntry e = DirEntry(arg);
		if (e.isSymlink) {
			if (cont) goto FILE;
			writefln("%s\nType: Symlink", arg);
		} else if (e.isDir) {
			writefln("%s\nType: Directory", arg);
		} else {
FILE:
			writefln("%s\nType: File\nSize: %s",
				arg, e.size.formatsize(base10));

			version (Windows)
			writefln(
				"Created: %s\nAccess : %s\nModif. : %s",
				e.timeCreated,
				e.timeLastAccessed,
				e.timeLastModified
			);
			else
			writefln(
				"Access : %s\nModif. : %s",
				e.timeLastAccessed,
				e.timeLastModified
			);
		}
	}

	return 0;
}

void PrintHelp() {
	write(
		"Get some file stats.\n"~
		"  Usage: ds {-b, -c, -s, -r} file\n"~
		"         ds {-h|--help|-v|--version|/?}\n"
	);
}

void PrintVersion() {
	import core.stdc.stdlib : exit;
	writef(
		PROJECT_NAME~" "~PROJECT_VERSION~" ("~__TIMESTAMP__~")\n"~
		"Compiled ds with "~__VENDOR__~" v%u\n"~
		"Project page: <https://github.com/dd86k/ds>\n",
		__VERSION__
	);
	exit(0);
}

string formatsize(const(ulong) size, bool base10 = false) {
	enum : float {
		KB = 1024,
		MB = KB * 1024,
		GB = MB * 1024,
		TB = GB * 1024,
		KiB = 1000,
		MiB = KiB * 1000,
		GiB = MiB * 1000,
		TiB = GiB * 1000
	}
	
	if (base10) goto BASE10;
	
	if (size > GB)
		return format("%.2f GB", size / GB);
	if (size > MB)
		return format("%.2f MB", size / MB);
	if (size > KB)
		return format("%.2f KB", size / KB);
	
	goto BYTE;

BASE10:
	
	if (size > GiB)
		return format("%.2f GiB", size / GiB);
	if (size > MiB)
		return format("%.2f MiB", size / MiB);
	if (size > KiB)
		return format("%.2f KiB", size / KiB);

BYTE:
	return format("%u B", size);
}