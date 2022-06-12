
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Filter Editation                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

volatile BOOL EditMode = FALSE;	// editation mode is activated

int EditW1;						// width of left stripe
int EditW2;						// width of right stripe

// current selected group of filters template (0=all)
int GroupFSel = 0;

#define ZOOMEDITX1 250
#define ZOOMEDITW1 50
#define ZOOMEDITX2 (ZOOMEDITX1+ZOOMEDITW1+5)
#define ZOOMEDITW2 90

#define OUTTILESX (ZOOMEDITX2+ZOOMEDITW2+10)
#define OUTTILESW (60+10)
#define LOCKVIEWX (OUTTILESX+OUTTILESW)
#define LOCKVIEWW (60+10)

#define TIMEEDITX1 (LOCKVIEWX+LOCKVIEWW+5)
#define TIMEEDITW1 30
#define TIMEEDITX2 (TIMEEDITX1+TIMEEDITW1+5)
#define TIMEEDITW2 100

// lock view check
CCheckBox	LockViewCheck;		// lock view check

BOOL Lock = FALSE;				// lock filter preview

// group selection
int EditGrpX;					// X of group selection
int EditGrpW;					// width of group selection
int EditGrpY;					// Y of group selection
int EditGrpH;					// height of group selection
CListBox GrpSelListBox;			// group selection list box
int EditFGrpX;					// X of group filter selection
int EditFGrpW;					// width of group filter selection
int EditFGrpY;					// Y of group filter selection
int EditFGrpH;					// height of group filter selection
CScroller FGrpScroller;			// group filter scroller

// view scrollers
CScroller		ViewHScroller;		// view horizontal scroller
CScroller		ViewVScroller;		// view vertical scroller

// dragging
BOOL EditLDown = FALSE;				// left mouse button is down
BOOL EditRDown = FALSE;				// right mouse button is down
BOOL EditMDown = FALSE;				// middle mouse button is down
BOOL EditDragOn = FALSE;			// dragging started
BOOL EditDragNew = FALSE;			// dragging new filter
int EditDragLXW, EditDragLYW;		// dragging last window coordinates
int EditDragLX, EditDragLY;			// dragging last coordinates
int EditDragLX0, EditDragLY0;		// dragging start coordinates
int EditDragMinX, EditDragMinY, EditDragMaxX, EditDragMaxY; // dragging limits
CFilter* EditDragFOut = NULL;		// dragging filter output (NULL = none)
CProperty* EditDragPDst = NULL;		// destination property
CFilter* EditDragPDstOld = NULL;		// old source

///////////////////////////////////////////////////////////////////////////////
// calculate layout of edit screen

void LayoutEdit()
{
	EditW1 = STRIPEW;
	EditW2 = FGRPW + VIEWSCROLLERW;

	// prepare edit view window
	ViewWinX = EditW1 + MainFrameClientLeft;
	ViewWinY = MainFrameClientTop;
	ViewWinW = MainFrameClientWidth - EditW1 - EditW2 - VIEWSCROLLERW;
	ViewWinH = MainFrameClientHeight - VIEWSCROLLERW;

	// control menu
	PropFrame.Move(MainFrameClientLeft, MainFrameClientTop + STRIPEW, STRIPEW, MainFrameClientHeight - STRIPEW);

	// group selection box
	EditGrpX = ViewWinX + ViewWinW + VIEWSCROLLERW;
	EditGrpY = MainFrameClientTop;
	EditGrpW = EditW2;
	EditGrpH = GROUPSELHEIGHT; 

	// group filter selection
	EditFGrpX = EditGrpX;
	EditFGrpW = FGRPW;
	EditFGrpY = EditGrpY + EditGrpH + EDITGRPDH;
	EditFGrpH = MainFrameClientTop + MainFrameClientHeight - EditFGrpY;

	// preview window
	PreviewLayout(MainFrameClientLeft, MainFrameClientTop, EditW1, EditW1,
		PrevDimXTab2[PrevDim2], PrevDimYTab2[PrevDim2]);
}

