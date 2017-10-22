import std.getopt, std.stdio, std.file;

enum
    PROJECT_NAME = "ds", /// Project name
    PROJECT_VERSION = "0.0.0"; /// Project version

__gshared bool Base10, cont, raw, sizeonly;

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
            config.bundling, config.caseSensitive,
            "s|size-only", "Give only the size.", &sizeonly,
            config.bundling, config.caseSensitive,
            "r|raw", "Do not format size.", &raw,
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

	foreach (arg; args[1..$]) {
		if (exists(arg)) {
			DirEntry e = DirEntry(arg);
			if (e.isSymlink) {
				if (cont)
					goto FILE;
				writefln("%s\nType: Symlink", arg);
			} else if (e.isDir) {
				writefln("%s\nType: Directory", arg);
			} else {
FILE:
				if (sizeonly) {
					if (raw)
						writefln("%d", e.size);
					else
						writefln("%s", formatsize(e.size));
				} else {
					if (raw)
						writefln("%s\nType: File\nSize: %d", arg, e.size);
					else
						writefln("%s\nType: File\nSize: %s", arg, formatsize(e.size));
					version (Windows)
						writefln("Created: %s", e.timeCreated);
					writefln("Access : %s", e.timeLastAccessed);
					writefln("Modif. : %s", e.timeLastModified);
				}
			}
		} else {
			stderr.writef("\nCould not find entry: %s\n", arg);
			return 1;
		}
	}

    return 0;
}

extern(C) void PrintHelp() {
    printf("Get some file stats.\n");
    printf("  Usage: ds {-b, -c, -s, -r} file\n");
    printf("         ds {-h|--help|-v|--version|/?}\n");
}

extern(C) void PrintVersion() {
    import core.stdc.stdlib : exit;
    printf("ds %s (%s)\n", &PROJECT_VERSION[0], &__TIMESTAMP__[0]);
	printf("Compiled %s with %s v%d\n",
		&__FILE__[0], &__VENDOR__[0], __VERSION__);
    printf("MIT License: Copyright (c) 2017 dd86k\n");
    printf("Project page: <https://github.com/dd86k/ds>\n");
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

	if (Base10) {
		if (size > TiB)
			return format("%0.2f TiB", s / TiB);
		else if (size > GiB)
			return format("%0.2f GiB", s / GiB);
		else if (size > MiB)
			return format("%0.2f MiB", s / MiB);
		else if (size > KiB)
			return format("%0.2f KiB", s / KiB);
		else
			return format("%d B", size);
	} else {
		if (size > TB)
			return format("%0.2f TB", s / TB);
		else if (size > GB)
			return format("%0.2f GB", s / GB);
		else if (size > MB)
			return format("%0.2f MB", s / MB);
		else if (size > KB)
			return format("%0.2f KB", s / KB);
		else
			return format("%d B", size);
	}
}