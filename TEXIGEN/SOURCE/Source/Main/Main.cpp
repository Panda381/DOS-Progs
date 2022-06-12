
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Main Module                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// global variables

// application startup
HINSTANCE	Instance;					// instance of the application
HINSTANCE	PrevInstance;				// previous instance
int			ShowMode;					// init show mode

// system version
int			OSVersion;					// OS version
OSVERSIONINFO OSVersionInfo;			// OS version info

// screen size
int			ScreenWidth;				// screen client width
int			ScreenHeight;				// screen client height

// default system fonts
HFONT		FontDefault = NULL;			// default GUI font
HFONT		FontNormal = NULL;			// normal font
HFONT		FontBold = NULL;			// bold font
HFONT		FontFixed = NULL;			// fixed font
HFONT		FontFixedBold = NULL;		// fixed bold font

HCURSOR		CurArrow = NULL;			// default application cursor (arrow)

// accelerator table
HACCEL		Accel = NULL;				// accelerator table

// directories
CText		ExeFileName;				// EXE file name
CText		HomeDir;					// EXE home directory (with ending \)
CText		DataDir;					// data directory (without ending \)

// configuration
CText		IniFile(_T(".\\TexiGen.ini")); // configuration file

#define INIBUFSIZE 5000
TCHAR		IniBuf[INIBUFSIZE];			// ini string input buffer
CText		MainIniGroup(_T("Main"));	// main ini group

// language
int			Language = LANG_EN;			// current language

// preview priority menu ID
const int MenuPrevPriorID[] = { ID_PREV_STOP, ID_PREV_IDLE, ID_PREV_LOWEST,
	ID_PREV_VERYLOW, ID_PREV_LOW, ID_PREV_LOWER, ID_PREV_NORMAL };

// preview dimension menu ID
const int MenuPrevDimID[] = { ID_PREV_DIM0, ID_PREV_DIM1, ID_PREV_DIM2, ID_PREV_DIM3,
	ID_PREV_DIM4, ID_PREV_DIM5, ID_PREV_DIM6, ID_PREV_DIM7, ID_PREV_DIM8, ID_PREV_DIM9 };

const int MenuPrevDimID2[] = { ID_PREV_DIM20, ID_PREV_DIM21, ID_PREV_DIM22, ID_PREV_DIM23 };

// help
//int			HelpTopic = 0;			// help topic (0=default)

///////////////////////////////////////////////////////////////////////////////
// read configuration number

int ReadIniInt(LPCTSTR group, LPCTSTR key, int def)
{
	return ::GetPrivateProfileInt(group, key, def, IniFile);
}

int ReadIniInt(LPCTSTR key, int def)
{
	return ReadIniInt(MainIniGroup, key, def);
}

///////////////////////////////////////////////////////////////////////////////
// read configuration bool

BOOL ReadIniBool(LPCTSTR group, LPCTSTR key, BOOL def)
{
	return (ReadIniInt(group, key, def) != FALSE);
}

BOOL ReadIniBool(LPCTSTR key, BOOL def)
{
	return ReadIniBool(MainIniGroup, key, def);
}

///////////////////////////////////////////////////////////////////////////////
// read configuration string

CText ReadIniTxt(LPCTSTR group, LPCTSTR key, LPCTSTR def)
{
	int n = ::GetPrivateProfileString(group, key, def, IniBuf, INIBUFSIZE, IniFile);
	CText txt(IniBuf, n);
	return txt;
}

CText ReadIniTxt(LPCTSTR key, LPCTSTR def)
{
	return ReadIniTxt(MainIniGroup, key, def);
}

///////////////////////////////////////////////////////////////////////////////
// write configuration number

void WriteIniInt(LPCTSTR group, LPCTSTR key, int num)
{
	CText txt;
	txt.SetInt(num);
	::WritePrivateProfileString(group, key, txt, IniFile);
}

void WriteIniInt(LPCTSTR key, int num)
{
	WriteIniInt(MainIniGroup, key, num);
}

///////////////////////////////////////////////////////////////////////////////
// write configuration bool

