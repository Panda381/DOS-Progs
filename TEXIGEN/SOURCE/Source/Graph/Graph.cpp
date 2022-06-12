
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 Filter Graph                              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// Locking filter graph
//
// Lock with render thread:
// - read/render FGraph (it cannot modify structure)
// - read PrevFilter
// - set off m_ReqPrev filter flag
//
// Lock with main thread:
// - modify structure FGraph (need not lock when reading)
// - render FGraph (due to file colisions in CFilterIn)
// - set PrevFilter
// - set on m_ReqPrev filter flag

CLock	FLock;					// filter lock

// filter graph (LOCKED!)
CListCount<CFilter> FGraph;		// filter graph
CText FInfo;					// filter info

// output filters
CFilterOut* OutFilter[OUTMAX];	// output filters
int		OutFilterNum = 0;		// number of output filters
int		OutFilterInx = 0;		// output filter index

// input filters
CFilterIn* InFilter[INMAX];		// input filters
BOOL	 InFilterLock[INMAX];	// locks
int		InFilterNum = 0;		// number of input filters

//BOOL	Anti = TRUE;			// antialiasing

// parse filter graph
int		GraphVer;				// graph version in hundreths
CText	GraphIdent(_T("TexiGen")); // graph identification
CText	GraphFilename;			// current graph filename
CText	GraphText;				// graph content
CTextList GraphRowList;			// list of rows
int		GraphRowInx;			// row index
CText	GraphRowText;			// one row from graph content
CText	GraphRowText0;
CTextList GraphWordList;		// word list
int		GraphWordInx;			// word index

CText	TextLinear(_T("Linear"));

// filter graph view area
int FGraphViewX, FGraphViewY, FGraphViewX2, FGraphViewY2;

// filter graph select area
int FGraphSelX, FGraphSelY, FGraphSelX2, FGraphSelY2;

// filter graph modified
BOOL Modi = FALSE;

///////////////////////////////////////////////////////////////////////////////
// clear filter graph (should be LOCKED!)

void ClearGraph()
{
	FInfo.Empty();

	PrevFilter = NULL;

	while (!FGraph.IsEmpty())
	{
		CFilter* f = FGraph.First();
		FGraph.Delete(f);
		delete f;
	}
	GraphRowInx = 0;
	GraphWordInx = 0;
	OutFilterNum = 0;
	InFilterNum = 0;
}

///////////////////////////////////////////////////////////////////////////////
// clear filter graph with lock

void ClearGraphLock()
{
	FLock.Lock();
	ClearGraph();
	FLock.Unlock();
}

///////////////////////////////////////////////////////////////////////////////
// get view area of filters

