#include	"include.h"

// globální promìnné
HINSTANCE	hInstance;		// handle této aplikace
HINSTANCE	hPrevInst;		// handle pøedcházející instance aplikace
LPSTR		lpszCmdLine;	// pøíkazový øádek
int			nCmdShow;		// poèáteèní zobrazení hlavního okna
 
MSG			msg;			// zpracovávaná zpráva

///////////////////////////////////////////////////////////////////
// inicializace aplikace
BOOL App_Init()
{                 
// inicializace hlavního okna aplikace
	if (!MainFrm_Init()) return FALSE;

    return TRUE;
}

///////////////////////////////////////////////////////////////////
// ukonèení aplikace
void App_Term()
{  
	if (hWndMain) DestroyWindow(hWndMain);
	hWndMain = NULL;
}                     

///////////////////////////////////////////////////////////////////
// start aplikace
            
int PASCAL WinMain(HINSTANCE _hInstance, HINSTANCE _hPrevInst, 
	LPSTR _lpszCmdLine, int _nCmdShow)
{
// pøíprava globálních promìnných
	hInstance	= _hInstance;
	hPrevInst	= _hPrevInst;
	lpszCmdLine	= _lpszCmdLine;
	nCmdShow	= _nCmdShow;

	hWndMain	= NULL;
	hAccelMain	= NULL;	
    
// inicializace aplikace
    if (!App_Init()) return 1;
    
// hlavní obslužná smyèka	                   
	while (GetMessage(&msg, NULL, 0, 0))
	{           
		if (!TranslateAccelerator(msg.hwnd, hAccelMain, &msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}            

	App_Term();
		
	return msg.wParam;
}
