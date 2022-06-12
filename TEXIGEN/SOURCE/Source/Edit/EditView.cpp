
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Editor View                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// edit view buffer
SCanvas* ViewBuf = NULL;		// edit view buffer
int ViewViewX = 100;			// view center X (X coordinate in center of view window)
int ViewViewY = 100;			// view center Y (Y coordinate in center of view window)
int ViewViewSX = 0;				// view source X coordinate (X start of display in view image)
int ViewViewSY = 0;				// view source Y coordinate (Y start of display in view image)
int ViewViewOX = 0;				// view offset X (convert filter coordinates to view image coordinates)
int ViewViewOY = 0;				// view offset Y (convert filter coordinates to view image coordinates)
BOOL ViewSelOn = FALSE;			// display selection box
int ViewSelX = 50;				// X of selection box
int ViewSelY = 50;				// Y of selection box
int ViewSelW = 200;				// width of selection box
int ViewSelH = 200;				// height of selection box

// edit view window
int ViewWinX, ViewWinY, ViewWinW, ViewWinH;	// view window

// view selected filter mark (NULL=none)
CText ViewSelFilterText(_T("*"));

// property colors
u32 PropCol[] = {
	FILTERNUMCOL,	// PCAT_VAL: numeric value
	FILTERIMGCOL,	// PCAT_COLOR: color
	FILTERCURCOL,	// PCAT_CURVE: curve
	FILTERGRADCOL,	// PCAT_GRAD: gradient
	FILTERENUMCOL,	// PCAT_ENUM: enumeration
	FILTERCHECKCOL,	// PCAT_CHECK: check box
	FILTERIMGCOL,	// PCAT_LOOPBEGIN: output from LoopBegin
	FILTERIMGCOL,	// PCAT_LOOPEND: output from LoopEnd
	FILTERIMGCOL,	// PCAT_PARTICLE: output from Particle
};

// filter colors (on change update FILTERCAT!)
u32 FiltCol[] = {
	FILTERIMGCOL,	// FCAT_IMG: image
	FILTERCURCOL,	// FCAT_CURVE: curve
	FILTERPINCOL,	// FCAT_PIN: pin
	FILTERNUMCOL,	// FCAT_INVALUE: input value filter
	FILTERGRADCOL,	// FCAT_INCOLOR: input color filter
	FILTERIMGCOL,	// FCAT_INIMAGE: input image filter
	FILTERIMGCOL,	// FCAT_INIMAGEDATA: input image data filter
	FILTERIMGCOL,	// FCAT_OUT: main output
	FILTERCURCOL,	// FCAT_TABLE: table
	FILTERIMGCOL,	// FCAT_BRICK: bricks and paving
	FILTERIMGCOL,	// FCAT_LOOPBEGIN: LoopBegin
	FILTERIMGCOL,	// FCAT_LOOPEND: LoopEnd
	FILTERNUMCOL,	// FCAT_SYS: system values
	FILTERIMGCOL,	// FCAT_PARTICLE: particle
};

///////////////////////////////////////////////////////////////////////////////
// draw one filter to canvas buffer

void DrawFilter(CFilter* f)
{
	// coordinates
	int x = f->X() + ViewViewOX;
	int y = f->Y() + ViewViewOY;

	// width and height
	int w = f->BaseW();
	int h = f->BaseH();

	// draw filter base
	DrawImage(ViewBuf, f->Image(), x, y);

	// selected
	if (f->Selected())
	{
		DrawFrame(ViewBuf, x - 1, y - 1, w + 2, h + FILTERTH + 2, FILTERSELC);
		DrawFrame(ViewBuf, x - 2, y - 2, w + 4, h + FILTERTH + 4, FILTERSELC);
	}

	// output arrow
	u32 c = FiltCol[(int)f->Category()];
	if (f->Category() == FCAT_PIN) c = FILTERIMGCOL;
	DrawArrow(ViewBuf, x + w - 1, y + f->BaseOutY() - 4, c);

	if (f->Category() != FCAT_PIN)
	{
		// preview
		int x2 = x + w - FPREVWH - GRID;
		if (f->Category() != FCAT_INVALUE)
		{
			if (f->Category() == FCAT_INCOLOR)
				DrawImage(ViewBuf, f->Preview(), x2, y + h - 3*GRID + 1, 2*GRID);
			else
				DrawImage(ViewBuf, f->Preview(), x2, y + h - FPREVWH - GRID + 1);
		}
		else
		{
			CText txt;
			txt.SetDouble(((CFilterValue*)f)->DefValue());
			DrawText(ViewBuf, txt, x2 + 3, y + h - 3*GRID + 3, FILTERFG, FPREVWH - 4);
		}

		// draw label of input filter
		if ((f->Category() >= FCAT_IN_MIN) && (f->Category() <= FCAT_IN_MAX))
		{
			CFilterIn* f2 = (CFilterIn*)f;
			DrawText(ViewBuf, f2->Label(), x + 5, y + h - 20, FILTERFG, w - FPREVWH - 18);
		}

		// draw label of output filter
		if (f->Category() == FCAT_OUT)
		{
			CFilterOut* f2 = (CFilterOut*)f;
			DrawText(ViewBuf, f2->Label(), x + 5, y + h - 13, FILTERFG, w - FPREVWH - 18);
		}

		// draw label of table filter
		if (f->Category() == FCAT_TABLE)
		{
			CFilterTable* f2 = (CFilterTable*)f;
			CText txt;
			txt = TCHAR('(');
			txt.AddInt(f2->ListNum());
			txt += _T(") ");
			txt += f2->List();
			DrawText(ViewBuf, txt, x + 5, y + h - 13, FILTERFG, w - FPREVWH - 18);
		}

		// draw label of brick filter
		if (f->Category() == FCAT_BRICK)
		{
			CFilterBrick* f2 = (CFilterBrick*)f;
			CText txt;
			txt = TCHAR('(');
			txt.AddInt(f2->RowNum());
			txt += TCHAR('x');
			txt.AddInt(f2->ColMax());
			txt += _T(") ");
			txt += f2->List();
			DrawText(ViewBuf, txt, x + 5, y + h - 13, FILTERFG, w - FPREVWH - 18);
		}
	}

	// view selected filter mark
	if (f == PrevFilter) DrawText(ViewBuf, ViewSelFilterText, x + w - ((f->Category() == FCAT_PIN) ? 8 : 13), y + h + 2, FILTERTFG);
}