///////////////////////////////////////////////////////////////////////////////
// start edit screen (returns FALSE on error)

void CreateEdit()
{
	// edit mode is activated
	if (EditMode) return;
	EditMode = TRUE;

	// unlock preview
	Lock = FALSE;

	// clear preview buffer
	ClearPrevBuf();

	// load default variation
	LoadDefVar();

	// calculate layout of edit screen
	LayoutEdit();

	// show property editor
	PropFrame.Show();

	// view scrollers
	ViewVScroller.CreateVScroll(ViewWinX+ViewWinW, ViewWinY, VIEWSCROLLERW, ViewWinH, MainFrame);
	ViewHScroller.CreateHScroll(ViewWinX, ViewWinY+ViewWinH, ViewWinW, VIEWSCROLLERW, MainFrame);

	// group selection box
	GrpSelListBox.CreateLst(EditGrpX, EditGrpY, EditGrpW, EditGrpH, FALSE, FALSE, MainFrame);

	// group filter scroller
	FGrpScroller.CreateVScroll(EditFGrpX+EditFGrpW, EditFGrpY, VIEWSCROLLERW, EditFGrpH, MainFrame);

	// zoom selection title
	ZoomSelTitle.CreateRight(EmptyText, ZOOMEDITX1, 10, ZOOMEDITW1, DefLabelH, MainFrame->ToolBar());

	// zoom selection box
	ZoomSelBox.CreateLst(ZOOMEDITX2, 6, ZOOMEDITW2, 200, FALSE, MainFrame->ToolBar());
	MainFrame->ToolBar()->AddToolTip(&ZoomSelBox, ID_SELZOOM);

	// tiles check
	OutTilesCheck.CreateChk(EmptyText, OUTTILESX, 9,
		FALSE, FALSE, OUTTILESW, DefCheckBoxH, MainFrame->ToolBar());
	MainFrame->ToolBar()->AddToolTip(&OutTilesCheck, ID_TILES);

	// lock view check
	LockViewCheck.CreateChk(EmptyText, LOCKVIEWX, 9,
		FALSE, FALSE, LOCKVIEWW, DefCheckBoxH, MainFrame->ToolBar());
	MainFrame->ToolBar()->AddToolTip(&LockViewCheck, ID_LOCK);

	// time slider
	TimeSelTitle.CreateRight(EmptyText, TIMEEDITX1, 10, TIMEEDITW1, DefLabelH, MainFrame->ToolBar());
	TimeSelSlider.SetId(ID_TIME);
	TimeSelSlider.CreateLowSlider(TIMEEDITX2, 6, TIMEEDITW2, 30, MainFrame->ToolBar());
	TimeSelSlider.SetPos((int)(PreviewTime*100+0.5));
	MainFrame->ToolBar()->AddToolTip(&TimeSelSlider, ID_TIME);

	// request to generate filter previews
	FLock.Lock();
	CFilter* f;
	ListForEach(f, &FGraph)
	{
		f->SetReqPrev(TRUE);
	}
	FLock.Unlock();
	FilterReq = TRUE;

	// set toolbar buttons
	MainFrame->ToolBar()->DelAllBtn();
	MainFrame->ToolBar()->AddBtn(TBEButton, TBEButtonNum);

	// selected filter
	PrevFilter = ((DWORD)OutFilterInx >= (DWORD)OutFilterNum) ? NULL : OutFilter[OutFilterInx];
	EditCtrlF = PrevFilter;
	if (EditCtrlF != NULL) EditCtrlF->SetSelected(TRUE);
	EPrevRenderStart();

	// set texts
	UpdateEditText();

	// redraw
	EditResize();

	SetCaption();
}

///////////////////////////////////////////////////////////////////////////////
// close edit screen

