
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                             Editation Properties                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

CFilter* EditCtrlF = NULL;			// selected filter (NULL=none)

CText TextConnected;				// text "connected"

///////////////////////////////////////////////////////////////////////////////
// callback on label/image change

void EditOnLabelCB(int inx, CText label)
{
	if (EditCtrlF == NULL) return;
	if (inx == 0)
	{
		if (EditCtrlF->Category() == FCAT_BRICK)
			((CFilterBrick*)EditCtrlF)->SetList(label);
		else if (EditCtrlF->Category() == FCAT_TABLE)
			((CFilterTable*)EditCtrlF)->SetList(label);
		else if (EditCtrlF->Category() == FCAT_OUT)
			((CFilterOut*)EditCtrlF)->SetLabel(label);
		else if (EditCtrlF->Category() == FCAT_INIMAGEDATA)
		{
			((CFilterImageData*)EditCtrlF)->SetFileName(label);
			if (PropFrame.IsValid(2)) PropFrame[2].SetValue(EditCtrlF->Prop(PROP_IMAGE_SQUEEZE)->GetUserValue());
		}
		else
			((CFilterIn*)EditCtrlF)->SetLabel(label);
	}
	else
	{
		CFilterImage* f = (CFilterImage*)EditCtrlF;
		FLock.Lock();
		f->SetDefFileName(label);
		FLock.Unlock();
	}
	EditFilterUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// callback on tiles change

void EditOnTilesCB(int inx, BOOL chk)
{
	if (EditCtrlF == NULL) return;
	if (EditCtrlF->Category() == FCAT_INIMAGEDATA)
		((CFilterImageData*)EditCtrlF)->SetTiled(chk);
	else
		((CFilterImage*)EditCtrlF)->SetTiled(chk);
	EditFilterUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// callback on min/max change

void EditOnMinMaxCB(int inx, int min, int max)
{
	if (EditCtrlF == NULL) return;
	CFilterValue* f = (CFilterValue*)EditCtrlF;
	f->SetMin(min);
	f->SetMax(max);
	if (PropFrame.IsValid(3)) PropFrame[3].SetMinMax(min, max);
	EditFilterUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// callback on min/max value change

void EditOnMinMaxValCB(int inx, real minval, real maxval)
{
	if (EditCtrlF == NULL) return;
	CFilterValue* f = (CFilterValue*)EditCtrlF;
	f->SetMinVal(minval);
	f->SetMaxVal(maxval);
	EditFilterUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// callback on default value change

void EditOnDefValCB(int inx, real value)
{
	if (EditCtrlF == NULL) return;
	CFilterValue* f = (CFilterValue*)EditCtrlF;
	f->SetDefValue(value);
	EditFilterUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// callback on default color change

void EditOnDefColCB(int inx, const CColor* col)
{
	if (EditCtrlF == NULL) return;
	CFilterColor* f = (CFilterColor*)EditCtrlF;
	f->Color()->Set(*col);
	f->DefColor()->Set(*col);
	EditFilterUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// callback on check property change

void EditOnCheckCB(int inx, BOOL chk)
{
	if (EditCtrlF == NULL) return;
	if (((EditCtrlF->Category() == FCAT_BRICK) ||
		(EditCtrlF->Category() == FCAT_TABLE) ||
		(EditCtrlF->Category() == FCAT_OUT)) && (inx > 0)) inx--;
	EditCtrlF->Prop(inx)->SetUserValue((real)(chk ? 1 : 0));
	EditFilterUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// callback on value property change

void EditOnValCB(int inx, real value)
{
	if (EditCtrlF == NULL) return;
	if (((EditCtrlF->Category() == FCAT_BRICK) ||
		(EditCtrlF->Category() == FCAT_TABLE) ||
		(EditCtrlF->Category() == FCAT_OUT)) && (inx > 0)) inx--;
	if ((EditCtrlF->Category() == FCAT_INIMAGEDATA) && (inx > 1)) inx -= 2;

	EditCtrlF->Prop(inx)->SetUserValue(value);
	EditFilterUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// callback on color property change

void EditOnColCB(int inx, const CColor* col)
{
	if (EditCtrlF == NULL) return;
	if (((EditCtrlF->Category() == FCAT_BRICK) ||
		(EditCtrlF->Category() == FCAT_TABLE) ||
		(EditCtrlF->Category() == FCAT_OUT)) && (inx > 0)) inx--;
	EditCtrlF->Prop(inx)->SetColor(*col);
	EditFilterUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// select current filter (NULL=none)

void EditSelFilter(CFilter* f)
{
	// not edit mode
	if (!EditMode) return;

	// lock window update
	PropFrame.LockUpdate();

	// delete all controls
	PropFrame.DelAll();

	// set new filter
	EditCtrlF = f;
	if (!Lock)
	{
		PrevFilter = EditCtrlF;
		EPrevRenderStart();
	}
	if (f == NULL)
	{
		PropFrame.UnlockUpdate();
		return;
	}

	// create filter input controls
	int k = 0;
	CPropCtrl* c;
	CText txt;
	if ((f->Category() >= FCAT_IN_MIN) && (f->Category() <= FCAT_IN_MAX))
	{
		CFilterIn* f2 = (CFilterIn*)f;

		// label
		c = PropFrame.Add(PROPCT_TEXT, ID_IN_LABEL, ID_IN_LABEL2);
		if (c != NULL) c->SetImg(f2->Label());
		PropFrame.SetOnImage(EditOnLabelCB);

		switch (f->Category())
		{
		// value
		case FCAT_INVALUE:
			{
				CFilterValue* f3 = (CFilterValue*)f2;

				// value min/max
				c = PropFrame.Add(PROPCT_MIN, ID_CTRL_MIN, ID_CTRL_MIN2);
				if (c != NULL)
				{
					c->SetMinEdit(f3->Min());
					c->SetMaxEdit(f3->Max());
				}

				// value min/max value
				c = PropFrame.Add(PROPCT_MINVAL, ID_CTRL_MINVAL, ID_CTRL_MINVAL2);
				if (c != NULL)
				{
					c->SetMinValEdit(f3->MinVal());
					c->SetMaxValEdit(f3->MaxVal());
				}

				// default value
				c = PropFrame.Add(PROPCT_VAL, ID_IN_VALUE, ID_IN_VALUE2);
				if (c != NULL)
				{
					c->SetMinMax(f3->Min(), f3->Max());
					c->SetValue(f3->DefValue());
				}

				PropFrame.SetOnMinMax(EditOnMinMaxCB);
				PropFrame.SetOnMinMaxVal(EditOnMinMaxValCB);
				PropFrame.SetOnValue(EditOnDefValCB);
			}
			break;

		// color
		case FCAT_INCOLOR:
			{
				CFilterColor* f3 = (CFilterColor*)f2;
				c = PropFrame.Add(PROPCT_COL, ID_IN_COLOR, ID_IN_COLOR2);
				if (c != NULL) c->SetColor(f3->DefColor());

				PropFrame.SetOnColor(EditOnDefColCB);
			}
			break;

		// image
		default:
			{
				CFilterImage* f3 = (CFilterImage*)f2;
				c = PropFrame.Add(PROPCT_IMG, ID_IN_IMAGE, ID_IN_IMAGE2);
				if (c != NULL) c->SetImg(f3->DefFileName());

				c = PropFrame.Add(PROPCT_TILES, IDS_TILES_TITLE, ID_CTRL_TILES);
				if (c != NULL) c->SetSwitch(f3->Tiled());

				PropFrame.SetOnSwitch(EditOnTilesCB);
			}
		}

		// unlock window update
		PropFrame.UnlockUpdate();
		return;
	}

	// create filter image data controls
	if (f->Category() == FCAT_INIMAGEDATA)
	{
		CFilterImageData* f2 = (CFilterImageData*)f;
		k = 2;

		c = PropFrame.Add(PROPCT_IMG, ID_IN_IMAGE, ID_IN_IMAGE2);
		if (c != NULL) c->SetImg(f2->FileName());
		PropFrame.SetOnImage(EditOnLabelCB);

		c = PropFrame.Add(PROPCT_TILES, IDS_TILES_TITLE, ID_CTRL_TILES);
		if (c != NULL) c->SetSwitch(f2->Tiled());
		PropFrame.SetOnSwitch(EditOnTilesCB);
	}

	// create filter output controls
	if (f->Category() == FCAT_OUT)
	{
		CFilterOut* f2 = (CFilterOut*)f;
		k = 1;

		// label
		c = PropFrame.Add(PROPCT_TEXT, ID_OUT_LABEL, ID_OUT_LABEL2);
		if (c != NULL) c->SetImg(f2->Label());
		PropFrame.SetOnImage(EditOnLabelCB);
	}

	// create filter table controls
	if (f->Category() == FCAT_TABLE)
	{
		CFilterTable* f2 = (CFilterTable*)f;
		k = 1;

		// label
		c = PropFrame.Add(PROPCT_TEXT, ID_TABLE_LABEL, ID_TABLE_LABEL2);
		if (c != NULL) c->SetImg(f2->List());
		PropFrame.SetOnImage(EditOnLabelCB);
	}

	// create filter bricks
	if (f->Category() == FCAT_BRICK)
	{
		CFilterBrick* f2 = (CFilterBrick*)f;
		k = 1;

		// label
		c = PropFrame.Add(PROPCT_TEXT, ID_BRICK_LABEL, ID_BRICK_LABEL2);
		if (c != NULL) c->SetImg(f2->List());
		PropFrame.SetOnImage(EditOnLabelCB);
	}

	// create property controls
	CProperty* p;
	int n = f->PropNum();
	int i;
	for (i = 0; i < n; i++)
	{
		// property
		p = f->Prop(i);

		// property is connected (or linear default filter)
		if (p->Filter() != NULL)
		{
			c = PropFrame.Add(PROPCT_INFO, p->Name(), p->ToolID());
			if (c != NULL)
			{
				txt = (p->Filter() == &FLinear) ? CText(_T("LINEAR")) : TextConnected;
				c->SetInfo(txt);
			}
		}
		else
		{
			switch (p->Category())
			{
			// check
			case PCAT_CHECK:
				c = PropFrame.Add(PROPCT_CHK, p->Name(), p->ToolID());
				if (c != NULL) c->SetSwitch(p->GetUserValue() >= (real)0.5);
				PropFrame.SetOnSwitch(EditOnCheckCB);
				break;

			// enum
			case PCAT_ENUM:
				c = PropFrame.Add(PROPCT_ENUM, p->Name(), p->ToolID());
				if (c != NULL)
				{
					c->SetEnum(p->Enum(), p->EnumNum());
					c->SetValue(p->GetUserValue());
					PropFrame.SetOnValue(EditOnValCB);
				}
				break;

			// value
			case PCAT_CURVE:
			case PCAT_VAL:
				c = PropFrame.Add(PROPCT_VAL, p->Name(), p->ToolID());
				if (c != NULL)
				{
					c->SetMinMax(p->Min(), p->Max());
					c->SetValue(p->GetUserValue());
					PropFrame.SetOnValue(EditOnValCB);
				}
				break;

			// color
			case PCAT_GRAD:
			case PCAT_COLOR:
			case PCAT_LOOPBEGIN:
			case PCAT_LOOPEND:
				c = PropFrame.Add(PROPCT_COL, p->Name(), p->ToolID());
				if (c != NULL)
				{
					CColor col;
					p->Color(&col);
					c->SetColor(&col);
					PropFrame.SetOnColor(EditOnColCB);
				}
				break;
			}
		}
	}

	// unlock window update
	PropFrame.UnlockUpdate();
}

///////////////////////////////////////////////////////////////////////////////
// copy filter parameters into clipboard

void CopyParEdit()
{
	// selected filter
	CFilter* f = EditCtrlF;
	if (f == NULL) return;

	// prepare properties text
	int i;
	CProperty* p;
	CColor c;
	CText txt;
	for (i = 0; i < f->PropNum(); i++)
	{
		p = f->Prop(i);
		if (i > 0) txt += TCHAR(' ');

		p->Color(&c);
		if ((c.r == c.g) && (c.r == c.b) && (c.a == 1))
			txt.AddDouble(p->GetUserValue());
		else
			txt.AddColor(&c);
	}

	// copy text into clipboard
	TextToClipboard(txt);
}

///////////////////////////////////////////////////////////////////////////////
// paste filter parameters from clipboard

void PasteParEdit()
{
	// selected filter
	CFilter* f = EditCtrlF;
	if (f == NULL) return;

	// get text from clipboard
	CText txt = TextFromClipboard();
	ParOnLoad(&txt);
	if (txt.IsEmpty()) return;

	// split parameters
	CTextList lst;
	lst.Split(txt);

	// parse parameters
	int i;
	CProperty* p;
	CTextList lstc;
	CColor c;
	for (i = 0; (i < f->PropNum()) && (i < lst.Num()); i++)
	{
		p = f->Prop(i);
		txt = lst[i];

		if ((txt.First() == TCHAR('(')) && (txt.Last() == TCHAR(')')))
		{
			txt.DelFirst();
			txt.DelLast();
			lstc.Split(txt, TCHAR(','));
			p->Color(&c);
			if (lstc.Num() > 0) c.r = (real)(lstc[0].Double()/255);
			if (lstc.Num() > 1) c.g = (real)(lstc[1].Double()/255);
			if (lstc.Num() > 2) c.b = (real)(lstc[2].Double()/255);
			if (lstc.Num() > 3) c.a = (real)(lstc[3].Double()/255);
			p->SetColor(c);
		}
		else
		{
			p->SetUserValue((real)txt.Double());
		}
	}
	EditSelFilter(EditCtrlF);
	EditFilterUpdate();
}
