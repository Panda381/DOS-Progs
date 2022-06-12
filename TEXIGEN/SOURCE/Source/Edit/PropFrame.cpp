
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                               Property Frame                              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define PROPCY	4					// first property position Y
#define PROPCDY	20					// property Y delta
#define PROPCDX	4					// gap between controls
#define PROPCW1	80					// property title width
#define PROPCEH	17					// height of edit control
#define PROPCLH 18					// height of label control
#define PROPCBH 17					// height of button control
#define PROPCMW	217					// property maximal width

#define PROPCVW	50					// value edit width
#define PROPCUW	17					// up/down button width
#define PROPCSW	(PROPCMW - 2*PROPCUW - 2*PROPCDX - PROPCVW) // slider width

#define PROPCCW	36					// color picture width
#define PROPCCH 14					// color picture height
#define PROPCCM	2					// color margin
#define PROPCCW1 (PROPCCW+2*PROPCCM) // color button width
#define PROPCCH1 (PROPCCH+2*PROPCCM) // color button height
#define PROPCCW2 12					// color text width
#define PROPCCW3 30					// color edit width

#define PROPCNW	60					// min and max edit
#define PROPCNW2 (PROPCMW - 2*PROPCNW - PROPCDX) // max label

// Property frame global variable
CPropFrame PropFrame;

CText	ColRGBAName[4] = { _T("R"), _T("G"), _T("B"), _T("A") };
int 	ColRGBAId[4] = { ID_CTRL_COLORR, ID_CTRL_COLORG, ID_CTRL_COLORB, ID_CTRL_COLORA };

///////////////////////////////////////////////////////////////////////////////
// update color button image

void CPropCtrl::UpdateColBtnImg(u32 color)
{
	// create bitmap
	HDC dc = ::GetDC(m_CColor.Handle());
	HDC dc2 = ::CreateCompatibleDC(dc);
	HBITMAP b = ::CreateCompatibleBitmap(dc, PROPCCW, PROPCCH);
	HBITMAP b2 = (HBITMAP)::SelectObject(dc2, b);

	// draw rectangle
	HBRUSH brush = ::CreateSolidBrush(color & 0xffffff);
	RECT rc;
	rc.left = 0;
	rc.top = 0;
	rc.right = PROPCCW;
	rc.bottom = PROPCCH;
	::FillRect(dc2, &rc, brush);

	// destroy objects
	::DeleteObject(brush);
	::SelectObject(dc2, b2);
	::DeleteDC(dc2);
	::ReleaseDC(m_CColor.Handle(), dc);

	// set new bitmap
	HANDLE old = m_CColor.Image();
	m_CColor.SetImage(b);
	::DeleteObject(old);
}

///////////////////////////////////////////////////////////////////////////////
// create control (return FALSE on error)

