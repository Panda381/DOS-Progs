
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Editor View                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// colors
#define BGVIEWCOL	0x405060	// background color
#define FILTERF		0			// filter frame color
#define FILTERBG	0xffffff	// filter background color
#define FILTERFG	0			// filter foreground color
#define FILTERTFG	0			// filter title foreground color
#define FILTERSELC	0xff0000	// filter select color
#define FILTERVFCOL	0xc0c0c0	// filter value frame color

// filter colors
#define FILTERNUMCOL	0xb0b0b0	// numeric
#define FILTERIMGCOL	0x90f070	// image
#define FILTERCURCOL	0x30c0ff	// curve
#define FILTERPINCOL	0xffffff	// pin
#define FILTERGRADCOL	0xf07070	// gradient
#define FILTERENUMCOL	0xf0f070	// enumeration
#define FILTERCHECKCOL	0x000000	// check

// edit view buffer
extern SCanvas* ViewBuf;			// edit view buffer
extern int ViewViewX;			// view center X (X coordinate in center of view window)
extern int ViewViewY;			// view center Y (Y coordinate in center of view window)
extern int ViewViewSX;			// view source X coordinate (X start of display in view image)
extern int ViewViewSY;			// view source Y coordinate (Y start of display in view image)
extern int ViewViewOX;			// view offset X (convert filter coordinates to view image coordinates)
extern int ViewViewOY;			// view offset Y (convert filter coordinates to view image coordinates)
extern BOOL ViewSelOn;			// display selection box
extern int ViewSelX;			// X of selection box
extern int ViewSelY;			// Y of selection box
extern int ViewSelW;			// width of selection box
extern int ViewSelH;			// height of selection box

// property colors
u32 PropCol[];

// filter colors
u32 FiltCol[];

// edit view window
extern int ViewWinX, ViewWinY, ViewWinW, ViewWinH;	// view window

///////////////////////////////////////////////////////////////////////////////
// draw edit view to canvas buffer

void DrawView();

///////////////////////////////////////////////////////////////////////////////
// render edit view line

inline void RenderViewLine(int x1, int y1, int x2, int y2, u32 col)
{
	DrawLine(ViewBuf, x1 + ViewViewOX, y1 + ViewViewOY, x2 + ViewViewOX, y2 + ViewViewOY, col);
}

///////////////////////////////////////////////////////////////////////////////
// render edit view arrow

inline void RenderViewArrow(int x, int y, u32 col)
{
	DrawArrow(ViewBuf, x + ViewViewOX, y + ViewViewOY, col);
}

///////////////////////////////////////////////////////////////////////////////
// repaint edit view to screen

void RepaintView();

///////////////////////////////////////////////////////////////////////////////
// resize view

void ResizeView();
