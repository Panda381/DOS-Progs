
///////////////////////////////////////////////////////////////////////////////
//
//                             Commad line
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

/*
// command line configuration
int TexW = DEFWH;					// texture width
int TexH = DEFWH;					// texture height
//int Anti = 5;						// antialiasing level 1 or 5
const char* IFile = "filter.ini";	// filter filename (INI format)
const char* OFile = "texture.tga";	// output texture filename (TGA RGB format)
const char* DFile = NULL;			// output diffuse filename (TGA RGB format)
const char* BFile = NULL;			// output bumpmap filename (TGA RGB format)
const char* NFile = NULL;			// output normal filename (TGA RGB format)

// help text
const char HelpText[] =
"Command line arguments (argument separator '-' or '/' can be used):\n"
" i filename ... input filter filename (INI format, default filter.ini)\n"
" w width ...... output texture width (1..32768, default 512)\n"
" h height ..... output texture height (1..32768, default 512)\n"
" a anti ....... antialiasing level 1=off, 5=on (default 5)\n"
" o filename ... output texture filename (TGA RGB format, default texture.tga)\n"
" d filename ... output diffuse filename (TGA RGB format, default \"\"=none)\n"
" b filename ... output bumpmap filename (TGA RGB format, default \"\"=none)\n"
" n filename ... output normal filename (TGA RGB format, default \"\"=none)\n";

// TGA file head
u8 TgaHead[TGAHEADSIZE] = { 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	(u8)DEFWH, (u8)(DEFWH>>8), (u8)DEFWH, (u8)(DEFWH>>8), 24, 0 };

///////////////////////////////////////////////////////////////////////////////
// parse command line (returns false on error)

bool ParseCmd(int argc, char* argv[])
{
	// check number of arguments
	if (argc <= 1)
	{
		printf(HelpText);
		return false;
	}
	argv++;

	// parse arguments
	for (; argc > 1; argc--)
	{
		// get next argument
		char* arg = *argv++;
		if ((*arg == '-') || (*arg == '/')) arg++;

		// get argument command
		char cmd = *arg++;
		if ((cmd >= 'A') && (cmd <= 'Z')) cmd += 'a' - 'A';

		if (*arg != 0)
		{
			printf ("Invalid argument %s\n", argv[-1]);
			printf(HelpText);
			return false;
		}

		if (argc <= 2)
		{
			printf ("Invalid argument of command -%c\n", cmd);
			printf(HelpText);
			return false;
		}
		arg = *argv++;
		argc--;

		// arguments
		switch (cmd)
		{
		// texture width
		case 'w':
			if ((sscanf(arg, "%u", &TexW) != 1) || (TexW < 1) || (TexW > 32768))
			{
				printf ("Invalid width -%c %s\n", cmd, arg);
				printf(HelpText);
				return false;
			}
			TgaHead[12]=(u8)TexW;
			TgaHead[13]=(u8)(TexW>>8);
			break;

		// texture height
		case 'h':
			if ((sscanf(arg, "%u", &TexH) != 1) || (TexH < 1) || (TexH > 32768))
			{
				printf ("Invalid height -%c %s\n", cmd, arg);
				printf(HelpText);
				return false;
			}
			TgaHead[14]=(u8)TexH;
			TgaHead[15]=(u8)(TexH>>8);
			break;

		// antialiasing
		//case 'a':
		//	if ((sscanf(arg, "%u", &Anti) != 1) || ((Anti != 1) && (Anti != 5)))
		//	{
		//		printf ("Unsupported antialiasing -%c %s\n", cmd, arg);
		//		printf(HelpText);
		//		return false;
		//	}
		//	break;

		// input configuration filename
		case 'i':
			IFile = arg;
			break;

		// output picture filename
		case 'o':
			OFile = (*arg == 0) ? NULL : arg;
			break;

		// output diffuse filename
		case 'd':
			DFile = (*arg == 0) ? NULL : arg;
			break;

		// output bump filename
		case 'b':
			BFile = (*arg == 0) ? NULL : arg;
			break;

		// output picture filename
		case 'n':
			NFile = (*arg == 0) ? NULL : arg;
			break;

		// invalid argument
		default:
			printf ("Invalid argument -%c %s\n", cmd, arg);
			printf(HelpText);
			return false;
		}
	}

	// print arguments
	//printf("Options: -w %u -h %u -a %u -i %s", TexW, TexH, Anti, IFile);
	//if (OFile) printf(" -o %s", OFile); else printf(" -o \"\"");
	//if (DFile) printf(" -d %s", DFile); else printf(" -d \"\"");
	//if (BFile) printf(" -b %s", BFile); else printf(" -b \"\"");
	//if (NFile) printf(" -n %s", NFile); else printf(" -n \"\"");
	//printf("\n");

	return true;
}
*/