BOOL CPropCtrl::Create(int index, CFrame* parent, PROPCT type, CText label, int labid)
{
	// save parameters
	m_Index = index;
	m_Parent = parent;
	m_Type = type;
	m_UseLock = (type == PROPCT_VALLOCK) || (type == PROPCT_COLLOCK) || (type == PROPCT_COLRGBLOCK) || (type == PROPCT_IMGLOCK);
	label += TCHAR(':');

	// set property index
	int i;
	m_Lock.SetPropInx(index);
	m_VSlider.SetPropInx(index);
	m_EDrop.SetPropInx(index);
	m_VValue.SetPropInx(index);
	m_VDown.SetPropInx(index);
	m_VUp.SetPropInx(index);
	m_CColor.SetPropInx(index);
	for (i = 0; i < 4; i++) m_CEdit[i].SetPropInx(index);
	m_IEdit.SetPropInx(index);
	m_IClear.SetPropInx(index);
	m_IBrowse.SetPropInx(index);
	m_SSwitch.SetPropInx(index);
	m_MMinEdit.SetPropInx(index);
	m_MMaxEdit.SetPropInx(index);

	// Y coordinate
	int y = PROPCY + index*PROPCDY;

	// create lock
	if (m_UseLock)
	{
		m_Lock.CreateChk(EmptyText, 2, y, FALSE, FALSE, 12, PROPCEH, parent);
		m_Lock.SetId(ID_CTRL_LOCK);
		MainFrame->ToolTip()->Add(&m_Lock);

		// create label
		m_Label.CreateRight(label, 14, y+1, PROPCW1 - 14, PROPCLH, parent);
	}
	else
		m_Label.CreateRight(label, 0, y+1, PROPCW1, PROPCLH, parent);

	m_Label.SetId(labid);
	MainFrame->ToolTip()->Add(&m_Label);

	// create controls
	int x = PROPCW1 + PROPCDX;
	int k = 4;
	switch (type)
	{
	// info
	case PROPCT_INFO:

		// info text
		m_Info.CreateLeft(EmptyText, x, y+1, PROPCMW, PROPCLH, parent);
		break;

	// enumeration
	case PROPCT_ENUM:

		// drop box
		m_EDrop.CreateLst(x, y-1, PROPCSW, 200, FALSE, parent);
		m_EDrop.SetId(ID_CTRL_ENUM);
		MainFrame->ToolTip()->Add(&m_EDrop);
		goto PROPCREATE;

	// value
	case PROPCT_VAL:
	case PROPCT_VALLOCK:

		// slider
		m_VSlider.CreateLowSlider(x, y+1, PROPCSW, 16, parent);
		m_VSlider.SetThumbLength(12);
		m_VSlider.SetRange(0, 100);
		m_VSlider.SetPage(10);
		m_VSlider.SetId(ID_CTRL_VALUE);
		MainFrame->ToolTip()->Add(&m_VSlider);

		// edit
PROPCREATE:
		x += PROPCSW + PROPCDX;
		m_VValue.CreateEdit(x, y, PROPCVW, TRUE, PROPCEH, parent);
		m_VValue.SetId(ID_CTRL_VALUE2);
		MainFrame->ToolTip()->Add(&m_VValue);

		// spin down
		x += PROPCVW + PROPCDX;
		m_VDown.CreateBtnPic(IDB_LEFT, x, y, FALSE, FALSE, PROPCUW, PROPCBH, TRUE, parent);
		m_VDown.SetId(ID_CTRL_VALUE3);
		MainFrame->ToolTip()->Add(&m_VDown);

		// spin up
		x += PROPCUW;
		m_VUp.CreateBtnPic(IDB_RIGHT, x, y, FALSE, FALSE, PROPCUW, PROPCBH, TRUE, parent);
		m_VUp.SetId(ID_CTRL_VALUE4);
		MainFrame->ToolTip()->Add(&m_VUp);
		break;

	// color
	case PROPCT_COLRGB:
	case PROPCT_COLRGBLOCK:
		k = 3;

	case PROPCT_COL:
	case PROPCT_COLLOCK:

		// button
		m_CColor.CreateBtnPic(NULL, x, y, FALSE, TRUE, PROPCCW1, PROPCCH1, parent);
		m_CColor.SetId(ID_CTRL_COLOR);
		MainFrame->ToolTip()->Add(&m_CColor);
		x += PROPCCW1; 

		// color components
		for (i = 0; i < k; i++)
		{
			m_CLabel[i].CreateRight(ColRGBAName[i], x, y+1, PROPCCW2, PROPCLH, parent);
			x += PROPCCW2 + 2;
			m_CEdit[i].CreateEdit(x, y, PROPCCW3, TRUE, PROPCEH, parent);
			m_CEdit[i].SetId(ColRGBAId[i]);
			MainFrame->ToolTip()->Add(&m_CEdit[i]);
			x += PROPCCW3;
		}
		break;

	// text
	case PROPCT_TEXT:

		// edit
		m_IEdit.CreateEdit(x, y, PROPCMW, TRUE, PROPCEH, parent);
		m_IEdit.SetId(ID_CTRL_TEXT);
		m_IEdit.Enable(TRUE);
		MainFrame->ToolTip()->Add(&m_IEdit);
		break;

	// image
	case PROPCT_IMG:
	case PROPCT_IMGLOCK:

		// edit
		m_IEdit.CreateEdit(x, y, PROPCMW-2*PROPCUW-1, TRUE, PROPCEH, parent);
		m_IEdit.SetId(ID_CTRL_IMAGE);
		m_IEdit.Enable(FALSE);
		MainFrame->ToolTip()->Add(&m_IEdit);
		x += PROPCMW-2*PROPCUW;

		// browse
		m_IClear.CreateBtn(_T("x"), x, y, FALSE, FALSE, PROPCUW, PROPCBH, parent);
		m_IClear.SetId(ID_CTRL_IMAGE3);
		MainFrame->ToolTip()->Add(&m_IClear);
		x += PROPCUW;

		// browse
		m_IBrowse.CreateBtn(_T("..."), x, y, FALSE, FALSE, PROPCUW, PROPCBH, parent);
		m_IBrowse.SetId(ID_CTRL_IMAGE2);
		MainFrame->ToolTip()->Add(&m_IBrowse);
		break;

	// switch
	case PROPCT_CHK:
	case PROPCT_TILES:

		// check
		m_SSwitch.CreateChk(EmptyText, x, y, FALSE, FALSE, 12, PROPCEH, parent);
		m_SSwitch.SetId((type == PROPCT_TILES) ? ID_CTRL_TILES : ID_CTRL_SWITCH);
		MainFrame->ToolTip()->Add(&m_SSwitch);
		break;

	// min/max
	case PROPCT_MIN:

		// minimum edit
		m_MMinEdit.CreateEdit(x, y, PROPCNW, TRUE, PROPCEH, parent);
		m_MMinEdit.SetId(ID_CTRL_MIN2);
		MainFrame->ToolTip()->Add(&m_MMinEdit);

		// maximum label
		x += PROPCNW;
		m_MMaxLabel.CreateRight(ID_CTRL_MAX, x, y+1, PROPCNW2, PROPCLH, parent);
		m_MMaxLabel.SetId(ID_CTRL_MAX2);
		MainFrame->ToolTip()->Add(&m_MMaxLabel);

		// maximum edit
		x += PROPCNW2 + PROPCDX;
		m_MMaxEdit.CreateEdit(x, y, PROPCNW, TRUE, PROPCEH, parent);
		m_MMaxEdit.SetId(ID_CTRL_MAX2);
		MainFrame->ToolTip()->Add(&m_MMaxEdit);
		break;

	// min/max value
	case PROPCT_MINVAL:

		// minimum edit
		m_MMinEdit.CreateEdit(x, y, PROPCNW, TRUE, PROPCEH, parent);
		m_MMinEdit.SetId(ID_CTRL_MINVAL2);
		MainFrame->ToolTip()->Add(&m_MMinEdit);

		// maximum label
		x += PROPCNW;
		m_MMaxLabel.CreateRight(ID_CTRL_MAXVAL, x, y+1, PROPCNW2, PROPCLH, parent);
		m_MMaxLabel.SetId(ID_CTRL_MAXVAL2);
		MainFrame->ToolTip()->Add(&m_MMaxLabel);

		// maximum edit
		x += PROPCNW2 + PROPCDX;
		m_MMaxEdit.CreateEdit(x, y, PROPCNW, TRUE, PROPCEH, parent);
		m_MMaxEdit.SetId(ID_CTRL_MAXVAL2);
		MainFrame->ToolTip()->Add(&m_MMaxEdit);
		break;
	}

	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// set value control minimum and maximum (default 0 and 100)

void CPropCtrl::SetMinMax(int min, int max)
{
	m_VSlider.SetRange(min, max);
	int m = (max - min + 5)/10;
	if (m < 1) m = 1;
	m_VSlider.SetPage(m);
	int n = (int)(m_Value + 1000 + (real)0.5) - 1000;
	m_VSlider.SetPos(n);
}

///////////////////////////////////////////////////////////////////////////////
// set enumeration list

void CPropCtrl::SetEnum(const CText lst[], int num)
{
	m_EDrop.DelAll();
	int i;
	for (i = 0; i < num; i++) m_EDrop.Add(lst[i]);
}

///////////////////////////////////////////////////////////////////////////////
// set enumeration list (entries separated with "|" character)

void CPropCtrl::SetEnum(const CText& text)
{
	m_EDrop.DelAll();
	CTextList lst;
	lst.Split(text, TCHAR('|'));
	int i;
	for (i = 0; i < lst.Num(); i++) m_EDrop.Add(lst[i]);
}

///////////////////////////////////////////////////////////////////////////////
// set value of value control

void CPropCtrl::SetValue(real val, CWindow* except /*= NULL*/)
{
	m_Value = val;
	int n = (int)(val + 1000 + (real)0.5) - 1000;
	if (except != (CWindow*)&m_VSlider) m_VSlider.SetPos(n);
	if (except != (CWindow*)&m_VValue) m_VValue.SetNum(val);
	if (except != (CWindow*)&m_EDrop) m_EDrop.SetSelect(n);
}

///////////////////////////////////////////////////////////////////////////////
// set color

void CPropCtrl::SetColor(CColor* col, CWindow* except /*= NULL*/)
{
	m_Color.Set(*col);
	this->UpdateColBtnImg(col->GetRGB());
	if (except != (CWindow*)&m_CEdit[0]) m_CEdit[0].SetNum(col->r * 255);
	if (except != (CWindow*)&m_CEdit[1]) m_CEdit[1].SetNum(col->g * 255);
	if (except != (CWindow*)&m_CEdit[2]) m_CEdit[2].SetNum(col->b * 255);
	if (except != (CWindow*)&m_CEdit[3]) m_CEdit[3].SetNum(col->a * 255);
}

///////////////////////////////////////////////////////////////////////////////
// set image filename/text

void CPropCtrl::SetImg(const CText& text, CWindow* except /*= NULL*/)
{
	m_FileName = text;
	if (except != (CWindow*)&m_IEdit) m_IEdit.SetText(text);
}

///////////////////////////////////////////////////////////////////////////////
// move control

void CPropCtrl::Move(int y)
{
	if (m_UseLock)
	{
		m_Lock.Move(2, y);
		m_Label.Move(14, y+1);
	}
	else
		m_Label.Move(0, y+1);

	int x = PROPCW1 + PROPCDX;
	int i;
	switch (m_Type)
	{
	case PROPCT_INFO:
		m_Info.Move(x, y+1);
		break;

	case PROPCT_ENUM:
		m_EDrop.Move(x, y-1);
		goto PROPMOVE;

	case PROPCT_VAL:
	case PROPCT_VALLOCK:
		m_VSlider.Move(x, y+1);
PROPMOVE:
		x += PROPCSW + PROPCDX;
		m_VValue.Move(x, y);
		x += PROPCVW + PROPCDX;
		m_VDown.Move(x, y);
		x += PROPCUW;
		m_VUp.Move(x, y);
		break;

	case PROPCT_COL:
	case PROPCT_COLRGB:
	case PROPCT_COLLOCK:
	case PROPCT_COLRGBLOCK:
		m_CColor.Move(x, y);
		x += PROPCCW1; 
		for (i = 0; i < 4; i++)
		{
			m_CLabel[i].Move(x, y+1);
			x += PROPCCW2 + 2;
			m_CEdit[i].Move(x, y);
			x += PROPCCW3;
		}
		break;

	case PROPCT_TEXT:
		m_IEdit.Move(x, y);
		break;

	case PROPCT_IMG:
	case PROPCT_IMGLOCK:
		m_IEdit.Move(x, y);
		x += PROPCMW-2*PROPCUW;
		m_IClear.Move(x, y);
		x += PROPCUW;
		m_IBrowse.Move(x, y);
		break;

	case PROPCT_CHK:
	case PROPCT_TILES:
		m_SSwitch.Move(x, y);
		break;

	case PROPCT_MIN:
	case PROPCT_MINVAL:
		m_MMinEdit.Move(x, y);
		x += PROPCNW;
		m_MMaxLabel.Move(x, y+1);
		x += PROPCNW2 + PROPCDX;
		m_MMaxEdit.Move(x, y);
		break;
	}
}

///////////////////////////////////////////////////////////////////////////////
// destroy control

void CPropCtrl::Destroy()
{
	MainFrame->ToolTip()->Del(&m_Lock);
	m_Lock.Destroy();
	MainFrame->ToolTip()->Del(&m_Label);
	m_Label.Destroy();
	m_Info.Destroy();

	// value/enumeration controls
	MainFrame->ToolTip()->Del(&m_VSlider);
	m_VSlider.Destroy();
	MainFrame->ToolTip()->Del(&m_EDrop);
	m_EDrop.Destroy();
	MainFrame->ToolTip()->Del(&m_VValue);
	m_VValue.Destroy();
	MainFrame->ToolTip()->Del(&m_VDown);
	m_VDown.Destroy();
	MainFrame->ToolTip()->Del(&m_VUp);
	m_VUp.Destroy();

	// color controls
	m_CColor.Destroy();
	int i;
	for (i = 0; i < 4; i++)
	{
		m_CLabel[i].Destroy();
		MainFrame->ToolTip()->Del(&m_CEdit[i]);
		m_CEdit[i].Destroy();
	}

	// image controls
	MainFrame->ToolTip()->Del(&m_IEdit);
	m_IEdit.Destroy();
	MainFrame->ToolTip()->Del(&m_IClear);
	m_IClear.Destroy();
	MainFrame->ToolTip()->Del(&m_IBrowse);
	m_IBrowse.Destroy();

	// switch control
	MainFrame->ToolTip()->Del(&m_SSwitch);
	m_SSwitch.Destroy();

	// min/max control
	MainFrame->ToolTip()->Del(&m_MMinEdit);
	m_MMinEdit.Destroy();
	MainFrame->ToolTip()->Del(&m_MMaxLabel);
	m_MMaxLabel.Destroy();
	MainFrame->ToolTip()->Del(&m_MMaxEdit);
	m_MMaxEdit.Destroy();
}

///////////////////////////////////////////////////////////////////////////////
// scroll frame content to new position

void CPropFrame::Scroll()
{
	this->LockUpdate();
	int i;
	for (i = 0; i < this->Num(); i++) m_List[i].Move(PROPCY + i*PROPCDY - m_VTop);
	this->UnlockUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// update frame virtual height

void CPropFrame::UpdateVHeight()
{
	// prepare virtual height
	int h = this->Num() * PROPCDY + PROPCY + 10;
	int page = m_Rect.Height();
	if (h < page) h = page;
	m_VHeight = h;

	// set scroller
	int max = h - page;
	if (max > 0)
	{
		m_Scroller.Enable(TRUE);
		m_Scroller.SetRange(0, max, page, TRUE);
	}

	// new top
	if (m_VTop > max)
	{
		m_VTop = max;
		this->Scroll();
		m_Scroller.SetPos(m_VTop);
	}
	if (max == 0) m_Scroller.Enable(FALSE);
}

///////////////////////////////////////////////////////////////////////////////
// invert all locks

void CPropFrame::LockInv()
{
	this->LockUpdate();
	int i;
	for (i = 0; i < this->Num(); i++)
	{
		CPropCtrl* p = &m_List[i];
		if (p->UseLock())
		{
			BOOL lock = !p->GetLock();
			p->SetLock(lock);
			if (m_OnLock != NULL) m_OnLock(i, lock);
		}
	}
	this->UnlockUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// on command message (returns TRUE if message was processed)

BOOL CPropFrame::OnCommand(CWindow* w, int id)
{
	// get property control
	if (w->Filling()) return FALSE;
	int inx = w->PropInx();
	if ((DWORD)inx >= (DWORD)this->Num()) return FALSE;
	CPropCtrl* p = &m_List[inx];
	int k;

	// parse command
	switch (id)
	{
	// property lock
	case ID_CTRL_LOCK:
		{
			BOOL lock = !p->GetLock();
			p->SetLock(lock);
			if (m_OnLock != NULL) m_OnLock(inx, lock);
		}
		return TRUE;

	// value slider
	case ID_CTRL_VALUE:
		{
			real val = (real)p->GetValueSlider();
			p->SetValue(val, w);
			if (m_OnValue != NULL) m_OnValue(inx, val);
		}
		return TRUE;

	// edit value
	case ID_CTRL_VALUE2:
		{
			real val = p->GetValueEdit();
			p->SetValue(val, w);
			if (m_OnValue != NULL) m_OnValue(inx, val);
		}
		return TRUE;

	// spin down/up
	case ID_CTRL_VALUE3:
		k = -1;
		goto SETCTRLVALUE;

	case ID_CTRL_VALUE4:
		k = 1;
SETCTRLVALUE:
		{
			real val = p->GetValue() + k;
			p->SetValue(val, w);
			if (m_OnValue != NULL) m_OnValue(inx, val);
		}
		return TRUE;

	// set color with button
	case ID_CTRL_COLOR:
		{
			CColor col;
			p->GetColor(&col);
			ColorSel.SetColor(col.GetRGB());

			if (ColorSel.Execute(MainFrame))
			{
				col.SetRGB(ColorSel.Color());
				p->SetColor(&col, w);
				if (m_OnColor != NULL) m_OnColor(inx, &col);
			}
		}
		return TRUE;

	// set color R
	case ID_CTRL_COLORR:
		{
			CColor col;
			p->GetColor(&col);
			col.r = p->GetColorEdit(0);
			p->SetColor(&col, w);
			if (m_OnColor != NULL) m_OnColor(inx, &col);
		}
		return TRUE;

	// set color G
	case ID_CTRL_COLORG:
		{
			CColor col;
			p->GetColor(&col);
			col.g = p->GetColorEdit(1);
			p->SetColor(&col, w);
			if (m_OnColor != NULL) m_OnColor(inx, &col);
		}
		return TRUE;

	// set color B
	case ID_CTRL_COLORB:
		{
			CColor col;
			p->GetColor(&col);
			col.b = p->GetColorEdit(2);
			p->SetColor(&col, w);
			if (m_OnColor != NULL) m_OnColor(inx, &col);
		}
		return TRUE;

	// set color A
	case ID_CTRL_COLORA:
		{
			CColor col;
			p->GetColor(&col);
			col.a = p->GetColorEdit(3);
			p->SetColor(&col, w);
			if (m_OnColor != NULL) m_OnColor(inx, &col);
		}
		return TRUE;

	// switch
	case ID_CTRL_SWITCH:
	case ID_CTRL_TILES:
		{
			BOOL on = !p->GetSwitch();
			p->SetSwitch(on);
			if (m_OnSwitch != NULL) m_OnSwitch(inx, on);
		}
		return TRUE;

	// clear filename
	case ID_CTRL_IMAGE3:
		{
			p->SetImg(EmptyText, w);
			if (m_OnImage != NULL) m_OnImage(inx, EmptyText);
		}
		return TRUE;

	// browse filename
	case ID_CTRL_IMAGE2:
		{
			CText txt = GetSaveLoadFile(IDS_PICMASK2, _T("tga"), p->GetImg(), MainFrame, FALSE);
			if (txt.IsNotEmpty())
			{
				p->SetImg(txt, w);
				if (m_OnImage != NULL) m_OnImage(inx, txt);
			}
		}
		return TRUE;

	// text
	case ID_CTRL_TEXT:
		{
			CText txt = p->GetImgEdit();
			p->SetImg(txt, w);
			if (m_OnImage != NULL) m_OnImage(inx, txt);
		}
		return TRUE;

	// minimum/maximum
	case ID_CTRL_MIN2:
	case ID_CTRL_MAX2:
		{
			int min = p->GetMinEdit();
			int max = p->GetMaxEdit();
			if (m_OnMinMax != NULL) m_OnMinMax(inx, min, max);
		}
		return TRUE;

	// minimum/maximum value
	case ID_CTRL_MINVAL2:
	case ID_CTRL_MAXVAL2:
		{
			real minval = p->GetMinValEdit();
			real maxval = p->GetMaxValEdit();
			if (m_OnMinMaxVal != NULL) m_OnMinMaxVal(inx, minval, maxval);
		}
		return TRUE;

	// enumeration
	case ID_CTRL_ENUM:
		{
			real val = (real)p->GetValueEnum();
			p->SetValue(val, w);
			if (m_OnValue != NULL) m_OnValue(inx, val);
		}
		return TRUE;
	}
	return FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// on scroller message (returns TRUE if message was processed)

BOOL CPropFrame::OnScroller(HWND wnd, WPARAM wParam)
{
	// check message validity
	if ((wnd != m_Scroller.Handle()) || m_Scroller.Filling()) return FALSE;

	// service message
	if (m_Scroller.OnMsg(wParam, PROPCDY))
	{
		m_VTop = m_Scroller.GetPos();
		this->Scroll();
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// move frame

void CPropFrame::Move(int x, int y, int w, int h)
{
	m_Rect.Set(x, y, w, h);
	if (m_Frame.IsValid())
	{
		m_Frame.MoveResize(x, y, w-VIEWSCROLLERW, h);
		m_Scroller.MoveResize(x+w-VIEWSCROLLERW, y, VIEWSCROLLERW, h);
		this->UpdateVHeight();
	}
}

///////////////////////////////////////////////////////////////////////////////
// show frame

void CPropFrame::Show()
{
	// create frame
	if (!m_Frame.IsValid())
	{
		int x = m_Rect.left;
		int y = m_Rect.top;
		int w = m_Rect.Width();
		int h = m_Rect.Height();
		m_Frame.CreateFrm(FRAME_NONE, x, y, w-VIEWSCROLLERW, h, MainFrame);
		m_Scroller.CreateVScroll(x+w-VIEWSCROLLERW, y, VIEWSCROLLERW, h, MainFrame);
	}

	// show frame
	this->UpdateVHeight();
}

///////////////////////////////////////////////////////////////////////////////
// hide frame

void CPropFrame::Hide()
{
	this->DelAll();
}

///////////////////////////////////////////////////////////////////////////////
// add control (returns NULL on error)

CPropCtrl* CPropFrame::Add(PROPCT type, CText label, int labid)
{
	int n = m_List.New();
	if (n < 0) return NULL;
	UpdateVHeight();
	CPropCtrl* p = &m_List[n];
	if (!p->Create(n, &this->m_Frame, type, label, labid)) return NULL;
	return p;
}

///////////////////////////////////////////////////////////////////////////////
// constructor

CPropFrame::CPropFrame()
{
	m_OnLock = NULL;
	m_OnValue = NULL;
	m_OnColor = NULL;
	m_OnImage = NULL;
	m_OnSwitch = NULL;
	m_OnMinMax = NULL;
	m_OnMinMaxVal = NULL;
	m_VTop = 0;
}

///////////////////////////////////////////////////////////////////////////////
// delete all controls (and clear all callbacks)

void CPropFrame::DelAll()
{
	int i;
	for (i = m_List.Num()-1; i >= 0; i--) m_List[i].Destroy();
	m_List.DelAll();
	UpdateVHeight();

	m_OnLock = NULL;
	m_OnValue = NULL;
	m_OnColor = NULL;
	m_OnImage = NULL;
	m_OnSwitch = NULL;
	m_OnMinMax = NULL;
	m_OnMinMaxVal = NULL;
}