void WriteIniBool(LPCTSTR group, LPCTSTR key, BOOL val)
{
	WriteIniInt(group, key, val != FALSE);
}

void WriteIniBool(LPCTSTR key, BOOL val)
{
	WriteIniBool(MainIniGroup, key, val);
}

///////////////////////////////////////////////////////////////////////////////
// write configuration string

void WriteIniTxt(LPCTSTR group, LPCTSTR key, CText txt)
{
	txt = CText('"') + txt + CText('"');
	::WritePrivateProfileString(group, key, txt, IniFile);
}

void WriteIniTxt(LPCTSTR key, CText txt)
{
	WriteIniTxt(MainIniGroup, key, txt);
}

///////////////////////////////////////////////////////////////////////////////
// delete configuration key

void WriteIniDelKey(LPCTSTR group, LPCTSTR key)
{
	::WritePrivateProfileString(group, key, NULL, IniFile);
}
///////////////////////////////////////////////////////////////////////////////
// delete configuration group

void WriteIniDelGrp(LPCTSTR group)
{
	::WritePrivateProfileString(group, NULL, NULL, IniFile);
}

///////////////////////////////////////////////////////////////////////////////
// language correction

int CorigLanguage(int lang)
{
	int n = lang & 0x3FF;
	switch (n)
	{
	case LANG_CZ:
	case LANG_EN:
		break;

	default:
		n = LANG_EN;
	}
	return n;
}

///////////////////////////////////////////////////////////////////////////////
// set system language

typedef LANGID (WINAPI *FP_SetThreadUILanguage)(LANGID LangId);

void SetLanguage0(int lang)
{
	Language = CorigLanguage(lang);

	HMODULE hKernel32 = ::GetModuleHandle(_T("Kernel32.dll"));
	if (hKernel32)
	{
		FARPROC pFn = ::GetProcAddress(hKernel32, "SetThreadUILanguage");
		if (pFn)
		{
			FP_SetThreadUILanguage pSetThreadUILanguage = (FP_SetThreadUILanguage)pFn;
			pSetThreadUILanguage((LANGID)(Language | 0x400));
		}
		::FreeLibrary(hKernel32);
	}

	::SetThreadLocale(Language | 0x400);
}

///////////////////////////////////////////////////////////////////////////////
// update preview priority menu

void MenuPrevPriorUpdate()
{
	int i;
	for (i = 0; i <= CPUPRIOR_NUM; i++) CheckCmd(MenuPrevPriorID[i], i == PreviewPriority);
}
		
///////////////////////////////////////////////////////////////////////////////
// update preview dimension menu

void MenuPrevDimUpdate()
{
	int i;
	if (SelectMode)
		for (i = 0; i < PREVDIMN; i++) CheckCmd(MenuPrevDimID[i], i == PrevDim);
	else
		for (i = 0; i < PREVDIMN2; i++) CheckCmd(MenuPrevDimID2[i], i == PrevDim2);
}
		
///////////////////////////////////////////////////////////////////////////////
// reload main menu

void ReloadMainMenu()
{
	HMENU menu = ::LoadMenu(Instance, MAKEINTRESOURCE(SelectMode ? IDM_SELECT : IDM_EDIT));
	::SetMenu(MainFrame->Handle(), menu);
	::DestroyMenu(MainMenu);
	MainMenu = menu;
	MenuPrevPriorUpdate();
	MenuPrevDimUpdate();
	//CheckCmd(ID_MARK_VAR, MarkVar);
}

///////////////////////////////////////////////////////////////////////////////
// switch language

void SetLanguage(int lang)
{
	// set language
	SetLanguage0(lang);
	WriteIniInt(_T("Language"), Language);

	// reload main menu
	ReloadMainMenu();

	// update mainframe caption
	SetCaption();

	// update selection texts
	UpdateSelectText();

	// update edit texts
	UpdateEditText();
}

///////////////////////////////////////////////////////////////////////////////
// read configuration

