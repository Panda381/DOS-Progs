
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                             Editation Variations                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// load default variation (locks FLock)

void LoadDefVar()
{
	FLock.Lock();

	int i;
	CFilterIn* f;
	CFilterValue* fv;
	CFilterColor* fc;
	CFilterImage* fi;

	for (i = 0; i < InFilterNum; i++)
	{
		f = InFilter[i];
		switch (f->Category())
		{
		case FCAT_INVALUE:
			fv = (CFilterValue*)f;
			fv->SetValue(fv->DefValue());
			FGraphUpdate(fv);
			break;

		case FCAT_INCOLOR:
			fc = (CFilterColor*)f;
			fc->Color()->Set(*fc->DefColor());
			FGraphUpdate(fc);
			break;

		default:
			fi = (CFilterImage*)f;
			fi->SetFileName(fi->DefFileName());
			FGraphUpdate(fi);
		}
	}

	FilterReq = TRUE;
	FLock.Unlock();
}

///////////////////////////////////////////////////////////////////////////////
// load list of images

CTextList ImgFileList;

void GenRandVar1(CText name)
{
	WIN32_FIND_DATA fd;
	HANDLE fnd = ::FindFirstFile(name, &fd);
	if (fnd != INVALID_HANDLE_VALUE)
	{
		do {
			name = fd.cFileName;
			ImgFileList.Add(name);
		} while (::FindNextFile(fnd, &fd));
		::FindClose(fnd);
	}
}

///////////////////////////////////////////////////////////////////////////////
// generate random variation (locks FLock)

void GenRandVar()
{
	FLock.Lock();

	int i;
	CFilterIn* f;
	CFilterValue* fv;
	CFilterColor* fc;
	CFilterImage* fi;

	for (i = 0; i < InFilterNum; i++)
	{
		if (!InFilterLock[i])
		{
			f = InFilter[i];
			switch (f->Category())
			{
			// value
			case FCAT_INVALUE:
				fv = (CFilterValue*)f;
				fv->SetValue((real)((int)((real)rand()/RAND_MAX * (fv->Max() - fv->Min())
					+ fv->Min() + (real)0.5 + 1000) - 1000));
				FGraphUpdate(fv);
				break;

			// color
			case FCAT_INCOLOR:
				fc = (CFilterColor*)f;
				fc->Color()->r = (rand() & 0xff) / (real)255;
				fc->Color()->g = (rand() & 0xff) / (real)255;
				fc->Color()->b = (rand() & 0xff) / (real)255;
				FGraphUpdate(fc);
				break;

			// image
			default: // FCAT_INIMAGE
				fi = (CFilterImage*)f;
				if (fi->FileName().IsNotEmpty())
				{
					// prepare find string
					CText name = fi->FileName();
					CText path = name.ExtractPath();
					path.AddBackSlash();
					
					// load list of TGA files
					ImgFileList.DelAll();
					GenRandVar1(path + _T("*.tga"));
					GenRandVar1(path + _T("*.png"));
					GenRandVar1(path + _T("*.bmp"));
					GenRandVar1(path + _T("*.jpg"));
					if (ImgFileList.Num() > 0) fi->SetFileName(path + ImgFileList[rand() % ImgFileList.Num()]);
				}
				break;
			}
		}
	}

	FilterReq = TRUE;
	FLock.Unlock();
}

///////////////////////////////////////////////////////////////////////////////
// mutate variation (locks FLock)