void CloseEdit()
{
	// edit mode is not activated
	if (!EditMode) return;
	EditMode = FALSE;

	// unselect filter
	PrevFilter = NULL;
	EditSelFilter(NULL);

	// hide property editor
	PropFrame.Hide();

	GrpSelListBox.Destroy();
	ViewVScroller.Destroy();
	ViewHScroller.Destroy();
	FGrpScroller.Destroy();

	// delete time selection
	MainFrame->ToolBar()->DelToolTip(&TimeSelSlider);
	TimeSelSlider.Destroy();
	TimeSelTitle.Destroy();

	// delete zoom selections
	MainFrame->ToolBar()->DelToolTip(&ZoomSelBox);
	ZoomSelBox.Destroy();
	ZoomSelTitle.Destroy();

	MainFrame->ToolBar()->DelToolTip(&OutTilesCheck);
	OutTilesCheck.Destroy();

	MainFrame->ToolBar()->DelToolTip(&LockViewCheck);
	LockViewCheck.Destroy();

	// stop rendering
	PrevRenderStop();

	// delete view canvas
	free(ViewBuf);
	ViewBuf = NULL;
}

///////////////////////////////////////////////////////////////////////////////
// update edit texts after changing language

void UpdateEditText()
{
	if (!EditMode) return;

	GrpSelListBox.DelAll();
	GrpSelListBox.AddMulti(ID_GROUP_LIST);
	GrpSelListBox.SetSelect(GroupFSel);

	TextConnected.Load(IDS_CONNECTED);
	TextConnected = _T("<") + TextConnected + _T(">");
	EditSelFilter(EditCtrlF);

	ZoomSelTitle.LoadText(IDS_ZOOMSEL_TITLE);
	UpdateZoomList();

	OutTilesCheck.LoadText(IDS_TILES_TITLE);
	OutTilesCheck.SetCheck(Tiles);

	LockViewCheck.LoadText(IDS_LOCK_TITLE);
	LockViewCheck.SetCheck(Lock);

	TimeSelTitle.LoadText(IDS_TIME_TITLE);
}

///////////////////////////////////////////////////////////////////////////////
// redraw group selection

void EditGSelRedraw()
{
	if (!EditMode) return;

	// get client window DC
	HDC dc = ::GetDC(MainFrame->Handle());

	// stretch mode - no smoothing
	::SetStretchBltMode(dc, COLORONCOLOR);

	// draw filters
	int g = GroupFSel;
	int h = GroupImageList[g]->h;
	if (h > EditFGrpH) h = EditFGrpH;
	GroupImageBMP[g].bmiHeader.biHeight = h;
	::StretchDIBits(dc, EditFGrpX, EditFGrpY, EditFGrpW, h, 0, 0, FGRPW, h,
		GroupImageList[g]->d + (GroupImageList[g]->h - h - GroupFiltersTop[g])*FGRPW*3,
		&GroupImageBMP[g], DIB_RGB_COLORS, SRCCOPY);

	// draw empty space
	h = EditFGrpH - GroupImageList[g]->h;
	if (h > 0)
	{
		RECT rc;
		rc.left = EditFGrpX;
		rc.top = EditFGrpY + GroupImageList[g]->h;
		rc.right = EditFGrpX + EditFGrpW;
		rc.bottom = EditFGrpY + EditFGrpH;
		::FillRect(dc, &rc, (HBRUSH)::GetStockObject(WHITE_BRUSH));
	}

	// release DC
	::ReleaseDC(MainFrame->Handle(), dc);
}

///////////////////////////////////////////////////////////////////////////////
// redraw edit window