void ReadIni()
{
	// selected language
	Language = CorigLanguage(ReadIniInt("Language", Language));

	// main frame position
	MainFrameWidth = ScreenWidth*7/8;
	MainFrameHeight = ScreenHeight*7/8;
	MainFrameLeft = (ScreenWidth - MainFrameWidth)/2;
	MainFrameTop = (ScreenHeight - MainFrameHeight)/2;
	MainFrameWidth = ReadIniInt("MainFrameWidth", MainFrameWidth);
	MainFrameHeight = ReadIniInt("MainFrameHeight", MainFrameHeight);
	MainFrameLeft = ReadIniInt("MainFrameLeft", MainFrameLeft);
	MainFrameTop = ReadIniInt("MainFrameTop", MainFrameTop);
	MainFrameMax = ReadIniBool("MainFrameMax", MainFrameMax);

	// selected group and filter
	GroupList.SetSelName(ReadIniTxt("Group", EmptyText));
	GraphList.SetSelName(ReadIniTxt("Graph", EmptyText));
	VarList.SetSelName(ReadIniTxt("Variation", EmptyText));

	// zoom
	//Zoom = ReadIniInt("Zoom", Zoom);
	//if (Zoom < 0) Zoom = 0;
	//if (Zoom >= ZOOMNUM) Zoom = ZOOMNUM-1;
	//UpdateZoom();

	// mark variants
	//MarkVar = ReadIniBool("MarkVar", MarkVar);

	// output
	OutFilterInx = ReadIniInt("Output", OutFilterInx);
	Tiles = ReadIniBool("Tiles", Tiles);
	//Lock = ReadIniBool("Lock", Lock);

	// selected group of filters template
	GroupFSel = ReadIniInt("GroupSel", GroupFSel);
	if ((DWORD)GroupFSel > (DWORD)FGRP_NUM) GroupFSel = 0;

	// preview priority
	PreviewPriority = ReadIniInt("PreviewPriority", PreviewPriority);
	if (PreviewPriority < 0) PreviewPriority = 0;
	if (PreviewPriority > CPUPRIOR_NUM) PreviewPriority = CPUPRIOR_NUM;

	// preview dimension
	PrevDim = ReadIniInt("PreviewDimension", PrevDim);
	if (PrevDim < 0) PrevDim = 0;
	if (PrevDim >= PREVDIMN) PrevDim = PREVDIMN-1;

	PrevDim2 = ReadIniInt("PreviewDimension2", PrevDim2);
	if (PrevDim2 < 0) PrevDim2 = 0;
	if (PrevDim2 >= PREVDIMN2) PrevDim2 = PREVDIMN2-1;

	// load render configuration
	LoadRenderIni();
}

///////////////////////////////////////////////////////////////////////////////
// program entry point