void GetGraphView()
{
	FGraphViewX = FMAXPOS;
	FGraphViewY = FMAXPOS;
	FGraphViewX2 = -FMAXPOS;
	FGraphViewY2 = -FMAXPOS;

	CFilter* f;
	int x, y, h;

	ListForEach(f, &FGraph)
	{
		x = f->X();
		if (x < FGraphViewX) FGraphViewX = x;
		x += f->BaseW() + ARROWWIDTH;
		if (x > FGraphViewX2) FGraphViewX2 = x;

		y = f->Y();
		if (y < FGraphViewY) FGraphViewY = y;
		h = f->BaseH() + FILTERTH;
		y += h;
		if (y > FGraphViewY2) FGraphViewY2 = y;
	}

	if ((FGraphViewX > FGraphViewX2) || (FGraphViewY > FGraphViewY2))
	{
		FGraphViewX = 0;
		FGraphViewX2 = 0;
		FGraphViewY = 0;
		FGraphViewY2 = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// get select area of filters

void GetGraphSelect()
{
	FGraphSelX = FMAXPOS;
	FGraphSelY = FMAXPOS;
	FGraphSelX2 = -FMAXPOS;
	FGraphSelY2 = -FMAXPOS;

	CFilter* f;
	int x, y, h;

	ListForEach(f, &FGraph)
	{
		if (f->Selected())
		{
			x = f->X();
			if (x < FGraphSelX) FGraphSelX = x;
			x += f->BaseW() + ARROWWIDTH;
			if (x > FGraphSelX2) FGraphSelX2 = x;

			y = f->Y();
			if (y < FGraphSelY) FGraphSelY = y;
			h = f->BaseH() + FILTERTH;
			y += h;
			if (y > FGraphSelY2) FGraphSelY2 = y;
		}
	}

	if ((FGraphSelX > FGraphSelX2) || (FGraphSelY > FGraphSelY2))
	{
		FGraphSelX = 0;
		FGraphSelX2 = 0;
		FGraphSelY = 0;
		FGraphSelY2 = 0;
	}
}

///////////////////////////////////////////////////////////////////////////////
// find highest selected filter (NULL=none)

CFilter* FindGraphSelect()
{
	CFilter* f;
	ListForEachBack(f, &FGraph)
	{
		if (f->Selected()) return f;
	}
	return NULL;
}

///////////////////////////////////////////////////////////////////////////////
// delete filter (need lock FLock!)

void DelGraphSelect(CFilter* f)
{
	CFilter* f2;
	int i;
	CProperty* p;

	// delete connections
	ListForEach(f2, &FGraph)
	{
		p = f2->Prop(0);
		for (i = f2->PropNum(); i > 0; i--)
		{
			if (p->Filter() == f)
			{
				p->SetFilter(NULL);
				f2->Restart(); // need CFilterWood
			}
			p++;
		}
	}

	// delete filter
	FGraph.Delete(f);
}

///////////////////////////////////////////////////////////////////////////////
// find filter by coordinates (from top, NULL=not found)

CFilter* FindGraphFilter(int x, int y)
{
	CFilter* f;

	ListForEachBack(f, &FGraph)
	{
		if ((x >= f->X()) && (y >= f->Y()) &&
			(x < f->X2()) && (y < f->Y2()))
			return f;
	}
	return NULL;
}

///////////////////////////////////////////////////////////////////////////////
// find filter output by coordinates (from top, NULL=not found)

CFilter* FindGraphOut(int x, int y)
{
	CFilter* f;

	ListForEachBack(f, &FGraph)
	{
		if ((x >= f->OutX() - ARROWDELTA) && (y >= f->OutY() - ARROWDELTA) &&
			(x <= f->OutX() + ARROWDELTA) && (y <= f->OutY() + ARROWDELTA))
			return f;
	}
	return NULL;
}

///////////////////////////////////////////////////////////////////////////////
// find filter by name (NULL=not found)

CFilter* FindGraphName(const CText& name)
{
	CFilter* f;

	ListForEach(f, &FGraph)
	{
		if (f->Name() == name) return f;
	}
	return NULL;
}

///////////////////////////////////////////////////////////////////////////////
// restart all filters

void FGraphRestart()
{
	CFilter* f;
	ListForEach(f, &FGraph)
	{
		f->Restart();
	}
}

///////////////////////////////////////////////////////////////////////////////
// request to update filter preview (with dependent filters; need lock FLock!)

void FGraphUpdate(CFilter* f)
{
	CFilter* f2;
	CProperty* p;
	int i;

	// filter already requested
	if (f->ReqPrev()) return;

	// set request flag
	f->SetReqPrev(TRUE);

	// request to update dependent filters
	ListForEach(f2, &FGraph)
	{
		for (i = 0; i < f2->PropNum(); i++)
		{
			p = f2->Prop(i);
			if (p->Filter() == f)
			{
				FGraphUpdate(f2);
				break;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// create new filter name

CText NewGraphName()
{
	CText name;
	int i = 1;
	do {
		name = TCHAR('F');
		name.AddInt(i++);
	} while (FindGraphName(name) != NULL);
	return name;
}

///////////////////////////////////////////////////////////////////////////////
// find filter property by coordinates (from top, NULL=property not found)

CProperty* FindGraphProperty(int x, int y)
{
	CFilter* f;
	int i, n;

	ListForEachBack(f, &FGraph)
	{
		n = f->PropNum();
		if (n > 0)
		{
			if ((x >= (f->PropX() - ARROWDELTA)) &&
				(x <= (f->PropX() + ARROWDELTA)) &&
				(y >= (f->PropY(n - 1) - FILTERDY)) &&
				(y <= (f->PropY(0) + FILTERDY)))
			{
				i = (f->PropY(0) - y + FILTERDY/2)/FILTERDY;
				if (i < 0) i = 0;
				if (i >= n) i = n - 1;
				return f->Prop(i);
			}
		}
	}
	return NULL;
}

///////////////////////////////////////////////////////////////////////////////
// check filter connection loopback (returns FALSE if connection forbidden)

BOOL GraphCheckLoop(CFilter* src, CFilter* dst)
{
	if (src == dst) return FALSE;
	int i;
	CProperty* p;
	CFilter* f;
	for (i = 0; i < src->PropNum(); i++)
	{
		p = src->Prop(i);
		f = p->Filter();
		if ((f != NULL) && ((p->Category() != PCAT_LOOPEND) || (f->Category() != FCAT_LOOPEND))
				&& ((p->Category() != PCAT_PARTICLE) || (f->Category() != FCAT_PARTICLE)))
		{
			if (!GraphCheckLoop(f, dst)) return FALSE;
		}
	}
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// move selected filters

void MoveGraphFilter(int dx, int dy)
{
	CFilter* f;

	ListForEachBack(f, &FGraph)
	{
		if (f->Selected())
		{
			f->SetX(f->X() + dx);
			f->SetY(f->Y() + dy);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// align filters to grid

void GridGraphFilter()
{
	CFilter* f;

	ListForEach(f, &FGraph)
	{
		f->SetX((f->X() + GRID/2) & ~(GRID-1));
		f->SetY((f->Y() + GRID/2) & ~(GRID-1));
	}
}

///////////////////////////////////////////////////////////////////////////////
// move filter to top of graph

void TopGraphFilter(CFilter* f)
{
	FGraph.Delete(f);
	FGraph.AddLast(f);
}

///////////////////////////////////////////////////////////////////////////////
// unselect all filters

void UnselectGraphFilter()
{
	CFilter* f;

	ListForEach(f, &FGraph)
	{
		f->SetSelected(FALSE);
	}
}

///////////////////////////////////////////////////////////////////////////////
// select filters in range

void SelGraphFilterRange(int x1, int y1, int x2, int y2)
{
	CFilter* f;

	ListForEach(f, &FGraph)
	{
		if ((x1 < f->X2()) && (x2 >= f->X()) &&
			(y1 < f->Y2()) && (y2 >= f->Y()))
			f->SetSelected(TRUE);
	}
}

///////////////////////////////////////////////////////////////////////////////
// get list of output filters

void GetOutFilt()
{
	OutFilterNum = 0;

	// get list of output filters
	CFilter* f;
	ListForEach(f, &FGraph)
	{
		if (f->Category() == FCAT_OUT)
		{
			OutFilter[OutFilterNum++] = (CFilterOut*)f;
			if (OutFilterNum == OUTMAX) break;
		}
	}

	// sort filters by Y coordinate
	int i;
	BOOL ok;
	CFilterOut* fo;
	do {
		ok = FALSE;
		for (i = 0; i < OutFilterNum-1; i++)
		{
			fo = OutFilter[i];
			if (fo->Y() < OutFilter[i+1]->Y())
			{
				OutFilter[i] = OutFilter[i+1];
				OutFilter[i+1] = fo;
				ok = TRUE;
			}
		}
	} while (ok);

	// correction filter index
	if ((OutFilterNum > 0) && (OutFilterInx >= OutFilterNum)) OutFilterInx = OutFilterNum - 1;
}

///////////////////////////////////////////////////////////////////////////////
// get list of input filters

void GetInFilt()
{
	InFilterNum = 0;

	// get list of input filters
	CFilter* f;
	ListForEach(f, &FGraph)
	{
		if ((f->Category() >= FCAT_IN_MIN) &&
			(f->Category() <= FCAT_IN_MAX))
		{
			InFilter[InFilterNum++] = (CFilterIn*)f;
			if (InFilterNum == INMAX) break;
		}
	}

	// sort filters by Y coordinate
	int i;
	BOOL ok;
	CFilterIn* fi;
	do {
		ok = FALSE;
		for (i = 0; i < InFilterNum-1; i++)
		{
			fi = InFilter[i];
			if (fi->Y() < InFilter[i+1]->Y())
			{
				InFilter[i] = InFilter[i+1];
				InFilter[i+1] = fi;
				ok = TRUE;
			}
		}
	} while (ok);
}

///////////////////////////////////////////////////////////////////////////////
// parameters correction before loading

void ParOnLoad(CText* txt)
{
	txt->SubstList(_T("\t\r\n"), _T("   "), 3);
	txt->Trim();
	*txt = _T(" ") + *txt + _T(" ");
	txt->Subst(_T("  "), _T(" "));

	int pos, pos2;
	CText t1, t2, t3;
	int pos0 = 0;
	for (;;)
	{
		pos = txt->Find(_T(" \""), 2, pos0);
		if (pos < 0) break;
		pos2 = txt->Find(_T("\" "), 2, pos+2);
		if (pos2 <= pos) break;

		t1 = txt->Left(pos+2);
		t2 = txt->Mid(pos+2, pos2-pos-2);
		t3 = txt->RightFrom(pos2);
		t2.Subst(_T(" "), _T("\r"));
		*txt = t1 + t2 + t3;
		pos0 = pos2+1;
	}
	txt->Trim();
}

///////////////////////////////////////////////////////////////////////////////
// get one row from graph content (returns FALSE on end of file)

BOOL GetGraphRow()
{
	do {
		// load new row
		if (GraphRowInx >= GraphRowList.Num()) return FALSE;
		GraphRowText = GraphRowList[GraphRowInx];
		GraphRowText0 = GraphRowText;
		GraphRowInx++;

		// text in quotes correction
		ParOnLoad(&GraphRowText);

		// split row to words
		GraphWordList.Split(GraphRowText);
	} while (GraphWordList.Num() == 0);

	// correct text in quotes - stage 2
	int i;
	for (i = 0; i < GraphWordList.Num(); i++)
	{
		if (GraphWordList[i].First() == TCHAR('"'))
			GraphWordList[i].Subst(_T("\r"), _T(" "));
	}

	GraphWordInx = 0;
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// get word from graph row (returns empty on end of row)

CText GetGraphWord()
{
	CText txt;
	if (GraphWordInx < GraphWordList.Num())
	{
		txt = GraphWordList[GraphWordInx];
		GraphWordInx++;
	}
	return txt;
}

///////////////////////////////////////////////////////////////////////////////
// load filter graph (returns FALSE on error, locks filter lock, empty text = no file)

CText TextHighPass(_T("HighPass"));
CText TextTime(_T("Time"));
CText TextBlend(_T("Blend"));

BOOL LoadGraph(const CText& filename)
{
	GraphFilename = filename;

	// lock filter lock
	FLock.Lock();

	Modi = FALSE;

	SetCaption();

	// clear filter graph
	ClearGraph();
	UpdateSelCtrl();
	if (filename.IsEmpty())
	{
		FLock.Unlock();
		return TRUE;
	}

	// load graph
	CText txt1, txt2;
	if (!GraphText.LoadFileName(filename))
	{
		FLock.Unlock();
		txt2.Load(ID_LOADERR2);
		txt1.Format((LPCTSTR)txt2, (LPCTSTR)filename);
		txt2.Load(ID_LOADERR);
		::MessageBox(MainFrame->Handle(), txt1, txt2, MB_OK);
		return FALSE;
	}

	// split to lines
	if (!GraphRowList.SplitLines(GraphText))
	{
		FLock.Unlock();
		return FALSE;
	}
	GraphRowInx = 0;

	// parse file header
	if (!GetGraphRow() || (GetGraphWord() != GraphIdent) || 
		((GraphVer=GetGraphWord().Int()) < 100))
	{
		FLock.Unlock();
		txt2.Load(ID_LOADERR3);
		txt1.Format((LPCTSTR)txt2, (LPCTSTR)filename);
		txt2.Load(ID_LOADERR);
		::MessageBox(MainFrame->Handle(), txt1, txt2, MB_OK);
		return FALSE;
	}

	// parse file - create filters
	CText name, cls;
	int i, x, y;
	CFilter* f;
	FInfo.Empty();
	while (GetGraphRow())
	{
		// filter info
		if (GraphRowText0.First() == TCHAR('#'))
		{
			txt1 = GraphRowText0.RightFrom(1);
			if (txt1.First() == TCHAR(' ')) txt1.DelFirst();
			FInfo += txt1;
			FInfo += NewLine;
			continue;
		}

		// filter name
		name = GetGraphWord();

		// filter class
		cls = GetGraphWord();

		// filter coordinates
		x = GetGraphWord().Int();
		y = GetGraphWord().Int();
		if (x > FMAXPOS) x = FMAXPOS;
		if (x < -FMAXPOS) x = -FMAXPOS;
		if (y > FMAXPOS) y = FMAXPOS;
		if (y < -FMAXPOS) y = -FMAXPOS;

		// check if this label already exists
		f = FindGraphName(name);
		if (f != NULL)
		{
			FLock.Unlock();
			txt2.Load(ID_LOADERR5);
			txt1.Format((LPCTSTR)txt2, (LPCTSTR)filename, GraphRowInx, (LPCTSTR)name);
			txt2.Load(ID_LOADERR);
			::MessageBox(MainFrame->Handle(), txt1, txt2, MB_OK);
			return FALSE;
		}

		// find and create filter class
		for (i = 0; i < TemplateNum; i++)
		{
			if (Template[i]->Class() == cls)
			{
				// create filter
				CFilter* f = Template[i]->Duplicate();
				if (f == NULL)
				{
					FLock.Unlock();
					return FALSE;
				}
				f->SetName(name);
				f->SetX(x);
				f->SetY(y);
				FGraph.AddLast(f);
				break;
			}
		}

		// invalid filter class
		if (i == TemplateNum)
		{
			FLock.Unlock();
			txt2.Load(ID_LOADERR4);
			txt1.Format((LPCTSTR)txt2, (LPCTSTR)filename, GraphRowInx, (LPCTSTR)cls);
			txt2.Load(ID_LOADERR);
			::MessageBox(MainFrame->Handle(), txt1, txt2, MB_OK);
			return FALSE;
		}
	}

	// round two - parse properties
	GraphRowInx = 1;
	f = FGraph.First();
	TCHAR ch;
	CProperty* p;
	CTextList lst;
	CFilter* f2;
	while (GetGraphRow())
	{
		if (GraphRowText0.First() == TCHAR('#')) continue;

		GraphWordInx = 4;

		// import old format filters
		if ((f->Class() == TextHighPass) && (GraphWordList.Num() == 4+4))
		{
			GraphWordList.Add(_T("1"));
			GraphWordList.Add(_T("50"));
		}
		if ((f->Class() == TextTime) && (GraphWordList.Num() == 4+0))
		{
			GraphWordList.Add(TextLinear);
		}
		if ((f->Class() == TextBlend) && (GraphWordList.Num() == 4+4))
		{
			GraphWordList.Add(_T("0"));
		}

		// input filter label
		if ((f->Category() == FCAT_INVALUE) ||
			(f->Category() == FCAT_INCOLOR) ||
			(f->Category() == FCAT_INIMAGE))
		{
			CFilterIn* f3 = (CFilterIn*)f;
			name = GetGraphWord();
			if (name.IsEmpty() ||
				(name.First() != TCHAR('"')) ||
				(name.Last() != TCHAR('"'))) goto ERR_NAME_EMPTY;
			name.DelFirst();
			name.DelLast();
			f3->SetLabel(name);
		}

		// output filter label
		if (f->Category() == FCAT_OUT)
		{
			CFilterOut* f3 = (CFilterOut*)f;
			name = GetGraphWord();
			if (name.IsEmpty() ||
				(name.First() != TCHAR('"')) ||
				(name.Last() != TCHAR('"'))) goto ERR_NAME_EMPTY;
			name.DelFirst();
			name.DelLast();
			f3->SetLabel(name);
		}

		// table filter label
		if (f->Category() == FCAT_TABLE)
		{
			CFilterTable* f3 = (CFilterTable*)f;
			name = GetGraphWord();
			if (name.IsEmpty() ||
				(name.First() != TCHAR('"')) ||
				(name.Last() != TCHAR('"'))) goto ERR_NAME_EMPTY;
			name.DelFirst();
			name.DelLast();
			f3->SetList(name);
		}

		// brick filter label
		if (f->Category() == FCAT_BRICK)
		{
			CFilterBrick* f3 = (CFilterBrick*)f;
			name = GetGraphWord();
			if (name.IsEmpty() ||
				(name.First() != TCHAR('"')) ||
				(name.Last() != TCHAR('"'))) goto ERR_NAME_EMPTY;
			name.DelFirst();
			name.DelLast();
			f3->SetList(name);
		}

		// special properties
		if (f->Category() == FCAT_INVALUE)
		{
			CFilterValue* f3 = (CFilterValue*)f;
			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			f3->SetMin(name.Int());
			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			f3->SetMax(name.Int());
			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			f3->SetMinVal((real)name.Double());
			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			f3->SetMaxVal((real)name.Double());
			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			f3->SetDefValue((real)name.Double());
		}
		else if (f->Category() == FCAT_INCOLOR)
		{
			CFilterColor* f3 = (CFilterColor*)f;
			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			if ((name.Length() < 9) ||
				(name.First() != TCHAR('(')) ||
				(name.Last() != TCHAR(')'))) goto ERR_COLOR_ERROR;
			name.DelFirst();
			name.DelLast();
			lst.Split(name, TCHAR(','));
			if (lst.Num() != 4) goto ERR_COLOR_ERROR;
			f3->DefColor()->Set((real)(lst[0].Double()/255), (real)(lst[1].Double()/255), 
				(real)(lst[2].Double()/255), (real)(lst[3].Double()/255));
			f3->Color()->Set(*f3->DefColor());
		}
		else if (f->Category() == FCAT_INIMAGE)
		{
			CFilterImage* f3 = (CFilterImage*)f;
			name = GetGraphWord();
			if (name.IsEmpty() ||
				(name.First() != TCHAR('"')) ||
				(name.Last() != TCHAR('"'))) goto ERR_NAME_EMPTY;
			name.DelFirst();
			name.DelLast();
			f3->SetDefFileName(name);
			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			f3->SetTiled(name.Int() != 0);
		}
		else if (f->Category() == FCAT_INIMAGEDATA)
		{
			CFilterImageData* f3 = (CFilterImageData*)f;
			f3->DelBuf();
			name = GetGraphWord();
			if (name.IsEmpty() ||
				(name.First() != TCHAR('"')) ||
				(name.Last() != TCHAR('"'))) goto ERR_NAME_EMPTY;
			name.DelFirst();
			name.DelLast();
			f3->SetFileName0(name);

			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			f3->SetTiled(name.Int() != 0);

			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			int w = name.Int();

			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			int h = name.Int();

			name = GetGraphWord();
			if (name.IsEmpty()) goto ERR_NAME_EMPTY;
			int c = name.Int();

			name = GetGraphWord();
			if (name.IsEmpty() ||
				(name.First() != TCHAR('"')) ||
				(name.Last() != TCHAR('"'))) goto ERR_NAME_EMPTY;
			name.DelFirst();
			name.DelLast();
			if ((w < 1) || (w > PICMAXWH) ||
				(h < 1) || (h > PICMAXWH) ||
				((c != 3) && (c != 4)))
			{
				
			}
			else
			{
				u8* b = f3->CreateData(w, h, c);
				if (b != NULL)
				{
					int i = f3->PicSize();
					i = (i + 2)/3;
					int j = (name.Length() + 3)/4;
					if (i > j) i = j;
					TCHAR ch;
					int n = 0;
					int k;
					for (; i > 0; i--)
					{
						k = 0;
						int m = 0;
						for (j = 4; j > 0; j--)
						{
							ch = name[n++];
							if (ch == TCHAR('_'))
								ch = 37;			// 37
							else
								if (ch >= TCHAR('a'))
									ch = ch - TCHAR('a') + 38; // 38..63
								else
									if (ch >= TCHAR('@'))
										ch = ch - TCHAR('@') + 10; // 10..36
									else
										ch = ch - TCHAR('0'); // 0..9
							k |= (int)ch << m;
							m += 6;
						}
						*(u32*)b = k;
						b += 3;
					}
				}
			}
		}

		// parse parameters
		for (i = 0; i < f->PropNum(); i++)
		{
			name = GetGraphWord();

			// missing arguments
			if (name.IsEmpty())
			{
ERR_NAME_EMPTY:
				FLock.Unlock();
				txt2.Load(ID_LOADERR6);
				txt1.Format((LPCTSTR)txt2, (LPCTSTR)filename, GraphRowInx);
				txt2.Load(ID_LOADERR);
				::MessageBox(MainFrame->Handle(), txt1, txt2, MB_OK);
				return FALSE;
			}
			p = f->Prop(i);

			// numeric parameter
			ch = name.First();
			if (((ch >= TCHAR('0')) && (ch <= TCHAR('9'))) ||
				(ch == TCHAR('-')) || (ch == TCHAR('+')))
			{
				p->SetUserValue((real)name.Double());
			}

			// color
			else if (ch == TCHAR('('))
			{
				name.DelFirst();
				ch = name.Last();
				name.DelLast();
				lst.Split(name, TCHAR(','));
				if ((lst.Num() != 4) || (ch != TCHAR(')')))
				{
ERR_COLOR_ERROR:
					FLock.Unlock();
					txt2.Load(ID_LOADERR7);
					txt1.Format((LPCTSTR)txt2, (LPCTSTR)filename, GraphRowInx, (LPCTSTR)name);
					txt2.Load(ID_LOADERR);
					::MessageBox(MainFrame->Handle(), txt1, txt2, MB_OK);
					return FALSE;
				}

				p->SetColor((real)(lst[0].Double()/255), (real)(lst[1].Double()/255), 
					(real)(lst[2].Double()/255), (real)(lst[3].Double()/255));
			}

			// predefined filters
			else if (name == TextLinear)
			{
				p->SetFilter(&FLinear);
			}

			// filter name
			else
			{
				f2 = FindGraphName(name);
				if (f2 == NULL)
				{
					FLock.Unlock();
					txt2.Load(ID_LOADERR8);
					txt1.Format((LPCTSTR)txt2, (LPCTSTR)filename, GraphRowInx, (LPCTSTR)name);
					txt2.Load(ID_LOADERR);
					::MessageBox(MainFrame->Handle(), txt1, txt2, MB_OK);
					return FALSE;
				}
				p->SetFilter(f2);
			}
		}

		// next filter
		f = f->Next();
	}

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

	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// save filter graph (returns FALSE on error)

BOOL SaveGraph(const CText& filename)
{
	if (filename.IsEmpty()) return TRUE;

	// update caption
	CText txt = filename;
	txt.UpperCase();
	CText txt2 = GraphFilename;
	txt2.UpperCase();
	if (txt == txt2)
	{
		Modi = FALSE;
		SetCaption();
	}

	// file header
	txt = GraphIdent;
	txt += TCHAR(' ');
	txt += VERTXT;
	txt += NewLine;

	// filter info
	int i;
	for (i = 0; i < FInfo.RowsNum(); i++)
	{
		txt += TCHAR('#');
		txt += TCHAR(' ');
		txt += FInfo.Row(i);
		txt += NewLine;
	}

	// add filters
	CFilter* f;
	CProperty* p;
	CColor c;
	ListForEach(f, &FGraph)
	{
		// filter name
		txt2 = f->Name();
		
		// filter class
		txt2 += TCHAR(' ');
		txt2 += f->Class();

		// filter coordinates
		txt2 += TCHAR(' ');
		txt2.AddInt(f->X());
		txt2 += TCHAR(' ');
		txt2.AddInt(f->Y());

		// input filter label
		if ((f->Category() == FCAT_INVALUE) ||
			(f->Category() == FCAT_INCOLOR) ||
			(f->Category() == FCAT_INIMAGE))
		{
			CFilterIn* f2 = (CFilterIn*)f;
			txt2 += TCHAR(' ');
			txt2 += TCHAR('"');
			txt2 += f2->Label();
			txt2 += TCHAR('"');
		}

		// output filter label
		if (f->Category() == FCAT_OUT)
		{
			CFilterOut* f2 = (CFilterOut*)f;
			txt2 += TCHAR(' ');
			txt2 += TCHAR('"');
			txt2 += f2->Label();
			txt2 += TCHAR('"');
		}

		// table filter label
		if (f->Category() == FCAT_TABLE)
		{
			CFilterTable* f2 = (CFilterTable*)f;
			txt2 += TCHAR(' ');
			txt2 += TCHAR('"');
			txt2 += f2->List();
			txt2 += TCHAR('"');
		}

		// brick filter label
		if (f->Category() == FCAT_BRICK)
		{
			CFilterBrick* f2 = (CFilterBrick*)f;
			txt2 += TCHAR(' ');
			txt2 += TCHAR('"');
			txt2 += f2->List();
			txt2 += TCHAR('"');
		}

		// special properties
		if (f->Category() == FCAT_INVALUE)
		{
			CFilterValue* f2 = (CFilterValue*)f;
			txt2 += TCHAR(' ');
			txt2.AddInt(f2->Min());
			txt2 += TCHAR(' ');
			txt2.AddInt(f2->Max());
			txt2 += TCHAR(' ');
			txt2.AddDouble(f2->MinVal());
			txt2 += TCHAR(' ');
			txt2.AddDouble(f2->MaxVal());
			txt2 += TCHAR(' ');
			txt2.AddDouble(f2->DefValue());
		}
		else if (f->Category() == FCAT_INCOLOR)
		{
			CFilterColor* f2 = (CFilterColor*)f;
			txt2 += TCHAR(' ');
			txt2.AddColor(f2->DefColor());
		}
		else if (f->Category() == FCAT_INIMAGE)
		{
			CFilterImage* f2 = (CFilterImage*)f;
			txt2 += TCHAR(' ');
			txt2 += TCHAR('"');
			txt2 += f2->DefFileName();
			txt2 += TCHAR('"');
			txt2 += TCHAR(' ');
			txt2 += f2->Tiled() ? TCHAR('1') : TCHAR('0');
		}
		else if (f->Category() == FCAT_INIMAGEDATA)
		{
			CFilterImageData* f2 = (CFilterImageData*)f;
			txt2 += TCHAR(' ');
			txt2 += TCHAR('"');
			txt2 += f2->FileName();
			txt2 += TCHAR('"');
			txt2 += TCHAR(' ');
			txt2 += f2->Tiled() ? TCHAR('1') : TCHAR('0');
			txt2 += TCHAR(' ');
			txt2.AddInt(f2->PicW());
			txt2 += TCHAR(' ');
			txt2.AddInt(f2->PicH());
			txt2 += TCHAR(' ');
			txt2.AddInt(f2->PicC());
			txt2 += TCHAR(' ');
			txt2 += TCHAR('"');

			if ((f2->PicW() > 0) && (f2->PicH() > 0) && (f2->PicData() != NULL))
			{
				int size = (f2->PicW()*f2->PicH()*f2->PicC()+2)/3;
				TCHAR* b = (TCHAR*)malloc(size*4*sizeof(TCHAR) + 1);
				if (b != NULL)
				{
					int j, k, n;
					TCHAR ch;
					u8* s = f2->PicData();
					n = 0;
					for (; size > 0; size--)
					{
						k = *(u32*)s;
						s += 3;
						for (j = 4; j > 0; j--)
						{
							ch = (TCHAR)(k & 0x3f);
							k >>= 6;
							if (ch < 10)
								ch += TCHAR('0'); // 0..9
							else
								if (ch < 37)
									ch = ch - 10 + TCHAR('@'); // 10..36
								else
									if (ch == 37)
										ch = TCHAR('_'); // 37
									else
										ch = (TCHAR)(ch - 38 + TCHAR('a')); // 38..63
							b[n++] = ch;
						}
					}
					b[n++] = 0;
					CText t(b);
					txt2 += t;
					free(b);
				}
			}
			txt2 += TCHAR('"');
		}

		// properties
		for (i = 0; i < f->PropNum(); i++)
		{
			p = f->Prop(i);
			txt2 += TCHAR(' ');

			// filter
			if (p->Filter() != NULL)
			{
				if (p->Filter() == &FLinear)
					txt2 += TextLinear;
				else
					txt2 += p->Filter()->Name();
			}
			else
			{
				// value or color
				p->Color(&c);
				if ((c.r == c.g) && (c.r == c.b) && (c.a == 1))
					txt2.AddDouble(p->GetUserValue());
				else
					txt2.AddColor(&c);
			}
		}
		txt2 += NewLine;
		txt += txt2;
	}

	// path
	CText path = filename;
	path.Delete(path.Length()-3, 3);	

	// save file
	CText tmp = path + _T("$$$");
	if (!txt.SaveFileName(tmp))
	{
		txt2.Load(ID_SAVEERR2);
		txt.Format((LPCTSTR)txt2, (LPCTSTR)tmp);
		txt2.Load(ID_SAVEERR);
		::MessageBox(MainFrame->Handle(), txt, txt2, MB_OK);
		return FALSE;
	}

	// rename file
	CText bak = path + _T(BACKEXT);
	::DeleteFile((LPCTSTR)bak);
	::MoveFile(filename, bak);
	if (!::MoveFile(tmp, filename))
	{
		txt2.Load(ID_SAVEERR2);
		txt.Format((LPCTSTR)txt2, (LPCTSTR)filename);
		txt2.Load(ID_SAVEERR);
		::MessageBox(MainFrame->Handle(), txt, txt2, MB_OK);
		return FALSE;
	}

	// save preview icon
	SaveIcon(path + _T(PREVEXT) /*, FALSE*/);

	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// save filter graph As

void SaveGraphAs()
{
	CText txt = GetSaveLoadFile(IDS_FILEMASK, _T("txg"), GraphFilename, MainFrame, TRUE);
	if (txt.IsNotEmpty()) SaveGraph(txt);
}

///////////////////////////////////////////////////////////////////////////////
// check modification (returns FALSE = break operation)

BOOL CheckModi()
{
	// not modified
	if (!EditMode || !Modi) return TRUE;

	// dialog
	CText txt, txt2;
	txt.Load(IDS_MODI);
	txt2.Load(IDS_MODI2);
	int res = ::MessageBox(MainFrame->Handle(), txt2, txt, MB_YESNOCANCEL);

	// save the changes
	switch (res)
	{
	case IDYES:
		return SaveGraph(GraphFilename);

	case IDNO:
		Modi = FALSE;
		return TRUE;
	}
	return FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// set filter modification

void SetModi()
{
	Modi = TRUE;
	SetCaption();
}
