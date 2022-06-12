
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Filter Selection                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

BOOL SelectMode = FALSE;	// selection mode is activated

//BOOL MarkVar = FALSE;		// mark variants

// preview zoom selection index
int		Zoom = 0;			// zoom (0=100%, ...)
real	ZoomMidX = (real)0.5; // zoom middle X
real	ZoomMidY = (real)0.5; // zoom middle Y

real PreviewTime = 0;		// preview time

// zoom options - edit
CText	ZoomTxtE(_T("100% (256)|200% (512)|400% (1K)|800% (2K)|1600% (4K)|3200% (8K)"));

// zoom options - select
CText	ZoomTxtS(_T("100% (512)|200% (1K)|400% (2K)|800% (4K)|1600% (8K)|3200% (16K)"));

// zoom multiplies
int		ZoomTab[ZOOMNUM] = { 1, 2, 4, 8, 16, 32 };

// zoom selection box
#define ZOOMSELX1 (DefToolBarBtnW*(TBSButtonNum-3) + 3*5 + 70)
#define ZOOMSELW1 50
#define ZOOMSELX2 (ZOOMSELX1+ZOOMSELW1+5)
#define ZOOMSELW2 90
CLabel		ZoomSelTitle;	// zoom selection title
CDropList	ZoomSelBox;		// zoom selection box

// tiles check box
#define OUTTILESX (ZOOMSELX2+ZOOMSELW2+10)
#define OUTTILESW (60+10)
CCheckBox	OutTilesCheck;	// tiles check

// output selection box
#define OUTSELX1 (OUTTILESX+OUTTILESW)
#define OUTSELW1 45
#define OUTSELX2 (OUTSELX1+OUTSELW1+5)
#define OUTSELW2 100
CLabel		OutSelTitle;	// output selection title
CDropList	OutSelBox;		// output selection box

// time slider
#define TIMESELX1 (OUTSELX2+OUTSELW2+5)
#define TIMESELW1 30
#define TIMESELX2 (TIMESELX1+TIMESELW1+5)
#define TIMESELW2 100
CLabel		TimeSelTitle;	// time selection title
CSlider		TimeSelSlider;	// time slider

///////////////////////////////////////////////////////////////////////////////
// calculate layout of selection screen

void LayoutSelection()
{
	// preview window
	PreviewLayout(MainFrameClientLeft + STRIPEW, MainFrameClientTop,
		MainFrameClientWidth - STRIPEW, MainFrameClientHeight,
		PrevDimXTab[PrevDim], PrevDimYTab[PrevDim]);

	// group selection
	int x = MainFrameClientLeft + 2;
	int y = MainFrameClientTop;
	int w = STRIPEW/3;
	int h = 190;
	GroupList.Move(x, y, w, h);

	// graph selection
	GraphList.Move(x + w + 2, y, STRIPEW - w - 6, h);
	y += h;

	// variation selection
	h = STRIPEW - h;
	VarList.Move(x, y, STRIPEW - GRPMARG, h);

	// filter setting layout
	PropFrame.Move(MainFrameClientLeft, MainFrameClientTop + STRIPEW, STRIPEW, MainFrameClientHeight - STRIPEW);
}

///////////////////////////////////////////////////////////////////////////////
// start selection screen

void CreateSelect()
{
	// selection mode is already activated
	if (SelectMode) return;
	SelectMode = TRUE;

	// clear preview buffer
	ClearPrevBuf();

	// clear filter graph
	ClearGraphLock();

	// calculate layout of selection screen
	LayoutSelection();

	// zoom selection title
	ZoomSelTitle.CreateRight(EmptyText, ZOOMSELX1, 10, ZOOMSELW1, DefLabelH, MainFrame->ToolBar());

	// zoom selection box
	ZoomSelBox.CreateLst(ZOOMSELX2, 6, ZOOMSELW2, 200, FALSE, MainFrame->ToolBar());
	MainFrame->ToolBar()->AddToolTip(&ZoomSelBox, ID_SELZOOM);

	// output selection title
	OutSelTitle.CreateRight(EmptyText, OUTSELX1, 10, OUTSELW1, DefLabelH, MainFrame->ToolBar());

	// output selection box
	OutSelBox.CreateLst(OUTSELX2, 6, OUTSELW2, 200, FALSE, MainFrame->ToolBar());
	MainFrame->ToolBar()->AddToolTip(&OutSelBox, ID_SELOUT);

	// tiles check
	OutTilesCheck.CreateChk(EmptyText, OUTTILESX, 9,
		FALSE, FALSE, OUTTILESW, DefCheckBoxH, MainFrame->ToolBar());
	MainFrame->ToolBar()->AddToolTip(&OutTilesCheck, ID_TILES);

	// time slider
	TimeSelTitle.CreateRight(EmptyText, TIMESELX1, 10, TIMESELW1, DefLabelH, MainFrame->ToolBar());
	TimeSelSlider.SetId(ID_TIME);
	TimeSelSlider.CreateLowSlider(TIMESELX2, 6, TIMESELW2, 30, MainFrame->ToolBar());
	TimeSelSlider.SetPos((int)(PreviewTime*100+0.5));
	MainFrame->ToolBar()->AddToolTip(&TimeSelSlider, ID_TIME);

	// show group selection
	GroupList.Show();

	// show graph selection
	GraphList.Show();

	// show variation selection
	VarList.Show();

	// show property editor
	PropFrame.Show();

	// set toolbar buttons
	MainFrame->ToolBar()->DelAllBtn();
	MainFrame->ToolBar()->AddBtn(TBSButton, TBSButtonNum);

	// update texts
	UpdateSelectText();

	// load lists and graph
	LoadGroupList();

	SPrevRenderStart();
}

