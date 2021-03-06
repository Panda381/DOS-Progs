#include	"include.h"

// glob�ln� prom�nn�
HWND		hWndMain;					// handle hlavn�ho okna aplikace
HACCEL		hAccelMain;					// akcelera�n� tabulka hlavn�ho okna
char		MainFrmName[] = "MainFrm";	// jm�no t��dy hlavn�ho okna

const		StatusHeight = 16;			// v��ka stavov�ho ��dku
char*		StatusText = "N�pov�du z�sk�te stiskem kl�vesy F1";		// text stavov�ho ��dku

///////////////////////////////////////////////////////////////////
// zobrazen� stavov�ho ��dku
void DispStatus(HDC hDC, int width, int bottom)
{
	COLORREF	Color;
	COLORREF	TextColor;
	COLORREF	OldTextColor;
	COLORREF	OldBkColor;
    HPEN		hOldPen;
    HBRUSH		hOldBrush; 
    RECT		Rect;
    HFONT		hOldFont;
	                  
	Rect.left = 1;
	Rect.top = bottom - StatusHeight + 1;
	Rect.right = width;
	Rect.bottom = bottom;
	
	Color = GetSysColor(COLOR_BTNFACE);
	TextColor = GetSysColor(COLOR_BTNTEXT);
	
	hOldPen = SelectObject(hDC, CreatePen(PS_SOLID, 1, Color));
	hOldBrush = SelectObject(hDC, CreateSolidBrush(Color));
	OldTextColor = SetTextColor(hDC, TextColor);
	OldBkColor = SetBkColor(hDC, Color);
	hOldFont = SelectObject(hDC, CreateFont(
			15,             			// v��ka
			0,							// ���ka
			0,							// odklon
			0,							// orientace
			0,							// v�ha
			0,  						// italic
			0,							// podtr�en�
			0,							// p�e�krtnut�
			0,							// sada znak�
			OUT_DEFAULT_PRECIS,			// output precision
			CLIP_DEFAULT_PRECIS,		// cliping precision
			DEFAULT_QUALITY,			// kvalita
			DEFAULT_PITCH | FF_SWISS,	// pitch a family
			"MS Sans Serif"));			// jm�no
			
	Rectangle(hDC, 0, bottom - StatusHeight, width, bottom);
    DrawText(hDC, StatusText, -1, &Rect, 
    		DT_LEFT | DT_NOPREFIX | DT_SINGLELINE | DT_VCENTER);
                     
    SetBkColor(hDC, OldBkColor);                                 
    SetTextColor(hDC, OldTextColor);                                 
    DeleteObject(SelectObject(hDC, hOldFont));
    DeleteObject(SelectObject(hDC, hOldBrush));
    DeleteObject(SelectObject(hDC, hOldPen));
}     

///////////////////////////////////////////////////////////////////
// obsluha zpr�v hlavn�ho okna
LRESULT CALLBACK MainFrm_WndProc(HWND hWnd, UINT nMsg, WPARAM wParam, LPARAM lParam)
{
    HDC			hDC;              
    PAINTSTRUCT ps;
    RECT		ClientRect;
    
    switch (nMsg)
    {
    	case WM_PAINT:
    		hDC = BeginPaint(hWnd, &ps);
    		GetClientRect(hWnd, &ClientRect);
    		DispStatus(hDC, ClientRect.right, ClientRect.bottom);
    		EndPaint(hWnd, &ps);
    		break;   
    	case WM_SYSCOMMAND
    		           
    	case WM_DESTROY:
    		PostQuitMessage(0);
    		break;
    	default:
    		return (DefWindowProc(hWnd, nMsg, wParam, lParam));
    }
           
 	return 0;
}

///////////////////////////////////////////////////////////////////
// inicializace hlavn�ho okna aplikace
BOOL MainFrm_Init()
{
	WNDCLASS	wc;

// registrace t��dy okna
	wc.style			= CS_DBLCLKS | CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc		= MainFrm_WndProc;
	wc.cbClsExtra		= 0;
	wc.cbWndExtra		= 0;
	wc.hInstance		= hInstance;
	wc.hIcon			= LoadIcon(hInstance, MAKEINTRESOURCE(ID_MAINFRM));
	wc.hCursor			= LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground	= NULL;
	wc.lpszMenuName		= MAKEINTRESOURCE(ID_MAINFRM);
	wc.lpszClassName	= MainFrmName;
	
	RegisterClass(&wc);

// vytvo�en� okna      
    hWndMain = CreateWindowEx(
            0,
            MainFrmName,
            "Pet��k",
            WS_OVERLAPPEDWINDOW | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
            100, 100, 640, 450,
            NULL,
            NULL,
            hInstance,
            NULL);              
            
    if (!hWndMain) return FALSE;

    ShowWindow(hWndMain, nCmdShow);

// na�ten� akcelera�n� tabulky hlavn�ho okna
	hAccelMain = LoadAccelerators(hInstance, MAKEINTRESOURCE(ID_MAINFRM));

    return TRUE;
}