void MutateVar()
{
	FLock.Lock();

	int i;
	real k;
	CFilterIn* f;
	CFilterValue* fv;
	CFilterColor* fc;

#define MUTK (real)0.1

	for (i = 0; i < InFilterNum; i++)
	{
		if (!InFilterLock[i])
		{
			f = InFilter[i];
			switch (f->Category())
			{
			case FCAT_INVALUE:
				fv = (CFilterValue*)f;
				k = (real)((int)(fv->Value() + ((real)rand()/RAND_MAX - (real)0.5)*(fv->Max() - fv->Min())*MUTK + (real)0.5 + 1000) - 1000);
				if (k < fv->Min()) k = fv->Min();
				if (k > fv->Max()) k = fv->Max();
				fv->SetValue(k);
				FGraphUpdate(fv);
				break;

			case FCAT_INCOLOR:
				fc = (CFilterColor*)f;
				fc->Color()->r = ((int)((fc->Color()->r + ((rand() & 0xff)/(real)255 - (real)0.5)*MUTK)*255 + (real)0.5))/(real)255;
				if (fc->Color()->r < 0) fc->Color()->r = 0;
				if (fc->Color()->r > 1) fc->Color()->r = 1;

				fc->Color()->g = ((int)((fc->Color()->g + ((rand() & 0xff)/(real)255 - (real)0.5)*MUTK)*255 + (real)0.5))/(real)255;
				if (fc->Color()->g < 0) fc->Color()->g = 0;
				if (fc->Color()->g > 1) fc->Color()->g = 1;

				fc->Color()->b = ((int)((fc->Color()->b + ((rand() & 0xff)/(real)255 - (real)0.5)*MUTK)*255 + (real)0.5))/(real)255;
				if (fc->Color()->b < 0) fc->Color()->b = 0;
				if (fc->Color()->b > 1) fc->Color()->b = 1;

				FGraphUpdate(fc);
				break;

			default:
				break;
			}
		}
	}

	FilterReq = TRUE;
	FLock.Unlock();
}

///////////////////////////////////////////////////////////////////////////////
// save current variation

void SaveVar()
{
	// path to variaton directory
	CText path = VarList.Path();
	if (path.IsEmpty()) return;

	// create variation directory
	::CreateDirectory(path, NULL);

	// find new name
	CText name;
	CText filename;
	int i = VarList.NextVar();
	for (; i < 10000; i++)
	{
		name.Empty();
		//if (i < 100) name.Add(TCHAR('0'));
		if (i < 10) name.Add(TCHAR('0'));
		name.AddInt(i);
		filename = path + _T("\\") + name + _T("." VAREXT);
		if (!FileExists(filename)) break;
	}

	// create text
	CText txt;
	CText t;
	CFilterIn* f;

	for (i = 0; i < InFilterNum; i++)
	{
		if (i > 0) txt += TCHAR(' ');

		// filter
		f = InFilter[i];
		switch (f->Category())
		{
			// value
		case FCAT_INVALUE:
			txt.AddDouble(((CFilterValue*)f)->Value());
			break;

			// color
		case FCAT_INCOLOR:
			txt.AddColor(((CFilterColor*)f)->Color());
			break;

			// image
		default:
			t = ((CFilterImage*)f)->FileName();
			t.Subst(_T("_"), _T("\""));
			t.Subst(_T(" "), _T("_"));
			if (t.IsEmpty()) t = TCHAR('.');
			txt += t;
			break;
		}
	}

	// save file
	txt.SaveFileName(filename);

	// save preview icon
	SaveIcon(path + _T("\\") + name + _T("." + PREVEXT) /*, MarkVar*/);

	// new selected variation
	VarList.SetSelName(name);
}

///////////////////////////////////////////////////////////////////////////////
// load current variation

void LoadVar()
{
	// load default variation
	LoadDefVar();

	// get current variation entry
	CVarEntry* v = VarList.Selected();
	if (v == NULL) return;

	// load file
	CText txt;
	if (!txt.LoadFileName(v->FileName())) return;

	// split file to words
	CTextList lst;
	lst.Split(txt);

	// lock graph
	FLock.Lock();

	// load parameters
	int i;
	CFilterIn* f;
	CFilterValue* fv;
	CFilterColor* fc;
	CFilterImage* fi;
	CTextList l;

	for (i = 0; i < InFilterNum; i++)
	{
		// get one word
		if (i >= lst.Num()) continue;
		txt = lst[i];
		if (txt.IsEmpty()) continue;

		// filter
		f = InFilter[i];
		switch (f->Category())
		{
			// value
		case FCAT_INVALUE:
			fv = (CFilterValue*)f;
			fv->SetValue((real)txt.Double());
			FGraphUpdate(fv);
			break;

			// color
		case FCAT_INCOLOR:
			fc = (CFilterColor*)f;
			if ((txt.Length() < 9) ||
				(txt.First() != TCHAR('(')) ||
				(txt.Last() != TCHAR(')'))) break;
			txt.DelFirst();
			txt.DelLast();
			l.Split(txt, TCHAR(','));
			if (l.Num() != 4) break;
			fc->Color()->Set((real)(l[0].Double()/255), (real)(l[1].Double()/255), 
				(real)(l[2].Double()/255), (real)(l[3].Double()/255));
			FGraphUpdate(fc);
			break;

			// image
		default:
			fi = (CFilterImage*)f;
			txt.Subst(_T("_"), _T(" "));
			txt.Subst(_T("\""), _T("_"));
			if (txt == _T(".")) txt.Empty();
			fi->SetFileName(txt);
			FGraphUpdate(fi);
			break;
		}
	}

	// unlock graph
	FilterReq = TRUE;
	FLock.Unlock();
}