///////////////////////////////////////////////////////////////////////////////
// close selection screen

void CloseSelect()
{
	// selection mode is not activated
	if (!SelectMode) return;

	// stop rendering
	PrevRenderStop();

	// hide property editor
	PropFrame.Hide();

	// hide selection boxes
	VarList.Hide();
	GraphList.Hide();
	GroupList.Hide();

	// delete time selection
	MainFrame->ToolBar()->DelToolTip(&TimeSelSlider);
	TimeSelSlider.Destroy();
	TimeSelTitle.Destroy();

	// delete zoom selections
	MainFrame->ToolBar()->DelToolTip(&ZoomSelBox);
	ZoomSelBox.Destroy();
	ZoomSelTitle.Destroy();

	// delete output selections
	MainFrame->ToolBar()->DelToolTip(&OutTilesCheck);
	OutTilesCheck.Destroy();
	MainFrame->ToolBar()->DelToolTip(&OutSelBox);
	OutSelBox.Destroy();
	OutSelTitle.Destroy();

	// end selection mode
	SelectMode = FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// update zoom list

void UpdateZoomList()
{
	// add zoom names to selection box
	ZoomSelBox.DelAll();
	ZoomSelBox.AddMulti(SelectMode ? ZoomTxtS : ZoomTxtE);

	// select zoom
	ZoomSelBox.SetSelect(Zoom);
}

///////////////////////////////////////////////////////////////////////////////
// update zoom parameters

void UpdateZoom()
{
	PrevZoomW = (real)1.0/(1 << Zoom);

	real x = ZoomMidX - PrevZoomW/2;
	if (x < 0) x = 0;
	if (x + PrevZoomW > 1) x = 1 - PrevZoomW;
	PrevZoomX = x;

	real y = ZoomMidY - PrevZoomW/2;
	if (y < 0) y = 0;
	if (y + PrevZoomW > 1) y = 1 - PrevZoomW;
	PrevZoomY = y;
}

///////////////////////////////////////////////////////////////////////////////
// set zoom

void SetZoom(int zoom)
{
	Zoom = zoom;
	UpdateZoom();
	ZoomSelBox.SetSelect(Zoom);
	WriteIniInt("Zoom", Zoom);
	if (SelectMode)
		SPrevRenderStart();
	else
		EPrevRenderStart();
}

///////////////////////////////////////////////////////////////////////////////
// shift preview

void ViewShift(int dx, int dy)
{
	real oldx = ZoomMidX;
	real oldy = ZoomMidY;

	PrevZoomW = (real)1.0/(1 << Zoom);

	ZoomMidX += dx*PrevZoomW/2;
	if (ZoomMidX < PrevZoomW/2) ZoomMidX = PrevZoomW/2;
	if (ZoomMidX > 1 - PrevZoomW/2) ZoomMidX = 1 - PrevZoomW/2;

	ZoomMidY += dy*PrevZoomW/2;
	if (ZoomMidY < PrevZoomW/2) ZoomMidY = PrevZoomW/2;
	if (ZoomMidY > 1 - PrevZoomW/2) ZoomMidY = 1 - PrevZoomW/2;

	if ((oldx != ZoomMidX) || (oldy != ZoomMidY))
	{
		UpdateZoom();

		if (SelectMode)
			SPrevRenderStart();
		else
			EPrevRenderStart();
	}
}

///////////////////////////////////////////////////////////////////////////////
// update output list

void UpdateOutputList()
{
	// add filter names to selection box
	OutSelBox.DelAll();
	int i;
	for (i = 0; i < OutFilterNum; i++)
	{
		OutSelBox.Add(OutFilter[i]->Label());
	}

	// select filter
	OutSelBox.SetSelect(((DWORD)OutFilterInx >= (DWORD)OutFilterNum) ? -1 : OutFilterInx);
}

///////////////////////////////////////////////////////////////////////////////
// update selection texts after changing language

void UpdateSelectText()
{
	// not selection mode
	if (!SelectMode) return;

	// update output selection text
	ZoomSelTitle.LoadText(IDS_ZOOMSEL_TITLE);
	UpdateZoomList();
	OutSelTitle.LoadText(IDS_OUTSEL_TITLE);
	OutTilesCheck.LoadText(IDS_TILES_TITLE);
	OutTilesCheck.SetCheck(Tiles);
	TimeSelTitle.LoadText(IDS_TIME_TITLE);
	UpdateOutputList();

	// update selection boxes
	GroupList.UpdateLang();
	GraphList.UpdateLang();
	VarList.UpdateLang();
}

///////////////////////////////////////////////////////////////////////////////
// redraw selection window

void SelectRedraw()
{
	// not selection mode
	if (!SelectMode) return;

	// get client window DC
	HDC dc = ::GetDC(MainFrame->Handle());
	RECT rc;
	HBRUSH brush;

	// menu background
	brush = ::GetSysColorBrush(COLOR_3DFACE);
	rc.left = MainFrameClientLeft;
	rc.top = MainFrameClientTop;
	rc.right = PrevWinX;
	rc.bottom = MainFrameClientTop + MainFrameClientHeight;
	::FillRect(dc, &rc, brush);

	// release DC
	::ReleaseDC(MainFrame->Handle(), dc);

	// redraw preview
	RedrawPreview();
}

///////////////////////////////////////////////////////////////////////////////
// resize selection window

void SelectResize()
{
	LayoutSelection();
	SelectRedraw();
}

///////////////////////////////////////////////////////////////////////////////
// delete

void SelectDelete()
{
	CText txt1, txt2;

	// delete variation
	CVarEntry* v = VarList.Selected();
	if (v != NULL)
	{
		// message
		txt1.Load(ID_SELDEL1);
		txt2.Load(ID_SELDEL2);
		if (::MessageBox(MainFrame->Handle(), txt2, txt1, MB_OKCANCEL) != IDOK) return;

		// prepare alternative variation
		CText name2;
		if (VarList.SelInx()+1 < VarList.Num())
			name2 = VarList[VarList.SelInx()+1].Name(); // next variation
		else
		{
			if (VarList.SelInx() > 0)
				name2 = VarList[VarList.SelInx()-1].Name(); // last variation
		}

		// delete file and image
		::DeleteFile(v->FileName());
		::DeleteFile(v->ImgFileName());

		// reload variation list
		VarList.SetSelName(name2);
		LoadVarList();
		return;
	}

	// delete filter
	CGraphEntry* f = GraphList.Selected();
	if ((VarList.Num() == 0) && (f != NULL))
	{
		// message
		txt1.Load(ID_SELDEL3);
		txt2.Load(ID_SELDEL4);
		if (::MessageBox(MainFrame->Handle(), txt2, txt1, MB_OKCANCEL | MB_DEFBUTTON2) != IDOK) return;

		// message 2
		txt2.Load(ID_SELDEL5);
		if (::MessageBox(MainFrame->Handle(), txt2, txt1, MB_OKCANCEL) != IDOK) return;

		// prepare alternative graph
		CText name2;
		if (GraphList.SelInx()+1 < GraphList.Num())
			name2 = GraphList[GraphList.SelInx()+1].Name(); // next filter
		else
		{
			if (GraphList.SelInx() > 0)
				name2 = GraphList[GraphList.SelInx()-1].Name(); // last filter
		}

		// delete filter
		::RemoveDirectory(GraphList.VarPath());
		CText txt = f->FileName();
		::DeleteFile(txt);
		txt.Delete(txt.Length()-3, 3);
		txt += _T(BACKEXT);
		::DeleteFile(txt);
		::DeleteFile(f->ImgFileName());

		// reload graph list
		GraphList.SetSelName(name2);
		LoadGraphList();
		return;
	}

	// delete group
	CGroupEntry* g = GroupList.Selected();
	if ((GraphList.Num() == 0) && (g != NULL))
	{
		// message
		txt1.Load(ID_SELDEL6);
		txt2.Load(ID_SELDEL7);
		if (::MessageBox(MainFrame->Handle(), txt2, txt1, MB_OKCANCEL) != IDOK) return;

		// prepare alternative group
		CText name2;
		if (GroupList.SelInx()+1 < GroupList.Num())
			name2 = GroupList[GroupList.SelInx()+1].Name(); // next group
		else
		{
			if (GroupList.SelInx() > 0)
				name2 = GroupList[GroupList.SelInx()-1].Name(); // last group
		}

		// delete group
		txt1 = GroupList.Path() + _T("\\") + g->Name();
		::RemoveDirectory(txt1);

		// reload group list
		GroupList.SetSelName(name2);
		LoadGroupList();
		return;
	}
}

/////////////////////////////////////////////////////////////////////////////
// new group dialog

INT_PTR CALLBACK NewGroupProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
	case WM_INITDIALOG:
		GroupList.SelName().SetDialogText(hWnd, IDC_NAME);
		return TRUE;

	case WM_COMMAND:
		switch(HIWORD(wParam))
		{
		case 0:
		case 1:
			switch (LOWORD(wParam))
			{
			case IDOK:
				{
					CText txt;
					txt.GetDialogText(hWnd, IDC_NAME);
					txt.Trim();
					txt.FileName(0);
					if (txt.IsNotEmpty())
					{
						GroupList.SetSelName(txt);
						WriteIniTxt("Group", txt);

						txt = DataDir + _T("\\") + txt;
						if (!::CreateDirectory(txt, NULL))
						{
							CText txt2;
							txt.Load(ID_GROUPERR1);
							txt2.Load(ID_GROUPERR2);
							::MessageBox(hWnd, txt2, txt, MB_OK);
						}
						LoadGroupList();
					}
				}
			case IDCANCEL:
				::EndDialog(hWnd, LOWORD(wParam));
				return TRUE;
			}
			break;
		}
		break;
	}
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// new filter dialog