void EditRedraw()
{
	if (!EditMode) return;
	
	// get client window DC
	HDC dc = ::GetDC(MainFrame->Handle());
	RECT rc;
	HBRUSH brush;

	// menu background
	brush = ::GetSysColorBrush(COLOR_3DFACE);

	// small rectangle between view scrollers
	rc.left = ViewWinX + ViewWinW;
	rc.top = ViewWinY + ViewWinH;
	rc.right = rc.left + VIEWSCROLLERW;
	rc.bottom = rc.top + VIEWSCROLLERW;
	::FillRect(dc, &rc, brush);

	// gap between group selection and filter list
	rc.left = EditGrpX;
	rc.top = EditGrpY + EditGrpH;
	rc.right = EditGrpX + EditGrpW;
	rc.bottom = rc.top + EDITGRPDH;
	::FillRect(dc, &rc, brush);

	// release DC
	::ReleaseDC(MainFrame->Handle(), dc);

	// redraw preview
	RedrawPreview();

	// repaint edit view
	RepaintView();

	// redraw group selection
	EditGSelRedraw();
}

///////////////////////////////////////////////////////////////////////////////
// resize (without redraw) group selection and controls

void EditGSelResize()
{
	// update group selection scroller
	int h = GroupImageList[GroupFSel]->h;
	int max = h - EditFGrpH;
	if (max < 0) max = 0;
	if (GroupFiltersTop[GroupFSel] > max) GroupFiltersTop[GroupFSel] = max;
	if (max == 0)
		FGrpScroller.Enable(FALSE);
	else
	{
		int page = h;
		if (page > EditFGrpH) page = EditFGrpH;
		FGrpScroller.Enable(TRUE);
		FGrpScroller.SetRange(0, max, page);
		FGrpScroller.SetPos(GroupFiltersTop[GroupFSel]);
	}

	// update view scrollers
	ViewHScroller.SetRange(0, ViewBuf->w - ViewWinW, ViewWinW);
	ViewHScroller.SetPos(ViewViewSX);
	ViewVScroller.SetRange(0, ViewBuf->h - ViewWinH, ViewWinH);
	ViewVScroller.SetPos(ViewBuf->h - ViewWinH - ViewViewSY);

	// resize controls
	ViewVScroller.MoveResize(ViewWinX+ViewWinW, ViewWinY, VIEWSCROLLERW, ViewWinH);
	ViewHScroller.MoveResize(ViewWinX, ViewWinY+ViewWinH, ViewWinW, VIEWSCROLLERW);
	GrpSelListBox.MoveResize(EditGrpX, EditGrpY, EditGrpW, EditGrpH);
	FGrpScroller.MoveResize(EditFGrpX+EditFGrpW, EditFGrpY, VIEWSCROLLERW, EditFGrpH);
}

///////////////////////////////////////////////////////////////////////////////
// select group of filters

void SetGroupFSel(int inx)
{
	if ((DWORD)inx > (DWORD)FGRP_NUM) inx = 0;
	GroupFSel = inx;
	WriteIniInt("GroupSel", inx);
	EditGSelResize();
	EditGSelRedraw();
}

///////////////////////////////////////////////////////////////////////////////
// resize edit window

void EditResize()
{
	LayoutEdit();
	ResizeView();
	DrawView();
	EditGSelResize();
	EditRedraw();
}

///////////////////////////////////////////////////////////////////////////////
// delete selected filters

void EditDelete()
{
	// check if no edit control is activated
	HWND wnd = ::GetFocus();
	if (wnd != NULL)
	{
		CWindow* w = WinHList.Find(wnd);
		if ((w != NULL) && ((w->Type() == WINTYPE_EDIT)
			|| (w->Type() == WINTYPE_RICHEDIT)))
			return;
	}

	// find selected filters and delete them
	CFilter* f;
	FLock.Lock();
	for (;;)
	{
		f = FindGraphSelect();
		if (f == NULL) break;
		FGraphUpdate(f);
		FilterReq = TRUE;
		if (f == PrevFilter) PrevFilter = NULL;
		if (f == EditCtrlF) EditSelFilter(NULL);
		DelGraphSelect(f);
		SetModi();
	}
	FLock.Unlock();
	EditResize();
}