int APIENTRY _tWinMain(HINSTANCE inst, HINSTANCE prev, LPTSTR cmd, int show)
{
	// save instance handle
	Instance = inst;
	PrevInstance = prev;
	ShowMode = show;

	// get system version
	OSVersion = (int)::GetVersion();
	OSVersionInfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
	::GetVersionEx(&OSVersionInfo);

	// map font table
	FontTabMap();

	// initialize random generator
	srand(::GetTickCount());

	// generate Gauss blur weights
	GenGaussWeight();

	// initialize shapes
	HeartInit();
	SpadeInit();
	DropletInit();

	// get screen size
	ScreenWidth = ::GetSystemMetrics(SM_CXSCREEN);
	ScreenHeight = ::GetSystemMetrics(SM_CYSCREEN);

	// load system fonts
	FontDefault = (HFONT)::GetStockObject(DEFAULT_GUI_FONT);
	FontNormal = (HFONT)::GetStockObject(ANSI_VAR_FONT);
	FontBold = (HFONT)::GetStockObject(SYSTEM_FONT);
	FontFixed = (HFONT)::GetStockObject(ANSI_FIXED_FONT);
	FontFixedBold = (HFONT)::GetStockObject(SYSTEM_FIXED_FONT);

	// load default application cursor
	CurArrow = ::LoadCursor(NULL, MAKEINTRESOURCE(IDC_ARROW));

	// get default current language
	Language = CorigLanguage(::GetThreadLocale());

	// directories
	DataDir.GetCurrentDir();
	DataDir.DelBackSlash();
	TCHAR buf[512];
	buf[0] = 0;
	::GetModuleFileName(Instance, buf, 512);
	ExeFileName = buf;
	HomeDir = ExeFileName.ExtractPath();
	if (HomeDir.IsEmpty()) HomeDir = DataDir;
	HomeDir.AddBackSlash();

	// load accelerator table
	Accel = ::LoadAccelerators(Instance, (LPCTSTR)IDA_MAIN);

	// initialize common controls
	::InitCommonControls();
	INITCOMMONCONTROLSEX ic;
	ic.dwSize = sizeof(INITCOMMONCONTROLSEX);
	ic.dwICC = ICC_WIN95_CLASSES | ICC_DATE_CLASSES | ICC_INTERNET_CLASSES;
	InitCommonControlsEx(&ic); 

	// unlock select locks
	memset(InFilterLock, 0, INMAX*sizeof(BOOL));

	// load environment pictures
	LoadEnvPic();

	// load card pictures
	LoadCardPic();

	// load dollar pictures
	LoadDollarPic();

	// fill up filter template list
	TempFillUp();

	// read configuration
	ReadIni();

	// create main frame
	MainFrame = new CMainFrame;
	if (!MainFrameCreate()) return 255;
	SetStatusOn(TRUE);

	// create selection screen
	CreateSelect();

	// set language
	SetLanguage(Language);

	// start render thread
	if (!RenderInit()) return 253;

	// message loop
	MSG msg;
	BOOL noaccel;
	while (::GetMessage(&msg, NULL, 0, 0))
	{
		noaccel = FALSE;

		switch (msg.message)
		{
			case WM_KEYDOWN:
				{
					if (msg.wParam == VK_TAB)
					{
						CWindow* win2 = WinHList.Find(::GetFocus());
						if (win2 != NULL)
						{
							CWindow* owner = win2->Owner();

							BOOL back = (::GetAsyncKeyState(VK_SHIFT) < 0);

							CWindow* win3 = win2;
							if (back)
							{
								CWindow* win4 = NULL;
								for (;;)
								{
									win3 = win3->NextTreeEntry();
									if (win3 == win2) break;
									if (win3->CanFocus() && (win3->Enabled() ||
										(win3->Type() == WINTYPE_EDIT) || (win3->Type() == WINTYPE_RICHEDIT)) &&
										win3->Visible() && (win3->Owner() == owner))
									{
										win4 = win3;
									}
								}
								if (win4 != NULL) win4->SetFocus();
							}
							else
							{
								for (;;)
								{
									win3 = win3->NextTreeEntry();
									if (win3 == win2) break;
									if (win3->CanFocus() && (win3->Enabled() ||
										(win3->Type() == WINTYPE_EDIT) || (win3->Type() == WINTYPE_RICHEDIT)) &&
										win3->Visible() && (win3->Owner() == owner))
									{
										win3->SetFocus();
										break;
									}
								}
							}
						}
					}
					else if (msg.wParam == VK_DELETE)
					{
						CWindow* win2 = WinHList.Find(::GetFocus());
						if (win2 != NULL)
						{
							if (win2->Type() == WINTYPE_EDIT) noaccel = TRUE;
						}
					}					
				}
				break;
		}

		if (noaccel || !::TranslateAccelerator(MainFrame->Handle(), Accel, &msg))
		{
			::TranslateMessage(&msg);
			::DispatchMessage(&msg);
		}
	}

	// stop render thread
	RenderTerm();

	// deinitialize COM library
	::CoUninitialize();
	return 0;
}

///////////////////////////////////////////////////////////////////////////////
// save/load file dialog (returns filename; empty on error or cancel)

#define FILEMASKMAX 512
TCHAR FileMaskBuf[FILEMASKMAX];
#define FILENAMEMAX 511
TCHAR FileNameBuf[FILENAMEMAX+1];

