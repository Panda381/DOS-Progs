
/////////////////////////////////////////////////////////////////////////////
//																		   //
//							obsluha navigace							   //
//																		   //
/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
// aktualizace ukazatele po�tu referenc�

void CProg::OnUpdateProgRefer(CCmdUI* pCmdUI) 
{
// lok�ln� prom�nn�, nalezen� aktu�ln�ho prvku
	short bufID = m_AktBufID;					// ��slo aktu�ln�ho bufferu
	CProgBuf* buf = &(m_Buf[bufID]);			// aktu�ln� buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezen� aktivn�ho prvku
	int itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn�ho prvku
	PROGITEM* item;								// ukazatel na prvek
	CStatic* txt;								// prvek zobrazen�ho textu
	TCHAR buff[10];								// buffer k dek�dov�n� textu ��sla
	short count;								// po�et referenc�

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybr�n n�jak� prvek
	{

// ukazatel na aktu�ln� prvek
		item = &(buf->m_Items[itemN]);			// ukazatel na prvek

// p�esm�rov�n� na deklara�n� polo�ku prvku
		if  (
			 (
			  ((bufID == BufEdiID) && (item->typ != -1))	// z editoru v�dy do jin�ho bufferu
			  ||
			  ((bufID != BufEdiID) && (item->typ == BufStrID)) // z jin�ch buffer� jen do struktur
			 ) 
			 && 
			 (item->refer != -1)				// platn� ukazatel reference
			)
			item = &(m_Buf[item->typ].m_Items[item->refer]); // p�esm�rov�n� na deklara�n� prvek

// po�et referenc� prvku
		count = item->counter;					// po�et referenc� prvku

// test, zda byl �daj po�tu referenc� zm�n�n
		if (count != m_OldRef)					// zm�nil se po�et referenc� ?
		{
// zobrazen� nov�ho po�tu referenc�
			wsprintf(buff, _T("%d"), count);	// p��prava ��sla k zobrazen�
			txt = (CStatic*)(MainFrame->		// nalezen� okna textu
				m_wndNavBar.GetDlgItem(IDC_PROG_REFER));
			if (txt != NULL)					// bylo okno nalezeno ?
			{
				txt->SetWindowText(buff);		// nastaven� textu po�tu referenc�
				m_OldRef = count;				// �schova nov�ho po�tu referenc�
			}
			else
				m_OldRef = -2;					// jinak po�et referenc� neplatn�
		}
	}

// jinak se text po�tu referenc� vyma�e
	else
	{
		if (m_OldRef != -1)						// je text po�tu referenc� vymaz�n ?
		{
			txt = (CStatic*)(MainFrame->		// nalezen� okna textu
				m_wndNavBar.GetDlgItem(IDC_PROG_REFER));
			if (txt != NULL)					// bylo okno nalezeno ?
			{
				txt->SetWindowText(_T(""));		// vymaz�n� po�tu referenc�
				m_OldRef = -1;					// p��znak vymaz�n� textu referenc�
			}
			else
				m_OldRef = -2;					// jinak po�et referenc� neplatn�
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// zad�n� textu k hled�n�

void CProg::OnChangeFind() 
{
// p��prava editoru textu
	CEdit* name = (CEdit*)(MainFrame->m_wndNavBar.GetDlgItem(IDC_PROG_FIND));

// na�ten� textu z editoru
	if (name != NULL)
		name->GetWindowText(FindString);		// na�ten� textu do bufferu
}

void CProg::OnProgEdit() 
{
// p��prava editoru textu
	CEdit* name = (CEdit*)(MainFrame->m_wndNavBar.GetDlgItem(IDC_PROG_FIND));

// aktivace okna
	if (name != NULL)
		name->SetFocus();						// aktivace okna
}

/////////////////////////////////////////////////////////////////////////////
// nalezen� dal��ho v�skytu textu

void CProg::OnFindNext() 
{
	OnFind(1);
}


/////////////////////////////////////////////////////////////////////////////
// nalezen� p�ede�l�ho v�skytu textu

void CProg::OnFindPrev() 
{
	OnFind(-1);
}


/////////////////////////////////////////////////////////////////////////////
// nalezen� textu v po�adovan�m sm�ru

void CProg::OnFind(short inc)
{
// lok�ln� prom�nn�
	short bufnum;								// ��ta� buffer� k prohled�n�
	CString txt = _T("");						// buffer textu k polo�ce
	CString txtfind = FindString;				// hledan� text

	short bufID = m_AktBufID;					// ��slo aktivn�ho bufferu
	CProgBuf* buf = &(m_Buf[bufID]);			// adresa aktivn�ho bufferu
	short itemN = buf->SrcItem(buf->m_Tree->GetSelectedItem())+inc; // ukazatel ��sla aktivn�ho prvku
	PROGITEM* item;								// ukazatel na prvek
	short num = buf->m_Num;						// po�et polo�ek v bufferu

// p��prava hledan�ho textu
	txtfind.MakeUpper();						// konverze na velk� p�smena

// cyklus p�es v�echny buffery (+ 1 na p�ekryv)
	for (bufnum = 6+1; bufnum > 0; bufnum--)
	{

// cyklus p�es v�echny polo�ky v bufferu
		for (; ((itemN < num) && (itemN >= 0)); itemN += inc)
		{

// p��prava adresy polo�ky
			item = &(buf->m_Items[itemN]);		// adresa polo�ky

// nekontroluje se ROOT polo�ka LOCAL a EDIT
			if	(
				 ((bufID == BufEdiID) || (bufID == BufLocID)) &&
				 (item->parent == -1)
				)
				continue;						// p�esko�en� kontroly

// na�ten� textu k polo�ce
			txt = buf->GetName(itemN);			// na�ten� textu jm�na k polo�ce
			txt.MakeUpper();					// konverze na velk� p�smena

// vyhled�n� textu k polo�ce
			if (txt.Find(txtfind) != -1)
			{

// zobrazen� c�lov� polo�ky
				DispItem(bufID, itemN);			// nastaven� nalezen� polo�ky
				return;
			}
		}

// posun ukazatele na dal�� buffer
		if (inc > 0)							// je sm�r vp�ed ?
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
			itemN = 0;							// ukazatel ��sla prvku
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
			itemN = buf->m_Num-1;				// ukazatel ��sla prvku
		}
		num = buf->m_Num;						// po�et polo�ek v bufferu
	}
}


/////////////////////////////////////////////////////////////////////////////
// zobrazen� nalezen� polo�ky

void CProg::DispItem(short bufID, short itemN)
{
// lok�ln� prom�nn�
	CProgBuf* buf = &(m_Buf[bufID]);			// adresa bufferu
	short First;								// ROOT polo�ka
	short itemN2;								// odkazuj�c� polo�ka

// nalezen� ROOT polo�ky
	First = itemN;
	while (buf->m_Items[First].parent != -1)	// je to ji� ROOT ?
		First = buf->m_Items[First].parent;		// p�esm�rov�n� na rodi�e

// je-li editor, nalezen� deklara�n� ��sti LOKAL
	if (bufID == BufEdiID)
	{
		itemN2 = m_BufLoc.SrcDat(bufID, First);	// nalezen� odkazovac� polo�ky
		if (itemN2 != -1)						// byla polo�ka nalezena ?
			m_BufLoc.SetFirst(itemN2);			// zaji�t�n� zobrazen� po��tku
	}

// zaji�t�n� zobrazen� prvn� polo�ky v aktu�ln�m bufferu
	buf->SetFirst(itemN);						// zaji�t�n� zobrazen� prvn� polo�ky

// p�epnut� na c�lov� okno
	buf->m_Tree->SetFocus();					// p�epnut� na c�lov� okno

// nastaven� aktivn� polo�ky
	buf->m_Tree->EnsureVisible(buf->m_Items[itemN].htree);	// zaji�t�n� viditelnosti polo�ky
	buf->m_Tree->SelectItem(buf->m_Items[itemN].htree);	// nastaven� polo�ky jako aktivn�

// aktualizace defini�n�ch ukazatel�
	AktAllDef();								// aktualizace defini�n�ch ukazatel�
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace v�ech defini�n�ch ukazatel�

void CProg::AktAllDef()
{
// lok�ln� prom�nn�
	short itemN;								// ukazatel ��sla polo�ky

// nalezen� odkazu z lok�ln�ho bufferu do editoru
	itemN = m_BufLoc.SrcDat(BufEdiID, m_BufEdi.m_First-1);

// ozna�en� editovan� polo�ky v lok�ln�ch objektech
	if (itemN == -1)							// byla polo�ka platn� ?
		m_BufLoc.SetDef(-1);					// vypnut� indik�toru
	else
		if (m_BufLoc.m_Items[itemN].parent == -1) // je to ROOT polo�ka ?
			m_BufLoc.SetDef(-1);				// pro ROOT polo�ku nebude ukazatel
		else
			m_BufLoc.SetDef(itemN);				// jinak nastaven� ukazatele na polo�ku

// nalezen� odkazu v glob�ln�ch objektech
	itemN = m_BufObj.SrcDat(BufLocID, m_BufLoc.m_First-1); // nalezen� odkazu
	if (itemN == -1)							// byla polo�ka platn� ?
		m_BufObj.SetDef(-1);					// vypnut� indik�toru
	else
		m_BufObj.SetDef(itemN);					// nastaven� ukazatele na polo�ku

// nalezen� odkazu ve t��d�ch
	itemN = m_BufCls.SrcDat(BufLocID, m_BufLoc.m_First-1); // nalezen� odkazu
	if (itemN == -1)							// byla polo�ka platn� ?
		m_BufCls.SetDef(-1);					// vypnut� indik�toru
	else
		m_BufCls.SetDef(itemN);					// nastaven� ukazatele na polo�ku
}


/////////////////////////////////////////////////////////////////////////////
// skok na deklara�n� polo�ku

void CProg::OnRefDef() 
{
// lok�ln� prom�nn�, nalezen� aktu�ln�ho prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktu�ln� buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezen� aktivn�ho prvku
	short itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn�ho prvku
	PROGITEM* item;								// ukazatel na prvek
	short bufID2;								// �eklara�n� buffer
	short itemN2;								// deklara�n� polo�ka

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybr�n n�jak� prvek
	{

// ukazatel na aktu�ln� prvek
		item = &(buf->m_Items[itemN]);			// ukazatel na prvek

// odkaz na deklara�n� polo�ku
		bufID2 = item->typ;						// deklara�n� buffer
		itemN2 = item->refer;					// deklara�n� polo�ka

// skok na deklara�n� polo�ku, je-li platn�
		if (((bufID2 == BufObjID) ||			// glob�ln� objekty
			(bufID2 == BufLocID) ||				// lok�ln� objekty
			(bufID2 == BufClsID) ||				// t��dy
			(bufID2 == BufStrID)) &&			// struktury
			(itemN2 != -1))						// platn� index
		{
			DispItem(bufID2, itemN2);			// skok na deklaraci			
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// skok na dal�� pou�it� polo�ky

void CProg::OnRefNext() 
{
	OnRefNextPrev(1);
}


/////////////////////////////////////////////////////////////////////////////
// skok na p�ede�l� pou�it� polo�ky

void CProg::OnRefPrev() 
{
	OnRefNextPrev(-1);
}


/////////////////////////////////////////////////////////////////////////////
// skok na pou�it� polo�ky v po�adovan�m sm�ru

void CProg::OnRefNextPrev(short smer)
{
// lok�ln� prom�nn�
	short bufID = m_AktBufID;					// ��slo bufferu
	CProgBuf* buf = &(m_Buf[bufID]);			// adresa bufferu
	short itemN;								// ukazatel ��sla polo�ky
	PROGITEM* item;								// adresa polo�ky

// aktu�ln� vybran� polo�ka
	itemN = buf->GetAkt();						// nalezen� aktivn� polo�ky
	if (itemN == -1) return;					// nen� vybr�na ��dn� polo�ka
	item = &(buf->m_Items[itemN]);				// adresa polo�ky

// nalezen� polo�ky pro editor
	if (bufID == BufEdiID)
		AktRef(BufEdiID, item->typ, item->refer, smer); // nalezen� polo�ky
	else

// nalezen� polo�ky pro t��dy
		if (bufID == BufClsID)
		{
			if (!AktRef(BufLocID, bufID, itemN, smer)) // hled�n� v lok�ln�m bufferu
			AktRef(BufObjID, bufID, itemN, smer);	// hled�n� v glob�ln�m bufferu
		}
		else

// pro ostatn� buffery zm�na na edita�n� buffer
			AktRef(BufEdiID, bufID, itemN, smer);
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace polo�ky s po�adovanou referenc�

BOOL CProg::AktRef(short bufID, short bufref, short itemref, short smer)
{
// nalezen� polo�ky v editoru
	short itemN = m_Buf[bufID].SrcRef(bufref, itemref, smer);

// zobrazen� nalezen� polo�ky
	if (itemN != -1)							// byla polo�ka nalezena ?
	{
		DispItem(bufID, itemN);					// zobrazen� polo�ky
		return TRUE;							// p��znak zobrazen� polo�ky
	}
	else
		return FALSE;							// p��znak nenalezen� polo�ky
}

