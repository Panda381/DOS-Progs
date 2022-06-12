
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Main Module                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

///////////////////////////////////////////////////////////////////////////////
// global variables

// application startup
extern HINSTANCE	Instance;			// instance of the application
extern HINSTANCE	PrevInstance;		// previous instance
extern int			ShowMode;			// init show mode

// system version
extern int			OSVersion;			// OS version
extern OSVERSIONINFO OSVersionInfo;		// OS version info

// screen and window size
extern int			ScreenWidth;		// screen client width
extern int			ScreenHeight;		// screen client height

// default system fonts
extern HFONT		FontDefault;		// default GUI font
extern HFONT		FontNormal;			// normal font
extern HFONT		FontBold;			// bold font
extern HFONT		FontFixed;			// fixed font
extern HFONT		FontFixedBold;		// fixed bold font

extern HCURSOR		CurArrow;			// default application cursor (arrow)

// directories
extern CText		ExeFileName;		// EXE file name
extern CText		HomeDir;			// EXE home directory (with ending \)
extern CText		DataDir;			// data directory (without ending \)

// language
extern int			Language;			// current language
#define	LANG_CZ		5					// Czech language
#define	LANG_EN		9					// English language

// help
//extern int			HelpTopic;			// help topic (0=default)

///////////////////////////////////////////////////////////////////////////////
// read configuration number

int ReadIniInt(LPCTSTR group, LPCTSTR key, int def);
int ReadIniInt(LPCTSTR key, int def);

///////////////////////////////////////////////////////////////////////////////
// read configuration bool

BOOL ReadIniBool(LPCTSTR group, LPCTSTR key, BOOL def);
BOOL ReadIniBool(LPCTSTR key, BOOL def);

///////////////////////////////////////////////////////////////////////////////
// read configuration string

CText ReadIniTxt(LPCTSTR group, LPCTSTR key, LPCTSTR def);
CText ReadIniTxt(LPCTSTR key, LPCTSTR def);

///////////////////////////////////////////////////////////////////////////////
// write configuration number

void WriteIniInt(LPCTSTR group, LPCTSTR key, int num);
void WriteIniInt(LPCTSTR key, int num);

///////////////////////////////////////////////////////////////////////////////
// write configuration bool

void WriteIniBool(LPCTSTR group, LPCTSTR key, BOOL val);
void WriteIniBool(LPCTSTR key, BOOL val);

///////////////////////////////////////////////////////////////////////////////
// write configuration string

void WriteIniTxt(LPCTSTR group, LPCTSTR key, CText txt);
void WriteIniTxt(LPCTSTR key, CText txt);

///////////////////////////////////////////////////////////////////////////////
// delete configuration key/group

void WriteIniDelKey(LPCTSTR group, LPCTSTR key);
void WriteIniDelGrp(LPCTSTR group);

///////////////////////////////////////////////////////////////////////////////
// update preview priority menu

void MenuPrevPriorUpdate();

///////////////////////////////////////////////////////////////////////////////
// update preview dimension menu

void MenuPrevDimUpdate();

///////////////////////////////////////////////////////////////////////////////
// reload main menu

void ReloadMainMenu();

///////////////////////////////////////////////////////////////////////////////
// switch language

void SetLanguage(int lang);

///////////////////////////////////////////////////////////////////////////////
// save/load file dialog (returns filename; empty on error or cancel)

CText GetSaveLoadFile(int maskid, LPCTSTR extdef, const CText& filename, CWindow* parent, BOOL save);

///////////////////////////////////////////////////////////////////////////////
// internal error message

void IntError(const CText& txt);

///////////////////////////////////////////////////////////////////////////////
// copy text to clipboard

void TextToClipboard(const CText& txt);

///////////////////////////////////////////////////////////////////////////////
// paste text from clipboard (empty on error)

CText TextFromClipboard();

///////////////////////////////////////////////////////////////////////////////
// check if file exists

BOOL FileExists(LPCTSTR filename);

///////////////////////////////////////////////////////////////////////////////
// open help (0=content)

void HelpHelp(int id);