// new graph template
CText NewGraphTemplate(_T(	"TexiGen 100\r\n"
							"# Filter description\r\n"
							"F1 Out 150 50 \"Main\" 0\r\n"));

CWindow NewGraphDialog;
CCheckBox NewGraphDup;

INT_PTR CALLBACK NewFilterProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
	case WM_INITDIALOG:
		GraphList.SelName().SetDialogText(hWnd, IDC_NAME);
		NewGraphDialog.SetHandle(hWnd);
		NewGraphDup.InitDlg(IDC_DUPLICATE, &NewGraphDialog);
		NewGraphDup.SetCheck(ReadIniBool(_T("NewDup"), FALSE));
		return TRUE;

	case WM_COMMAND:
		switch(HIWORD(wParam))
		{
		case 0:
		case 1:
			switch (LOWORD(wParam))
			{
			case IDOK:
				{
					// get entered new name
					CText name, txt, txt2;
					name.GetDialogText(hWnd, IDC_NAME);
					name.Trim();
					name.FileName(0);
					if (name.IsNotEmpty())
					{
						CText nameold = GraphList.SelName();
						if (GraphList.SelInx() < 0) nameold.Empty();
						GraphList.SetSelName(name);
						WriteIniTxt("Graph", name);
						CText filename = GroupList.GraphPath() + _T("\\") + name + _T("." GRAPHEXT);

						// check if the file already exists
						FILE* f = _tfopen(filename, _T("rb"));
						if ((f != NULL) || (name == nameold))
						{
							if (f != NULL) fclose(f);
							txt2.Load(ID_GRAPHERR3);
							txt.Load(ID_GRAPHERR1);
							::MessageBox(hWnd, txt2, txt, MB_OK);
							return TRUE;
						}

						// load template
						BOOL dup = NewGraphDup.GetCheck();
						WriteIniBool(_T("NewDup"), dup);
						CText filenameold;
						if (dup)
						{
							filenameold = GroupList.GraphPath() + _T("\\") + nameold + _T("." GRAPHEXT);
							if (!txt.LoadFileName(filenameold)) txt = NewGraphTemplate;
						}
						else
							txt = NewGraphTemplate;
						
						// save new file
						if (txt.SaveFileName(filename))
						{
							// copy icon
							if (dup)
							{
								CText icon = GroupList.GraphPath() + _T("\\") + name + _T("." PREVEXT);
								CText iconold = GroupList.GraphPath() + _T("\\") + nameold + _T("." PREVEXT);
								::CopyFile(iconold, icon, TRUE);
							}

							// reload graph list
							LoadGraphList();
							::EndDialog(hWnd, IDOK);
							return TRUE;
						}

						// error
						txt2.Load(ID_GRAPHERR2);
						txt.Load(ID_GRAPHERR1);
						::MessageBox(hWnd, txt2, txt, MB_OK);
					}
				}

			// close dialog
			case IDCANCEL:
				::EndDialog(hWnd, IDCANCEL);
				return TRUE;
			}
			break;
		}
		break;
	}
	return FALSE;
}
