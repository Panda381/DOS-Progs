
/////////////////////////////////////////////////////////////////////////////
//																		   //
//							obsluha navigace							   //
//																		   //
/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
// aktualizace ukazatele poètu referencí

void CProg::OnUpdateProgRefer(CCmdUI* pCmdUI) 
{
// lokální promìnné, nalezení aktuálního prvku
	short bufID = m_AktBufID;					// èíslo aktuálního bufferu
	CProgBuf* buf = &(m_Buf[bufID]);			// aktuální buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezení aktivního prvku
	int itemN = buf->SrcItem(htree);			// nalezení indexu aktivního prvku
	PROGITEM* item;								// ukazatel na prvek
	CStatic* txt;								// prvek zobrazeného textu
	TCHAR buff[10];								// buffer k dekódování textu èísla
	short count;								// poèet referencí

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybrán nìjaký prvek
	{

// ukazatel na aktuální prvek
		item = &(buf->m_Items[itemN]);			// ukazatel na prvek

// pøesmìrování na deklaraèní položku prvku
		if  (
			 (
			  ((bufID == BufEdiID) && (item->typ != -1))	// z editoru vždy do jiného bufferu
			  ||
			  ((bufID != BufEdiID) && (item->typ == BufStrID)) // z jiných bufferù jen do struktur
			 ) 
			 && 
			 (item->refer != -1)				// platný ukazatel reference
			)
			item = &(m_Buf[item->typ].m_Items[item->refer]); // pøesmìrování na deklaraèní prvek

// poèet referencí prvku
		count = item->counter;					// poèet referencí prvku

// test, zda byl údaj poètu referencí zmìnìn
		if (count != m_OldRef)					// zmìnil se poèet referencí ?
		{
// zobrazení nového poètu referencí
			wsprintf(buff, _T("%d"), count);	// pøíprava èísla k zobrazení
			txt = (CStatic*)(MainFrame->		// nalezení okna textu
				m_wndNavBar.GetDlgItem(IDC_PROG_REFER));
			if (txt != NULL)					// bylo okno nalezeno ?
			{
				txt->SetWindowText(buff);		// nastavení textu poètu referencí
				m_OldRef = count;				// úschova nového poètu referencí
			}
			else
				m_OldRef = -2;					// jinak poèet referencí neplatný
		}
	}

// jinak se text poètu referencí vymaže
	else
	{
		if (m_OldRef != -1)						// je text poètu referencí vymazán ?
		{
			txt = (CStatic*)(MainFrame->		// nalezení okna textu
				m_wndNavBar.GetDlgItem(IDC_PROG_REFER));
			if (txt != NULL)					// bylo okno nalezeno ?
			{
				txt->SetWindowText(_T(""));		// vymazání poètu referencí
				m_OldRef = -1;					// pøíznak vymazání textu referencí
			}
			else
				m_OldRef = -2;					// jinak poèet referencí neplatný
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// zadání textu k hledání

void CProg::OnChangeFind() 
{
// pøíprava editoru textu
	CEdit* name = (CEdit*)(MainFrame->m_wndNavBar.GetDlgItem(IDC_PROG_FIND));

// naètení textu z editoru
	if (name != NULL)
		name->GetWindowText(FindString);		// naètení textu do bufferu
}

void CProg::OnProgEdit() 
{
// pøíprava editoru textu
	CEdit* name = (CEdit*)(MainFrame->m_wndNavBar.GetDlgItem(IDC_PROG_FIND));

// aktivace okna
	if (name != NULL)
		name->SetFocus();						// aktivace okna
}

/////////////////////////////////////////////////////////////////////////////
// nalezení dalšího výskytu textu

void CProg::OnFindNext() 
{
	OnFind(1);
}


/////////////////////////////////////////////////////////////////////////////
// nalezení pøedešlého výskytu textu

void CProg::OnFindPrev() 
{
	OnFind(-1);
}


/////////////////////////////////////////////////////////////////////////////
// nalezení textu v požadovaném smìru

void CProg::OnFind(short inc)
{
// lokální promìnné
	short bufnum;								// èítaè bufferù k prohledání
	CString txt = _T("");						// buffer textu k položce
	CString txtfind = FindString;				// hledaný text

	short bufID = m_AktBufID;					// èíslo aktivního bufferu
	CProgBuf* buf = &(m_Buf[bufID]);			// adresa aktivního bufferu
	short itemN = buf->SrcItem(buf->m_Tree->GetSelectedItem())+inc; // ukazatel èísla aktivního prvku
	PROGITEM* item;								// ukazatel na prvek
	short num = buf->m_Num;						// poèet položek v bufferu

// pøíprava hledaného textu
	txtfind.MakeUpper();						// konverze na velká písmena

// cyklus pøes všechny buffery (+ 1 na pøekryv)
	for (bufnum = 6+1; bufnum > 0; bufnum--)
	{

// cyklus pøes všechny položky v bufferu
		for (; ((itemN < num) && (itemN >= 0)); itemN += inc)
		{

// pøíprava adresy položky
			item = &(buf->m_Items[itemN]);		// adresa položky

// nekontroluje se ROOT položka LOCAL a EDIT
			if	(
				 ((bufID == BufEdiID) || (bufID == BufLocID)) &&
				 (item->parent == -1)
				)
				continue;						// pøeskoèení kontroly

// naètení textu k položce
			txt = buf->GetName(itemN);			// naètení textu jména k položce
			txt.MakeUpper();					// konverze na velká písmena

// vyhledání textu k položce
			if (txt.Find(txtfind) != -1)
			{

// zobrazení cílové položky
				DispItem(bufID, itemN);			// nastavení nalezené položky
				return;
			}
		}

// posun ukazatele na další buffer
		if (inc > 0)							// je smìr vpøed ?
		{
			switch(bufID)
			{
				case BufEdiID: bufID = BufStrID; break;
				case BufStrID: bufID = BufClsID; break;
				case BufClsID: bufID = BufLocID; break;
				case BufLocID: bufID = BufObjID; break;
				case BufObjID: bufID = BufEdiID; break;
			}
			buf = &(m_Buf[bufID]);				// adresa bufferu
			itemN = 0;							// ukazatel èísla prvku
		}
		else
		{
			switch(bufID)
			{
				case BufEdiID: bufID = BufObjID; break;
				case BufObjID: bufID = BufLocID; break;
				case BufLocID: bufID = BufClsID; break;
				case BufClsID: bufID = BufStrID; break;
				case BufStrID: bufID = BufEdiID; break;
			}
			buf = &(m_Buf[bufID]);				// adresa bufferu
			itemN = buf->m_Num-1;				// ukazatel èísla prvku
		}
		num = buf->m_Num;						// poèet položek v bufferu
	}
}


/////////////////////////////////////////////////////////////////////////////
// zobrazení nalezené položky

void CProg::DispItem(short bufID, short itemN)
{
// lokální promìnné
	CProgBuf* buf = &(m_Buf[bufID]);			// adresa bufferu
	short First;								// ROOT položka
	short itemN2;								// odkazující položka

// nalezení ROOT položky
	First = itemN;
	while (buf->m_Items[First].parent != -1)	// je to již ROOT ?
		First = buf->m_Items[First].parent;		// pøesmìrování na rodièe

// je-li editor, nalezení deklaraèní èásti LOKAL
	if (bufID == BufEdiID)
	{
		itemN2 = m_BufLoc.SrcDat(bufID, First);	// nalezení odkazovací položky
		if (itemN2 != -1)						// byla položka nalezena ?
			m_BufLoc.SetFirst(itemN2);			// zajištìní zobrazení poèátku
	}

// zajištìní zobrazení první položky v aktuálním bufferu
	buf->SetFirst(itemN);						// zajištìní zobrazení první položky

// pøepnutí na cílové okno
	buf->m_Tree->SetFocus();					// pøepnutí na cílové okno

// nastavení aktivní položky
	buf->m_Tree->EnsureVisible(buf->m_Items[itemN].htree);	// zajištìní viditelnosti položky
	buf->m_Tree->SelectItem(buf->m_Items[itemN].htree);	// nastavení položky jako aktivní

// aktualizace definièních ukazatelù
	AktAllDef();								// aktualizace definièních ukazatelù
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace všech definièních ukazatelù

void CProg::AktAllDef()
{
// lokální promìnné
	short itemN;								// ukazatel èísla položky

// nalezení odkazu z lokálního bufferu do editoru
	itemN = m_BufLoc.SrcDat(BufEdiID, m_BufEdi.m_First-1);

// oznaèení editované položky v lokálních objektech
	if (itemN == -1)							// byla položka platná ?
		m_BufLoc.SetDef(-1);					// vypnutí indikátoru
	else
		if (m_BufLoc.m_Items[itemN].parent == -1) // je to ROOT položka ?
			m_BufLoc.SetDef(-1);				// pro ROOT položku nebude ukazatel
		else
			m_BufLoc.SetDef(itemN);				// jinak nastavení ukazatele na položku

// nalezení odkazu v globálních objektech
	itemN = m_BufObj.SrcDat(BufLocID, m_BufLoc.m_First-1); // nalezení odkazu
	if (itemN == -1)							// byla položka platná ?
		m_BufObj.SetDef(-1);					// vypnutí indikátoru
	else
		m_BufObj.SetDef(itemN);					// nastavení ukazatele na položku

// nalezení odkazu ve tøídách
	itemN = m_BufCls.SrcDat(BufLocID, m_BufLoc.m_First-1); // nalezení odkazu
	if (itemN == -1)							// byla položka platná ?
		m_BufCls.SetDef(-1);					// vypnutí indikátoru
	else
		m_BufCls.SetDef(itemN);					// nastavení ukazatele na položku
}


/////////////////////////////////////////////////////////////////////////////
// skok na deklaraèní položku

void CProg::OnRefDef() 
{
// lokální promìnné, nalezení aktuálního prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktuální buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezení aktivního prvku
	short itemN = buf->SrcItem(htree);			// nalezení indexu aktivního prvku
	PROGITEM* item;								// ukazatel na prvek
	short bufID2;								// ïeklaraèní buffer
	short itemN2;								// deklaraèní položka

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybrán nìjaký prvek
	{

// ukazatel na aktuální prvek
		item = &(buf->m_Items[itemN]);			// ukazatel na prvek

// odkaz na deklaraèní položku
		bufID2 = item->typ;						// deklaraèní buffer
		itemN2 = item->refer;					// deklaraèní položka

// skok na deklaraèní položku, je-li platná
		if (((bufID2 == BufObjID) ||			// globální objekty
			(bufID2 == BufLocID) ||				// lokální objekty
			(bufID2 == BufClsID) ||				// tøídy
			(bufID2 == BufStrID)) &&			// struktury
			(itemN2 != -1))						// platný index
		{
			DispItem(bufID2, itemN2);			// skok na deklaraci			
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// skok na další použití položky

void CProg::OnRefNext() 
{
	OnRefNextPrev(1);
}


/////////////////////////////////////////////////////////////////////////////
// skok na pøedešlé použití položky

void CProg::OnRefPrev() 
{
	OnRefNextPrev(-1);
}


/////////////////////////////////////////////////////////////////////////////
// skok na použití položky v požadovaném smìru

void CProg::OnRefNextPrev(short smer)
{
// lokální promìnné
	short bufID = m_AktBufID;					// èíslo bufferu
	CProgBuf* buf = &(m_Buf[bufID]);			// adresa bufferu
	short itemN;								// ukazatel èísla položky
	PROGITEM* item;								// adresa položky

// aktuální vybraná položka
	itemN = buf->GetAkt();						// nalezení aktivní položky
	if (itemN == -1) return;					// není vybrána žádná položka
	item = &(buf->m_Items[itemN]);				// adresa položky

// nalezení položky pro editor
	if (bufID == BufEdiID)
		AktRef(BufEdiID, item->typ, item->refer, smer); // nalezení položky
	else

// nalezení položky pro tøídy
		if (bufID == BufClsID)
		{
			if (!AktRef(BufLocID, bufID, itemN, smer)) // hledání v lokálním bufferu
			AktRef(BufObjID, bufID, itemN, smer);	// hledání v globálním bufferu
		}
		else

// pro ostatní buffery zmìna na editaèní buffer
			AktRef(BufEdiID, bufID, itemN, smer);
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace položky s požadovanou referencí

BOOL CProg::AktRef(short bufID, short bufref, short itemref, short smer)
{
// nalezení položky v editoru
	short itemN = m_Buf[bufID].SrcRef(bufref, itemref, smer);

// zobrazení nalezené položky
	if (itemN != -1)							// byla položka nalezena ?
	{
		DispItem(bufID, itemN);					// zobrazení položky
		return TRUE;							// pøíznak zobrazení položky
	}
	else
		return FALSE;							// pøíznak nenalezení položky
}

