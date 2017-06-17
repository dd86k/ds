import std.getopt, std.stdio, std.file;

enum
    PROJECT_NAME = "ds",
    PROJECT_VERSION = "0.0.0";

bool Base10, cont;

private int main(string[] args)
{
    if (args.length == 1) {
        PrintHelp;
        return 0;
    }

    GetoptResult r;
	try {
		r = getopt(args,
            config.bundling, config.caseSensitive,
            "b|base10", "Use decimal metrics instead of binary.", &Base10,
            config.bundling, config.caseSensitive,
            "c|continue", "Continue on soft symlink.", &cont,
            config.caseSensitive,
            "v|version", "Print version information.", &PrintVersion);
	} catch (GetOptException ex) {
		stderr.writeln("Error: ", ex.msg);
        return 1;
	}
    
    if (r.helpWanted) {
        PrintHelp;
        writeln("\nOption             Description");
        foreach (it; r.options) { // "custom" defaultGetoptPrinter
            writefln("%*s, %-*s%s%s",
                4,  it.optShort,
                12, it.optLong,
                it.required ? "Required: " : " ",
                it.help);
        }
        return 0;
	}
    
    string f = args[$ - 1];
    if (exists(f)) {
        const DirEntry e = DirEntry(f);
        if (e.isSymlink) {
            if (cont)
                goto FILE;
            writefln("%s\nSymlink", f);
        } else if (e.isDir) {
            writefln("%s\nDirectory", f);
        } else {
FILE:
            writefln("%s\nSize: %s", f, formatsize(e.size));
            version (Windows)
                writefln("Created: %s", e.timeCreated);
            writefln("Access : %s", e.timeLastAccessed);
            writefln("Modif. : %s", e.timeLastModified);
        }
    } else {
        writefln("Could not find entry: %s", f);
        return 1;
    }

    return 0;
}

void PrintHelp()
{
    writeln("Get file stats.");
    writefln("  Usage: %s [<Options>] <File>", PROJECT_NAME);
    writefln("         %s {-h|--help|-v|--version|/?}", PROJECT_NAME);
}

void PrintVersion() {
    import core.stdc.stdlib : exit;
    writefln("%s %s (%s)", PROJECT_NAME, PROJECT_VERSION, __TIMESTAMP__);
debug writefln("Compiled %s with %s v%s", __FILE__, __VENDOR__, __VERSION__);
    writeln("MIT License: Copyright (c) 2016-2017 dd86k");
    writeln("Project page: <https://github.com/dd86k/ds>");
    exit(0);
}

string formatsize(long size) //BUG: %f is unpure?
{
    import std.format : format;

    enum : long {
        KB = 1024,
        MB = KB * 1024,
        GB = MB * 1024,
        TB = GB * 1024,
        KiB = 1000,
        MiB = KiB * 1000,
        GiB = MiB * 1000,
        TiB = GiB * 1000
    }

	const float s = size;

	if (Base10)
	{
		if (size > TiB)
			if (size > 100 * TiB)
				return format("%d TiB", size / TiB);
			else if (size > 10 * TiB)
				return format("%0.1f TiB", s / TiB);
			else
				return format("%0.2f TiB", s / TiB);
		else if (size > GiB)
			if (size > 100 * GiB)
				return format("%d GiB", size / GiB);
			else if (size > 10 * GiB)
				return format("%0.1f GiB", s / GiB);
			else
				return format("%0.2f GiB", s / GiB);
		else if (size > MiB)
			if (size > 100 * MiB)
				return format("%d MiB", size / MiB);
			else if (size > 10 * MiB)
				return format("%0.1f MiB", s / MiB);
			else
				return format("%0.2f MiB", s / MiB);
		else if (size > KiB)
			if (size > 100 * MiB)
				return format("%d KiB", size / KiB);
			else if (size > 10 * KiB)
				return format("%0.1f KiB", s / KiB);
			else
				return format("%0.2f KiB", s / KiB);
		else
			return format("%d B", size);
	}
	else
	{
		if (size > TB)
			if (size > 100 * TB)
				return format("%d TB", size / TB);
			else if (size > 10 * TB)
				return format("%0.1f TB", s / TB);
			else
				return format("%0.2f TB", s / TB);
		else if (size > GB)
			if (size > 100 * GB)
				return format("%d GB", size / GB);
			else if (size > 10 * GB)
				return format("%0.1f GB", s / GB);
			else
				return format("%0.2f GB", s / GB);
		else if (size > MB)
			if (size > 100 * MB)
				return format("%d MB", size / MB);
			else if (size > 10 * MB)
				return format("%0.1f MB", s / MB);
			else
				return format("%0.2f MB", s / MB);
		else if (size > KB)
			if (size > 100 * KB)
				return format("%d KB", size / KB);
			else if (size > 10 * KB)
				return format("%0.1f KB", s / KB);
			else
				return format("%0.2f KB", s / KB);
		else
			return format("%d B", size);
	}
}