///////////////////////////////////////////////////////////////////////////////
// on left mouse double click - lock preview filter

void OnLDblClk(int xv, int yv)
{
	// get filter under mouse cursor
	CFilter* f = FindGraphFilter(xv, yv);
	if (f != NULL)
	{
		// view is locked
		if (Lock)
		{
			// this filter is already locked
			if (PrevFilter == f) return;

			// or alternative - unlock the same filter
			//if (PrevFilter == f)
			//{
			//	Lock = FALSE;
			//	LockViewCheck.SetCheck(Lock);
			//}
		}
		else
		{
			// lock view if not locked
			Lock = TRUE;
			LockViewCheck.SetCheck(Lock);
		}

		PrevFilter = f;
		EPrevRenderStart();
		DrawView();
		EditRedraw();
	}
}

///////////////////////////////////////////////////////////////////////////////
// on middle mouse button - dragging view

void OnMMouse(int x, int y)
{
	// already pressed - dragging
	if (EditMDown)
	{
		// difference of coordinates
		int dx = x - EditDragLXW;
		int dy = y - EditDragLYW;
		if ((dx != 0) || (dy != 0))
		{
			ViewViewSX -= dx;
			ViewViewX -= dx;
			ViewHScroller.SetPos(ViewViewSX);
			ViewViewSY += dy;
			ViewViewY += dy;
			ViewVScroller.SetPos(ViewVScroller.Max() - ViewViewSY);
			ResizeView();
			EditRedraw();
		}
	}

	// save current cursor position
	EditDragLXW = x;
	EditDragLYW = y;
	EditMDown = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// start dragging new filter from filter list

void OnNewFilter(int xv, int yv)
{
	// find filter in group list
	int yr = EditDragLYW - EditFGrpY + GroupFiltersTop[GroupFSel];
	int i;
	for (i = 0; i < GroupNum[GroupFSel]; i++)
	{
		if ((yr >= GroupFiltersY[GroupFSel][i]) &&
			(yr < GroupFiltersY[GroupFSel][i] + GroupFiltersH[GroupFSel][i]))
		{
			// create new filter
			CFilter* f = GroupFilters[GroupFSel][i]->Duplicate();
			if (f == NULL) return;
			f->SetReqPrev(TRUE);
			FilterReq = TRUE;

			// create new name
			CText name = NewGraphName();
			f->SetName(name);

			// filter coordinates
			f->SetX(xv - (EditDragLXW - EditFGrpX - GRID));
			f->SetY(yv - (GroupFiltersH[GroupFSel][i] - (yr - GroupFiltersY[GroupFSel][i])) + GRID);
			EditDragLX = xv;
			EditDragLY = yv;

			// add filter to filter list
			FLock.Lock();
			FGraph.AddLast(f);
			FLock.Unlock();

			// select filter
			UnselectGraphFilter();
			f->SetSelected(TRUE);

			// resize view area
			GetGraphView();
			ResizeView();
			EditGSelResize();
			SetModi();

			// prepare dragging limits
			GetGraphSelect();
			EditDragMinX = EditDragLX - (FGraphSelX + ViewViewOX) + 4;
			EditDragMaxX = EditDragLX + (ViewBuf->w - ViewViewOX - FGraphSelX2) - 4;
			EditDragMinY = EditDragLY - (FGraphSelY + ViewViewOY) + 4;
			EditDragMaxY = EditDragLY + (ViewBuf->h - ViewViewOY - FGraphSelY2) - 4;

			// start dragging
			EditDragOn = TRUE;

			if (!Lock) PrevFilter = EditCtrlF;
			EPrevRenderStart();
			break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// mouse event

void EditOnMouse(int x, int y, BOOL lb, BOOL rb, BOOL mb, int msg)
{
	// recalc mouse coordinates to view coordinates
	int xv = ViewViewX - ViewWinW/2 + x - ViewWinX;
	int yv = ViewViewY + ViewWinH/2 - (y - ViewWinY);

	// select preview filter with left double click
	if ((msg == WM_LBUTTONDBLCLK))
	{
		OnLDblClk(xv, yv);
		return;
	}

	// middle button pressed - dragging view
	if (mb)
	{
		OnMMouse(x, y);
		return;
	}
	else
		// middle button not pressed
		EditMDown = FALSE;

	// left mouse pressed
	if (lb && (EditLDown || (msg == WM_LBUTTONDOWN)))
	{
		// first press
		if (!EditLDown)
		{
			EditLDown = TRUE;

			// save coordinates
			EditDragLXW = x;
			EditDragLYW = y;
			EditDragLX = xv;
			EditDragLY = yv;
			EditDragLX0 = xv;
			EditDragLY0 = yv;
			EditDragOn = FALSE;
			EditDragNew = FALSE;
			EditDragFOut = NULL;
			EditDragPDst = NULL;
			EditDragPDstOld = NULL;
		}

		// continue with press
		else
		{
			// dragging not started yet
			if (!EditDragOn)
			{
				// check start distance, whether dragging has been started
				int dx = xv - EditDragLX;
				int dy = yv - EditDragLY;
				if ((dx*dx + dy*dy) >= DRAGDELTA*DRAGDELTA)
				{
					// check coordinate whether to drag new filter
					if ((EditDragLXW >= EditFGrpX) && (EditDragLYW >= EditFGrpY) &&
						(EditDragLXW < EditFGrpX + EditFGrpW) &&
						(EditDragLYW < EditFGrpY + EditFGrpH))
					{
						if (x < EditFGrpX - 30) OnNewFilter(xv, yv);
						return;
					}

					// check edit window
					if ((EditDragLXW < ViewWinX) || (EditDragLXW >= ViewWinX + ViewWinW) ||
						(EditDragLYW < ViewWinY) || (EditDragLYW >= ViewWinY + ViewWinH))
						return;

					// find input property
					EditDragPDst = FindGraphProperty(EditDragLX, EditDragLY);

					// found valid property with input filter
					if ((EditDragPDst != NULL) && ((EditDragPDst->Filter() != NULL) && (EditDragPDst->Filter() != &FLinear)))
					{
						PreviewPause = TRUE;
						EditDragFOut = EditDragPDst->Filter();
						EditDragPDst->SetFilter(NULL);
						FLock.Lock();
						FGraphUpdate(EditDragPDst->Parent());
						FilterReq = TRUE;
						FLock.Unlock();
					}
					else
					{
						// find output filter
						EditDragFOut = FindGraphOut(EditDragLX, EditDragLY);
					}

					// found valid output
					if (EditDragFOut != NULL)
					{
						// start dragging
						EditDragOn = TRUE;

						// move filter to top of graph
						TopGraphFilter(EditDragFOut);

						// prepare dragging limits
						EditDragMinX = 10 - ViewViewOX;
						EditDragMaxX = ViewBuf->w - 20 - ViewViewOX;
						EditDragMinY = 10 - ViewViewOY;
						EditDragMaxY = ViewBuf->h - 20 - ViewViewOY;
					}
					else
					{
						// find filter under mouse cursor
						CFilter* f = FindGraphFilter(EditDragLX, EditDragLY);

						// found valid filter
						if (f != NULL)
						{
							// start dragging
							EditDragOn = TRUE;

							// SHIFT key flag
							BOOL shft = ((::GetAsyncKeyState(VK_SHIFT) < 0) || (::GetAsyncKeyState(VK_CONTROL) < 0));
							
							// unselect all filters - only if not SHIFT key and not selected
							if (!shft && !f->Selected()) UnselectGraphFilter();

							// select filter
							f->SetSelected(TRUE);

							// move last selected filter to top of graph
							TopGraphFilter(f);

							// prepare dragging limits
							GetGraphSelect();
							EditDragMinX = EditDragLX - (FGraphSelX + ViewViewOX) + 4;
							EditDragMaxX = EditDragLX + (ViewBuf->w - ViewViewOX - FGraphSelX2) - 4;
							EditDragMinY = EditDragLY - (FGraphSelY + ViewViewOY) + 4;
							EditDragMaxY = EditDragLY + (ViewBuf->h - ViewViewOY - FGraphSelY2) - 4;
						}

						// drag selection box
						else
						{
							EditDragOn = TRUE;
							ViewSelX = (xv < EditDragLX0) ? xv : EditDragLX0;
							ViewSelY = (yv < EditDragLY0) ? yv : EditDragLY0;
							ViewSelX += ViewViewOX;
							ViewSelY += ViewViewOY;
							ViewSelW = abs(xv - EditDragLX0);
							ViewSelH = abs(yv - EditDragLY0);
							ViewSelOn = TRUE;

							EditDragMinX = 1 - ViewViewOX;
							EditDragMaxX = ViewBuf->w - ViewViewOX - 1;
							EditDragMinY = 1 - ViewViewOY;
							EditDragMaxY = ViewBuf->h - ViewViewOY - 1;
						}
					}
				}
			}

			// continue with dragging
			if (EditDragOn)
			{
				// limit dragging
				if (xv < EditDragMinX) xv = EditDragMinX;
				if (xv > EditDragMaxX) xv = EditDragMaxX;
				if (yv < EditDragMinY) yv = EditDragMinY;
				if (yv > EditDragMaxY) yv = EditDragMaxY;

				// drag output
				if (EditDragFOut != NULL)
				{
					// return old filter
					if (EditDragPDst != NULL) EditDragPDst->SetFilter(EditDragPDstOld);

					// find property
					EditDragPDst = FindGraphProperty(xv, yv);

					// check connection loopback
					if ((EditDragPDst != NULL) && ((EditDragPDst->Category() != PCAT_LOOPEND) || (EditDragFOut->Category() != FCAT_LOOPEND))
							&& ((EditDragPDst->Category() != PCAT_PARTICLE) || (EditDragFOut->Category() != FCAT_PARTICLE)))
					{
						if (!GraphCheckLoop(EditDragFOut, EditDragPDst->Parent())) EditDragPDst = NULL;
					}

					// property is valid
					if (EditDragPDst != NULL)
					{
						PreviewPause = TRUE;
						xv = EditDragPDst->Parent()->PropX();
						yv = EditDragPDst->Parent()->PropY(EditDragPDst);
						EditDragPDstOld = EditDragPDst->Filter();
						EditDragPDst->SetFilter(NULL);
					}

					// redraw window
					DrawView();
					u32 c = FiltCol[(int)EditDragFOut->Category()];
					RenderViewLine(EditDragFOut->OutX(), EditDragFOut->OutY(), xv, yv, c);
					RenderViewArrow(xv + 1, yv - 4, c);
					EditRedraw();
				}
				else
				{
					// check drag distance
					int dx = xv - EditDragLX;
					int dy = yv - EditDragLY;
					EditDragLX = xv;
					EditDragLY = yv;

					if ((dx != 0) || (dy != 0))
					{
						// selection box
						if (ViewSelOn)
						{
							ViewSelX = (xv < EditDragLX0) ? xv : EditDragLX0;
							ViewSelY = (yv < EditDragLY0) ? yv : EditDragLY0;
							ViewSelW = abs(xv - EditDragLX0);
							ViewSelH = abs(yv - EditDragLY0);

							// unselect all filters
							UnselectGraphFilter();
							if (!Lock) PrevFilter = NULL;
							EditSelFilter(NULL);

							// select filters in selection box
							SelGraphFilterRange(ViewSelX, ViewSelY, ViewSelX + ViewSelW, ViewSelY + ViewSelH);

							ViewSelX += ViewViewOX;
							ViewSelY += ViewViewOY;
						}

						// move filters
						else
						{
							MoveGraphFilter(dx, dy);
						}

						// redraw window
						DrawView();
						EditRedraw();
					}
				}
			}
		}
	}

	// left mouse released
	else
	{
		// was pressed
		if (EditLDown)
		{
			PreviewPause = FALSE;
			EditLDown = FALSE;

			// was dragging - stop drag
			if (EditDragOn)
			{
				EditDragOn = FALSE;

				// drag connection
				if (EditDragFOut != NULL)
				{
					// valid destination
					if (EditDragPDst != NULL)
					{
						EditDragPDst->SetFilter(EditDragFOut);
						FLock.Lock();
						FGraphUpdate(EditDragPDst->Parent());
						FilterReq = TRUE;
						FLock.Unlock();
					}

					EditSelFilter(EditCtrlF);

					// redraw window
					if (!Lock) PrevFilter = EditCtrlF;
					EPrevRenderStart();
					EditResize();
					SetModi();
				}
				else
				{
					// selection box
					if (ViewSelOn)
					{
						ViewSelOn = FALSE;
						DrawView();
						RepaintView();
					}

					// drag filters
					else
					{
						// align filters to grid
						GridGraphFilter();

						// update graph window
						GetGraphView();

						if (!Lock) PrevFilter = FGraph.Last();
						EditSelFilter(FGraph.Last());

						// redraw window
						if (!Lock) PrevFilter = EditCtrlF;
						EPrevRenderStart();
						EditResize();
						SetModi();
					}
				}
			}

			// not dragging - select filters
			else
			{
				// find filter under mouse cursor
				CFilter* f = FindGraphFilter(EditDragLX, EditDragLY);

				// SHIFT key flag
				BOOL shft = ((::GetAsyncKeyState(VK_SHIFT) < 0) || (::GetAsyncKeyState(VK_CONTROL) < 0));

				// click on empty area
				if (f == NULL)
				{
					// unselect all filters - only if not SHIFT key
					if (!shft)
					{
						UnselectGraphFilter();
						if (!Lock) PrevFilter = NULL;
						EditSelFilter(NULL);
					}
				}
				else
				{
					// old selected state
					BOOL oldsel = f->Selected();

					// click on filter with SHIFT - add or subtract from selection
					if (shft)
						f->SetSelected(!oldsel);

					// without SHIFT - select filter
					else
					{
						UnselectGraphFilter();
						f->SetSelected(TRUE);
					}

					// move last selected filter to top of graph
					TopGraphFilter(f);

					if (!Lock) PrevFilter = f;
					EditSelFilter(f);
				}

				// redraw window
				DrawView();
				EditRedraw();
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// request to update current filter after change

void EditFilterUpdate()
{
	if (EditCtrlF != NULL)
	{
		FGraphRestart();
		// FLock.Lock(); // locks not needed; it freezes program for a while during edit
		FGraphUpdate(EditCtrlF);
		FilterReq = TRUE;
		// FLock.Unlock();
		EPrevRenderStart();
		SetModi();
	}
}

///////////////////////////////////////////////////////////////////////////////
// auto generator
/*
void AutoGener()
{
	// lock filters
	FLock.Lock();
	Modi = TRUE;
	SetCaption();

	// clear graph
	ClearGraph();
	UpdateSelCtrl();










	// get list of output filters
	GetOutFilt();

	// get list of input filters
	GetInFilt();

	// get view area of filters
	GetGraphView();
	GetGraphSelect();
	ViewViewX = (FGraphViewX + FGraphViewX2)/2;
	ViewViewY = (FGraphViewY + FGraphViewY2)/2;

	FLock.Unlock();

	PrevFilter = NULL;
	EditSelFilter(NULL);

	// redraw window
	DrawView();
	EditRedraw();
}
*/