CText GetSaveLoadFile(int maskid, LPCTSTR extdef, const CText& filename, CWindow* parent, BOOL save)
{
	// prepare mask
	CText txt;
	txt.Load(maskid);
	if (txt.IsEmpty()) return EmptyText;
	CTextList lst;
	lst.Split(txt, TCHAR('|'));
	int i, n;
	TCHAR* d = FileMaskBuf;
	for (i = 0; i < lst.Num(); i++)
	{
		n = lst[i].Length();
		lst[i].WriteZ(d);
		d += n + 1;
	}
	*d = 0;

	// prepare filename
	filename.WriteZ(FileNameBuf, FILENAMEMAX);

	// prepare openfile structure
	OPENFILENAME of;
	memset(&of, 0, sizeof(OPENFILENAME));
	of.lStructSize = sizeof(OPENFILENAME);
	of.hwndOwner = parent->Handle();
	of.lpstrFilter = FileMaskBuf;
	of.lpstrFile = FileNameBuf;
	of.nMaxFile = FILENAMEMAX;
	of.lpstrDefExt = extdef;

	// get filename
	if (save)
	{
		of.Flags = OFN_EXPLORER | OFN_ENABLESIZING | OFN_OVERWRITEPROMPT |
			OFN_PATHMUSTEXIST | OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
		if (!::GetSaveFileName(&of)) return EmptyText;
	}
	else
	{
		of.Flags = OFN_EXPLORER | OFN_ENABLESIZING |
			OFN_NOCHANGEDIR | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
		if (!::GetOpenFileName(&of)) return EmptyText;
	}

	// get filename
	CText txt2(FileNameBuf);
	txt2.Trim();
	return txt2;
}

///////////////////////////////////////////////////////////////////////////////
// internal error message

void IntError(const CText& txt)
{
	CText txt2;
	txt2.Load(IDS_INTERROR);
	::MessageBox((MainFrame == NULL) ? NULL : MainFrame->Handle(), txt, txt2, MB_OK);
}

///////////////////////////////////////////////////////////////////////////////
// copy text to clipboard

void TextToClipboard(const CText& txt)
{
	// copy text into clipboard
	if (!::OpenClipboard(MainFrame->Handle())) return;
	::EmptyClipboard();
	int n = txt.Length();
	HGLOBAL hg = ::GlobalAlloc(GMEM_MOVEABLE | GMEM_DDESHARE, n + 1);
	if (hg == NULL)
	{
		::CloseClipboard();
		return;
	}
	char* d = (char*)::GlobalLock(hg);
	if (d == NULL)
	{
		::GlobalFree(hg);
		::CloseClipboard();
		return;
	}
	txt.WriteZ(d);
	::GlobalUnlock(hg);
	::SetClipboardData(CF_TEXT, hg);
	::CloseClipboard();
}

///////////////////////////////////////////////////////////////////////////////
// paste text from clipboard (empty on error)

CText TextFromClipboard()
{
	// get text from clipboard
	if (!::OpenClipboard(MainFrame->Handle())) return EmptyText;
	HGLOBAL hg = ::GetClipboardData(CF_TEXT);
	if (hg == NULL)
	{
		::CloseClipboard();
		return EmptyText;
	}
	char* s = (char*)::GlobalLock(hg);
	if (s == NULL)
	{
		::CloseClipboard();
		return EmptyText;
	}
	CText txt(s);
	::GlobalUnlock(hg);
	::CloseClipboard();
	return txt;
}

///////////////////////////////////////////////////////////////////////////////
// check if file exists

BOOL FileExists(LPCTSTR filename)
{
	return (::GetFileAttributes(filename) != INVALID_FILE_ATTRIBUTES);
}

///////////////////////////////////////////////////////////////////////////////
// open help (0=content)

void HelpHelp(int id)
{
	// prepare help file name
	CText txt;
	txt.Load(ID_HELP_FILENAME);

	// help file cannot be found
	if (!FileExists(txt))
	{
		CText txt;
		txt.Load(ID_HELP_ERR);
		CText txt2;
		txt2.Load(ID_HELP_ERR2);
		::MessageBox(MainFrame->Handle(), txt2, txt, MB_OK | MB_ICONERROR);
		return;
	}

	// display help
	HtmlHelp(::GetDesktopWindow(), txt, ((id == 0) ? HH_DISPLAY_TOPIC : HH_HELP_CONTEXT), id);
}