///////////////////////////////////////////////////////////////////////////////
// callback on lock change

void SelOnLockCB(int inx, BOOL lock)
{
	InFilterLock[inx] = lock;
}

///////////////////////////////////////////////////////////////////////////////
// callback on value change

void SelOnValueCB(int inx, real value)
{
	CFilterValue* f = (CFilterValue*)InFilter[inx];
	f->SetValue(value);

	FGraphRestart();
	FLock.Lock();
	FGraphUpdate(f);
	FilterReq = TRUE;
	FLock.Unlock();

	SelectVar(-1, FALSE);
}

///////////////////////////////////////////////////////////////////////////////
// callback on color change

void SelOnColorCB(int inx, const CColor* col)
{
	CFilterColor* f = (CFilterColor*)InFilter[inx];
	f->Color()->Set(*col);

	FGraphRestart();
	FLock.Lock();
	FGraphUpdate(f);
	FilterReq = TRUE;
	FLock.Unlock();

	SelectVar(-1, FALSE);
}

///////////////////////////////////////////////////////////////////////////////
// callback on filename change

void SelOnImageCB(int inx, CText filename)
{
	CFilterImage* f = (CFilterImage*)InFilter[inx];

	FLock.Lock();
	f->SetFileName(filename);
	FGraphUpdate(f);
	FilterReq = TRUE;
	FLock.Unlock();

	SelectVar(-1, FALSE);
}

///////////////////////////////////////////////////////////////////////////////
// update property controls

void UpdateSelCtrl()
{
	// not select mode
	if (!SelectMode) return;

	// lock window update
	PropFrame.LockUpdate();

	// delete all controls
	PropFrame.DelAll();

	// create controls
	int i;
	CFilterIn* f;
	CFilterValue* fv;
	CFilterColor* fc;
	CFilterImage* fi;
	CPropCtrl* c;
	CText txt;
	for (i = 0; i < InFilterNum; i++)
	{
		// filter
		f = InFilter[i];

		switch (f->Category())
		{
		// value
		case FCAT_INVALUE:
			fv = (CFilterValue*)f;
			c = PropFrame.Add(PROPCT_VALLOCK, fv->Label(), ID_VAR_VALUE);
			if (c != NULL)
			{
				c->SetMinMax(fv->Min(), fv->Max());
				c->SetValue(fv->Value());
				c->SetLock(InFilterLock[i]);
			}
			break;

		// color
		case FCAT_INCOLOR:
			fc = (CFilterColor*)f;
			c = PropFrame.Add(PROPCT_COLRGBLOCK, fc->Label(), ID_VAR_COLOR);
			if (c != NULL)
			{
				c->SetColor(fc->Color());
				c->SetLock(InFilterLock[i]);
			}
			break;

		// image
		default: // FCAT_INIMAGE
			fi = (CFilterImage*)f;
			c = PropFrame.Add(PROPCT_IMGLOCK, fi->Label(), ID_VAR_IMAGE);
			if (c != NULL)
			{
				c->SetImg(fi->FileName());
				c->SetLock(InFilterLock[i]);
			}
			break;
		}
	}

	PropFrame.UnlockUpdate();

	// register callbacks
	PropFrame.SetOnLock(SelOnLockCB);
	PropFrame.SetOnValue(SelOnValueCB);
	PropFrame.SetOnColor(SelOnColorCB);
	PropFrame.SetOnImage(SelOnImageCB);
}

