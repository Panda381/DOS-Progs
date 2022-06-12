
// zveøejnìní globálních promìnných aplikace
extern	HINSTANCE	hInstance;		// handle této aplikace
extern	HINSTANCE	hPrevInst;		// handle pøedcházející instance aplikace
extern	LPSTR		lpszCmdLine;	// pøíkazový øádek
extern	int			nCmdShow;		// poèáteèní zobrazení hlavního okna
 
extern	MSG			msg;			// zpracovávaná zpráva

// zveøejnìní procedur
int PASCAL WinMain(HINSTANCE, HINSTANCE, LPSTR, int);	// start aplikace
