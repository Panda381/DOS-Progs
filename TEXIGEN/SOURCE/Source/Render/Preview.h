
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Preview                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

extern BOOL Tiles;				// display tiles

extern volatile BOOL PreviewMode;	// preview mode

extern int PrevW;				// preview width
extern int PrevH;				// preview height
extern real PrevZoomX;			// preview X relative coordinate
extern real PrevZoomY;			// preview Y relative coordinate
extern real PrevZoomW;			// preview relative width

extern volatile int PreviewPriority; // preview priority, 0=stop, 1=idle...6=normal (= CPUPRIOR + 1)

// preview dimension Select
extern int PrevDim;
#define PREVDIMN 10
#define PREVDIMMAXX 1024
#define PREVDIMMAXY 1024
extern const int PrevDimXTab[PREVDIMN];
extern const int PrevDimYTab[PREVDIMN];

// preview dimension Edit
extern int PrevDim2;
#define PREVDIMN2 4
extern const int PrevDimXTab2[PREVDIMN2];
extern const int PrevDimYTab2[PREVDIMN2];

extern CFilter* PrevFilter;		// current preview filter

extern u8	PrevBuf[];			// preview buffer (+ 1 byte reserve to enable using DWORD)

extern volatile u8 PrevUpDisp;	// request to update preview display

extern int PrevWinX, PrevWinY, PrevWinW, PrevWinH; // preview window position and size
//extern int PrevDX, PrevDY, PrevDW, PrevDH;	// preview destination position and size
//extern int PrevSX, PrevSY;				// preview source position

extern int PrevProgN;			// preview progress total
extern int PrevProg;			// preview progress (0..PrevProgN)

extern int PrevStepN;	// preview steps (64,32,16,8,4,2,1)
extern volatile u8 PreviewPause; // pause preview (set from render dialog)

// ----- filter preview images

extern volatile u8 FilterReq;		// request to render filter preview images
extern volatile u8 FilterViewReq;	// request to update filter view

#define GRID1	(real)0.9	// background grid color 1
#define GRID2	(real)0.7	// background grid color 2
#define GRIDN1	16		// grid size in filter preview
#define GRIDN2	32		// grid size in edit preview

// render statistic
extern int PrevStatTime;	// time counter (in [ms])
extern int PrevStatPix;		// pixel counter

///////////////////////////////////////////////////////////////////////////////
// clear preview buffer

void ClearPrevBuf();

///////////////////////////////////////////////////////////////////////////////
// update preview statistic timer (called every 55 ms)

void PreviewStatTimer();

///////////////////////////////////////////////////////////////////////////////
// generate filter preview

void GenFPrev(CFilter* f);

///////////////////////////////////////////////////////////////////////////////
// preview layout

void PreviewLayout(int x, int y, int w, int h, int prevw, int prevh);

///////////////////////////////////////////////////////////////////////////////
// start selection render preview

void SPrevRenderStart();

///////////////////////////////////////////////////////////////////////////////
// start edit render preview (selected filter or NULL=none)

void EPrevRenderStart(/*CFilter* f*/);

///////////////////////////////////////////////////////////////////////////////
// stop render preview

void PrevRenderStop();

///////////////////////////////////////////////////////////////////////////////
// redraw preview

void RedrawPreview();

///////////////////////////////////////////////////////////////////////////////
// update preview priority

void UpdatePreviewPriority();

///////////////////////////////////////////////////////////////////////////////
// start render thread (returns FALSE on error)

BOOL RenderInit();

///////////////////////////////////////////////////////////////////////////////
// terminate render thread

void RenderTerm();