///////////////////////////////////////////////////////////////////////////////
// get variant properties string

CText GetVarProp()
{
	// prepare properties text
	CText txt;
	CText t;
	CFilterIn* f;
	int i;
	for (i = 0; i < InFilterNum; i++)
	{
		if (i > 0) txt += TCHAR(' ');
		f = InFilter[i];
		switch (f->Category())
		{
			// value
		case FCAT_INVALUE:
			txt.AddDouble(((CFilterValue*)f)->Value());
			break;

			// color
		case FCAT_INCOLOR:
			txt.AddColor(((CFilterColor*)f)->Color());
			break;

			// image
		default:
			t = ((CFilterImage*)f)->FileName();
			t.Subst(_T("_"), _T("\""));
			t.Subst(_T(" "), _T("_"));
			txt += t;
			break;
		}
	}
	return txt;
}

///////////////////////////////////////////////////////////////////////////////
// copy variant into clipboard

void CopyVar()
{
	// copy text into clipboard
	TextToClipboard(GetVarProp());
}

///////////////////////////////////////////////////////////////////////////////
// paste variant from clipboard

void PasteVar()
{
	CText txt = TextFromClipboard();
	SetVarProp(txt);
}

///////////////////////////////////////////////////////////////////////////////
// set variant properties string

void SetVarProp(CText txt)
{
	txt.Trim();
	if (txt.IsEmpty()) return;

	// split parameters
	CTextList lst;
	lst.Split(txt);

	// lock graph
	FLock.Lock();

	// load parameters
	int i;
	CFilterIn* f;
	CFilterValue* fv;
	CFilterColor* fc;
	CFilterImage* fi;
	CTextList l;
	CColor c;

	for (i = 0; i < InFilterNum; i++)
	{
		// get one word
		if (i >= lst.Num()) break;
		txt = lst[i];
		if (txt.IsEmpty()) continue;

		// filter
		f = InFilter[i];
		switch (f->Category())
		{
		// value
		case FCAT_INVALUE:
			fv = (CFilterValue*)f;
			if (SelectMode)
				fv->SetValue((real)txt.Double());
			else
				fv->SetDefValue((real)txt.Double());
			FGraphUpdate(fv);
			break;

		// color
		case FCAT_INCOLOR:
			fc = (CFilterColor*)f;
			if ((txt.First() != TCHAR('(')) ||
				(txt.Last() != TCHAR(')')))
			{
				fc->Color()->SetGray((real)txt.Double());
				if (EditMode) fc->DefColor()->SetGray((real)txt.Double());
			}
			else
			{
				txt.DelFirst();
				txt.DelLast();
				l.Split(txt, TCHAR(','));
				if (l.Num() > 0) fc->Color()->r = (real)(l[0].Double()/255);
				if (l.Num() > 1) fc->Color()->g = (real)(l[1].Double()/255);
				if (l.Num() > 2) fc->Color()->b = (real)(l[2].Double()/255);
				if (l.Num() > 3) fc->Color()->a = (real)(l[3].Double()/255);
				if (EditMode) fc->DefColor()->Set(*fc->Color());
			}
			FGraphUpdate(fc);
			break;

			// image
		default:
			fi = (CFilterImage*)f;
			txt.Subst(_T("_"), _T(" "));
			txt.Subst(_T("\""), _T("_"));
			if (SelectMode)
				fi->SetFileName(txt);
			else
				fi->SetDefFileName(txt);
			FGraphUpdate(fi);
			break;
		}
	}

	// unlock graph
	FilterReq = TRUE;
	FLock.Unlock();

	// update
	if (SelectMode)
	{
		VarList.SetSelInx(-1);
		WriteIniTxt("Variation", VarList.SelName());
		UpdateSelCtrl();
		FGraphRestart();
		SPrevRenderStart();
	}
	if (EditMode)
	{
		EditSelFilter(EditCtrlF);
		FGraphRestart();
		EPrevRenderStart();
		SetModi();
	}
}
