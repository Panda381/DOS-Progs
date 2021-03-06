#include	"include.h"

// glob�ln� prom�nn�
HINSTANCE	hInstance;		// handle t�to aplikace
HINSTANCE	hPrevInst;		// handle p�edch�zej�c� instance aplikace
LPSTR		lpszCmdLine;	// p��kazov� ��dek
int			nCmdShow;		// po��te�n� zobrazen� hlavn�ho okna
 
MSG			msg;			// zpracov�van� zpr�va

///////////////////////////////////////////////////////////////////
// inicializace aplikace
BOOL App_Init()
{                 
// inicializace hlavn�ho okna aplikace
	if (!MainFrm_Init()) return FALSE;

    return TRUE;
}

///////////////////////////////////////////////////////////////////
// ukon�en� aplikace
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
// p��prava glob�ln�ch prom�nn�ch
	hInstance	= _hInstance;
	hPrevInst	= _hPrevInst;
	lpszCmdLine	= _lpszCmdLine;
	nCmdShow	= _nCmdShow;

	hWndMain	= NULL;
	hAccelMain	= NULL;	
    
// inicializace aplikace
    if (!App_Init()) return 1;
    
// hlavn� obslu�n� smy�ka	                   
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