///////////////////////////////////////////////////////////////////////////////
// draw connections (skip internal filters with no image)

void DrawConnect(CFilter* f)
{
	int i;
	CProperty* p;
	CFilter* f2;
	u32 c;
	for (i = 0; i < f->PropNum(); i++)
	{
		p = f->Prop(i);
		f2 = p->Filter();
		if ((f2 != NULL) && (f2->Image() != NULL))
		{
			c = FiltCol[(int)f2->Category()];
			DrawLine(ViewBuf, f2->OutX() + ViewViewOX, f2->OutY() + ViewViewOY,
				f->PropX() + ViewViewOX, f->PropY(i) + ViewViewOY, c);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// draw edit view to canvas buffer

void DrawView()
{
	FilterViewReq = FALSE;

	// clear buffer
	u8* buf = ViewBuf->d;
	int i;
	for (i = ViewBuf->w*ViewBuf->h; i > 0; i--)
	{
		*(u32*)buf = BGVIEWCOL;
		buf += 3;
	}

	// render connections
	CFilter* f;
	ListForEach(f, &FGraph)
	{
		DrawConnect(f);
	}

	// draw filters
	ListForEach(f, &FGraph)
	{
		DrawFilter(f);
	}

	// draw selection frame
	if (ViewSelOn)
	{
		DrawDash(ViewBuf, ViewSelX, ViewSelY, ViewSelW, ViewSelH, 0xff000000, 0xffffffff);
	}
}

///////////////////////////////////////////////////////////////////////////////
// repaint edit view to screen

void RepaintView()
{
	// get client window DC
	HDC dc = ::GetDC(MainFrame->Handle());

	// prepare bitmap info header
	BITMAPINFO bmp;
	memset(&bmp, 0, sizeof(BITMAPINFO));
	bmp.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
	bmp.bmiHeader.biHeight = ViewWinH;
	bmp.bmiHeader.biWidth = ViewBuf->w;
	bmp.bmiHeader.biPlanes = 1;
	bmp.bmiHeader.biBitCount = 24;
	bmp.bmiHeader.biCompression = BI_RGB;

	// stretch mode - no smoothing
	::SetStretchBltMode(dc, COLORONCOLOR);

	u8* buf = ViewBuf->d + ViewViewSY*ViewBuf->w*3;
	::StretchDIBits(dc, ViewWinX, ViewWinY, ViewWinW, ViewWinH, ViewViewSX, 0,
		ViewWinW, ViewWinH, buf, &bmp, DIB_RGB_COLORS, SRCCOPY);

	// release DC
	::ReleaseDC(MainFrame->Handle(), dc);
}

///////////////////////////////////////////////////////////////////////////////
// resize edit view (without repaint)

void ResizeView()
{
	// prepare view buffer
	int w = FGraphViewX2 - FGraphViewX + 2*FRESMARG;
	if (w < ViewWinW) w = ViewWinW;
	w = (w + 3) & ~3;

	int h = FGraphViewY2 - FGraphViewY + 2*FRESMARG;
	if (h < ViewWinH) h = ViewWinH;
	h = (h + 3) & ~3;

	if (ViewBuf != NULL)
	{
		if (w < ViewBuf->w) w = ViewBuf->w;
		if (h < ViewBuf->h) h = ViewBuf->h;
	}

	if ((ViewBuf == NULL) || ((int)ViewBuf->w < w) || ((int)ViewBuf->h < h))
	{
		ViewBuf = ReallocCanvas(ViewBuf, w, h);
	}

	// X coordinate
	w = ViewBuf->w;
	int dw = (w - (FGraphViewX2 - FGraphViewX))/2; // left or right margin
	int w0 = ViewWinW/2;			// half X of window
	int x1 = FGraphViewX - dw;		// X cordinate of left margin
	if ((ViewViewX - w0) < x1) ViewViewX = x1 + w0; // limit X from left
	int x2 = FGraphViewX2 + dw;		// X coordinate of right margin
	if ((ViewViewX + w0) > x2) ViewViewX = x2 - w0; // limit X from right
	ViewViewSX = ViewViewX - w0 - x1;
	if (ViewViewSX < 0) ViewViewSX = 0;
	ViewViewOX = (w - FGraphViewX2 - FGraphViewX)/2;

	// Y coordinate
	h = ViewBuf->h;
	int dh = (h - (FGraphViewY2 - FGraphViewY))/2; // bottom or top margin
	int h0 = ViewWinH/2;			// half Y of window
	int y1 = FGraphViewY - dh;		// Y cordinate of bottom margin
	if ((ViewViewY - h0 - 1) < y1) ViewViewY = y1 + h0 + 1; // limit Y from bottom
	int y2 = FGraphViewY2 + dh;		// Y coordinate of top margin
	if ((ViewViewY + h0 + 1) > y2) ViewViewY = y2 - h0 - 1; // limit Y from top
	ViewViewSY = ViewViewY - h0 - y1;
	if (ViewViewSY < 0) ViewViewSY = 0;
	ViewViewOY = (h - FGraphViewY2 - FGraphViewY)/2;
}
