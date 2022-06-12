
/////////////////////////////////////////////////////////////////////////////
//																		   //
//						obsluha vlastností prvkù						   //
//																		   //
/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
// pøepnutí stavu LOCK prvku pod kurzorem pomocí tlaèítka LOCK

void CProg::OnProgLock() 
{
// lokální promìnné, nalezení aktuálního prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktuální buffer
	CTreeCtrl* tree = buf->m_Tree;				// strom v aktuálním bufferu
	HTREEITEM htree = tree->GetSelectedItem();	// nalezení aktivního prvku
	int itemN = buf->SrcItem(htree);			// nalezení indexu aktivního prvku
	unsigned short* param;						// ukazatel na parametry prvku

// zmìna pøíznaku uzamknutí
	if (itemN != -1)							// pokud je vybrán nìjaký prvek
	{
		param = &(buf->m_Items[itemN].param);	// ukazatel na parametry prvku
		*param ^= PR_LOCK;						// zmìna pøiznaku uzamèení

// aktualizace zobrazení prvku ve stromu
		if (*param & (PR_LOCK | PR_LOCK_DEP))	// je prvek uzamèen ?
			tree->SetItemState(htree, TVIS_BOLD, TVIS_BOLD); // zapnutí zvýraznìní
		else
			tree->SetItemState(htree, 0, TVIS_BOLD);	// vypnutí zvýraznìní

// aktualizace prvkù v bufferech
		UpdateLock();							// aktualizace bufferù
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace stavu pøepínacího tlaèítka LOCK (prvek uzamèen)

void CProg::OnUpdateProgLock(CCmdUI* pCmdUI) 
{
// lokální promìnné, nalezení aktuálního prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktuální buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezení aktivního prvku
	int itemN = buf->SrcItem(htree);			// nalezení indexu aktivního prvku
	unsigned short* param;						// ukazatel na parametry prvku

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybrán nìjaký prvek
	{
		param = &(buf->m_Items[itemN].param);	// ukazatel na parametry prvku

// zákaz tlaèítka, je-li prvek závisle uzamèen
		if (*param & PR_LOCK_DEP)				// je prvek závisle uzamèen ?
			pCmdUI->Enable(FALSE);				// prvek uzamèen - zákaz tlaèítka
		else
			pCmdUI->Enable(TRUE);				// prvek odemknut - povolení tlaèítka

// nastavení stavu tlaèítka
		if (*param & PR_LOCK)					// je prvek uzamèen ?
			pCmdUI->SetCheck(1);				// prvek uzamèen - tlaèítko stisknuto
		else
			pCmdUI->SetCheck(0);				// prvek odemknut - tlaèítko nestisknuto
	}

// není vybrán prvek - tlaèítko nedefinované, ale povolené
	else
	{
		pCmdUI->Enable(TRUE);					// tlaèítko povoleno
		pCmdUI->SetCheck(2);					// tlaèítko nedefinované
	}
}


/////////////////////////////////////////////////////////////////////////////
// pøepnutí stavu OFF prvku pod kurzorem pomocí tlaèítka OFF

void CProg::OnProgOff() 
{
// lokální promìnné, nalezení aktuálního prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktuální buffer
	CTreeCtrl* tree = buf->m_Tree;				// strom v aktuálním bufferu
	HTREEITEM htree = tree->GetSelectedItem();	// nalezení aktivního prvku
	int itemN = buf->SrcItem(htree);			// nalezení indexu aktivního prvku
	unsigned short* param;						// ukazatel na parametry prvku

// zmìna pøíznaku vypnutí
	if (itemN != -1)							// pokud je vybrán nìjaký prvek
	{
		param = &(buf->m_Items[itemN].param);	// ukazatel na parametry prvku
		*param ^= PR_OFF;						// zmìna pøíznaku vypnutí

// aktualizace zobrazení prvku ve stromu
		if (*param & (PR_OFF | PR_OFF_DEP))		// je prvek vypnut ?
			tree->SetItemState(htree, TVIS_CUT, TVIS_CUT); // zapnutí zešednutí
		else
			tree->SetItemState(htree, 0, TVIS_CUT);		// vypnutí zešednutí

// aktualizace prvkù v bufferech
		UpdateLock();							// aktualizace bufferù
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace stavu pøepínacího tlaèítka OFF (prvek vypnut)

void CProg::OnUpdateProgOff(CCmdUI* pCmdUI) 
{
// lokální promìnné, nalezení aktuálního prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktuální buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezení aktivního prvku
	int itemN = buf->SrcItem(htree);			// nalezení indexu aktivního prvku
	unsigned short* param;						// ukazatel na parametry prvku

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybrán nìjaký prvek
	{
		param = &(buf->m_Items[itemN].param);	// ukazatel na parametry prvku

// zákaz tlaèítka, je-li prvek uzamèen
		if (*param & (PR_LOCK | PR_LOCK_DEP))	// je prvek uzamèen ?
			pCmdUI->Enable(FALSE);				// prvek uzamèen - zákaz tlaèítka
		else
			pCmdUI->Enable(TRUE);				// prvek odemknut - povolení tlaèítka

// nastavení stavu tlaèítka
		if (*param & PR_OFF)					// je prvek vypnut ?
			pCmdUI->SetCheck(1);				// prvek vypnut - tlaèítko stisknuto
		else
			pCmdUI->SetCheck(0);				// prvek není vypnut - tlaèítko nestisknuto
	}

// není vybrán prvek - tlaèítko nedefinované, ale povolené
	else
	{
		pCmdUI->Enable(TRUE);					// tlaèítko povoleno
		pCmdUI->SetCheck(2);					// tlaèítko nedefinované
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace pøíznakù LOCK a OFF bufferù
// Pozor - stav prvkù stromu musí souhlasit se stavem v seznamu !!!

void CProg::UpdateLock()
{
// první prùchod
// buffery LOCALL a EDIT jsou aktualizovány z OBJECT a CLASS
	UpdateLockBuf(BufStrID);			// buffer struktur
	UpdateLockBuf(BufClsID);			// buffer tøíd
	UpdateLockBuf(BufObjID);			// buffer globálních objektù

// druhý prùchod - nìkteré buffery jsou aktualizovány køížovì
	UpdateLockBuf(BufClsID);			// buffer tøíd
	UpdateLockBuf(BufObjID);			// buffer globálních objektù

// tøetí prùchod - lokální buffer je dvojnásobnì køížovì závislý
	UpdateLockBuf(BufClsID);			// buffer tøíd
	UpdateLockBuf(BufObjID);			// buffer globálních objektù
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace pøíznakù LOCK a OFF pro jeden buffer

void CProg::UpdateLockBuf(short bufID)
{
// lokální promìnné
	CProgBuf* buf = &(m_Buf[bufID]);	// adresa bufferu
	CTreeCtrl* tree = buf->m_Tree;		// adresa stromu bufferu
	short num = buf->m_Num;				// poèet položek v bufferu
	short index;						// pracovní index položky

// cyklus pøes všechny položky
	for (index = 0; index < num; index += buf->m_Items[index].items)
		UpdateLockItem(tree, &(buf->m_Items[index]), 0);
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace pøíznakù LOCK a OFF pro jednu položku
// - nesmí realokovat buffer položek, uchovávají se ukazatele na položky

void CProg::UpdateLockItem(CTreeCtrl* tree, PROGITEM* item, int state)
{
// lokální promìnné
	unsigned short* param;			// adresa parametrù položky
	int oldstate;					// starý stav položky
	short childs;					// èítaè potomkù

// oprava nového stavu podle deklaraèní položky
	if (item->refer != -1)
	{
		param = &(m_Buf[item->typ].m_Items[item->refer].param);
		if (*param & (PR_LOCK | PR_LOCK_DEP)) state |= TVIS_BOLD;
		if (*param & (PR_OFF | PR_OFF_DEP)) state |= TVIS_CUT;		
	}

// pøíprava starého stavu položky
	param = &(item->param);			// adresa parametrù aktuální položky
	oldstate = 0;
	if (*param & (PR_LOCK | PR_LOCK_DEP)) oldstate = TVIS_BOLD;
	if (*param & (PR_OFF | PR_OFF_DEP)) oldstate |= TVIS_CUT;

// nastavení závislých pøíznakù (pro ROOT definici se nenuluje, je již nastaveno)
	*param &= ~(PR_LOCK_DEP | PR_OFF_DEP);
	if (state & TVIS_BOLD) *param |= PR_LOCK_DEP;
	if (state & TVIS_CUT) *param |= PR_OFF_DEP;

// oprava stavu položky stromu
	if (*param & (PR_LOCK | PR_LOCK_DEP)) state |= TVIS_BOLD;
	if (*param & (PR_OFF | PR_OFF_DEP)) state |= TVIS_CUT;

// oprava stavu zobrazené položky stromu
	if ((item->htree != NULL) && (state != oldstate))
		tree->SetItemState(item->htree, state, TVIS_CUT | TVIS_BOLD);

// nastavení parametrù definièní položky
	if ((item->index != -1) && ((item->data == BufLocID) || (item->data == BufEdiID)))
		UpdateLockItem(m_Buf[item->data].m_Tree, 
			&(m_Buf[item->data].m_Items[item->index]), state);

// nastavení potomkù
	childs = item->childs;			// poèet potomkù položky
	item++;							// adresa prvního potomka
	for (; childs > 0; childs--)
	{
		UpdateLockItem(tree, item, state);
		item += item->items;		// adresa dalšího potomka
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace stavu pøepínacího tlaèítka DEF (implicitní jméno)

void CProg::OnUpdateProgDef(CCmdUI* pCmdUI) 
{
// lokální promìnné, nalezení aktuálního prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktuální buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezení aktivního prvku
	int itemN = buf->SrcItem(htree);			// nalezení indexu aktivního prvku
	PROGITEM* item;								// ukazatel na prvek

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybrán nìjaký prvek
	{
		item = &(buf->m_Items[itemN]);			// ukazatel na prvek

// zákaz tlaèítka, je-li prvek uzamèen
		if (item->param & (PR_LOCK | PR_LOCK_DEP))	// je prvek uzamèen ?
			pCmdUI->Enable(FALSE);				// prvek uzamèen - zákaz tlaèítka
		else
			pCmdUI->Enable(TRUE);				// prvek odemknut - povolení tlaèítka

// nastavení stavu tlaèítka
		if (item->name == -1)					// je implicitní jméno ?
			pCmdUI->SetCheck(1);				// implicitní jméno - tlaèítko stisknuto
		else
			pCmdUI->SetCheck(0);				// není implicitní jméno - tlaèítko nestisknuto
	}

// není vybrán prvek - tlaèítko nedefinované, ale povolené
	else
	{
		pCmdUI->Enable(TRUE);					// tlaèítko povoleno
		pCmdUI->SetCheck(2);					// tlaèítko nedefinované
	}
}


/////////////////////////////////////////////////////////////////////////////
// pøepínaè DEF (implicitní jméno prvku)

void CProg::OnProgDef() 
{
// lokální promìnné, nalezení aktuální položky
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktuální buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezení aktivní položky
	int itemN = buf->SrcItem(htree);			// nalezení indexu aktivní položky
	PROGITEM* item;								// ukazatel na položku
	CString txt = _T("");						// buffer textu
	CEdit* name;								// editor jména prvku

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybrán nìjaký prvek
	{
		item = &(buf->m_Items[itemN]);			// ukazatel na prvek

// test, zda je text implicitní
		if (item->name == -1)					// je text implicitní ?
		{

// naètení textu k položce
			txt = buf->GetName(itemN);			// naètení jména k položce

// pøidání textu do bufferu textù
			item->name = buf->m_Text->Add(txt);		// pøidání textu do bufferu
		}

// jinak uvolnìní starého textu položky
		else
		{
			buf->m_Text->ElementAt(item->name).Empty(); // zrušení starého textu
			item->name = -1;					// zrušení pøíznaku platnosti položky
		}

// aktualizace zobrazení textu v editoru jména položky
		DispName();								// aktualizace zobrazení jména

// pøíprava editoru jména
		name = (CEdit*)(MainFrame->m_wndPropBar.GetDlgItem(IDC_PROG_EDIT));

// naètení textu z editoru
		if (name != NULL)
			name->GetWindowText(txt);			// naètení textu do bufferu

// nastavení textu do stromu
		buf->m_Tree->SetItemText(item->htree,txt); // nastavení textu

// aktualizace zobrazení závislých bufferù
		if (item->counter)						// jsou reference z jiných bufferù ?
		{
			AktNameTree(BufObjID, txt, m_AktBufID, itemN);
			AktNameTree(BufLocID, txt, m_AktBufID, itemN);
			AktNameTree(BufClsID, txt, m_AktBufID, itemN);
			AktNameTree(BufEdiID, txt, m_AktBufID, itemN);
		}

	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace zobrazení jména položky v editoru jména

void CProg::DispName() 
{
// lokální promìnné, nalezení aktuální položky
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktuální buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezení aktivní položky
	int itemN = buf->SrcItem(htree);			// nalezení indexu aktivní položky
	CEdit* name;								// editor jména položky
	CString txt;								// nový text k nastavení
	CString txtold;								// pùvodní text v oknì

// naètení jména položky
	txt = buf->GetName(itemN);				// naètení jména položky

// okno editoru jména
	name = (CEdit*)(MainFrame->m_wndPropBar.GetDlgItem(IDC_PROG_EDIT));

// nastavení nového textu do editoru jména
	if (name != NULL)							// je okno editoru jména platné ?
	{
		name->GetWindowText(txtold);			// naètení starého textu v editoru
		if (txt.Compare(txtold))				// byl text zmìnìn ?
		{
			m_FilName = TRUE;					// pøíznak plnìní editoru jména
			name->SetWindowText(txt);			// nastavení nového textu editoru jména
			m_FilName = FALSE;					// ukonèení plnìní editoru jména
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// zmìna jména v editoru jména položky

void CProg::OnChangeName() 
{
// test, zda probíhá plnìní editoru jména programem
	if (m_FilName) return;						// probíhá plnìní programem - konec

// lokální promìnné, nalezení aktuální položky
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktuální buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezení aktivní položky
	int itemN = buf->SrcItem(htree);			// nalezení indexu aktivní položky
	PROGITEM* item;								// ukazatel na položku
	CString txt = _T("");						// buffer textu
	CEdit* name;								// editor jména prvku

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybrán nìjaký prvek
	{
		item = &(buf->m_Items[itemN]);			// ukazatel na prvek

// pøíprava editoru jména
		name = (CEdit*)(MainFrame->m_wndPropBar.GetDlgItem(IDC_PROG_EDIT));

// naètení textu z editoru
		if (name != NULL)
			name->GetWindowText(txt);			// naètení textu do bufferu

// vytvoøení nového textu nebo zmìna aktuálního textu
		if (item->name == -1)					// byl text dosud implicitní ?
			item->name = buf->m_Text->Add(txt);	// vytvoøení nového textu
		else
			buf->m_Text->Set(item->name, txt);	// zmìna aktuálního textu

// nastavení textu do stromu
		buf->m_Tree->SetItemText(item->htree,txt); // nastavení textu

// aktualizace zobrazení závislých bufferù
		if (item->counter)						// jsou reference z jiných bufferù ?
		{
			AktNameTree(BufObjID, txt, m_AktBufID, itemN);
			AktNameTree(BufLocID, txt, m_AktBufID, itemN);
			AktNameTree(BufClsID, txt, m_AktBufID, itemN);
			AktNameTree(BufEdiID, txt, m_AktBufID, itemN);
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace zobrazení jména závislých položek

void CProg::AktNameTree(short bufID, CString& txt, short bufrefID, short itemref)
{
// lokální promìnné
	CProgBuf* buf = &(m_Buf[bufID]);			// adresa bufferu
	short num = buf->m_Num;						// poèet položek v bufferu
	PROGITEM* item;								// ukazatel položek
	short i;									// ukazatel èísla položky

// cyklus pøes všechny položky
	for (i = num-1; i >= 0; i--)
	{
		item = &(buf->m_Items[i]);				// adresa položky

// test, zda je to položka s hledanou referencí
		if (item->refer == itemref)				// je to hledaná reference ?
		{

// kontrola ostatních parametrù, zda je implicitní text
			if ((item->typ == bufrefID) &&		// je to hledaný buffer ?
				(item->name == -1))				// je implicitní jméno ?
			{

// oprava textu položky ve stromu
				if (item->htree != NULL)		// je platná položka stromu ?
					buf->m_Tree->SetItemText(item->htree,txt);

// aktualizace zobrazení v závislém bufferu OBJECT -> EDIT
				if (bufID == BufObjID)
					AktNameTree(BufEdiID, txt, BufObjID, i);

// aktualizace zobrazení v závislém bufferu LOCAL -> EDIT
				if (bufID == BufLocID)
					AktNameTree(BufEdiID, txt, BufLocID, i);

// aktualizace zobrazení v závislém bufferu CLASS -> OBJECT, LOCAL
				if (bufID == BufClsID)
				{
					AktNameTree(BufObjID, txt, BufClsID, i);
					AktNameTree(BufLocID, txt, BufClsID, i);
				}
			}
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// zahájení editace jména ve stromu

void CProg::OnBeginLabelEdit(NMHDR* pNMHDR, LRESULT* pResult) 
{
// lokální promìnné, nalezení položky pod kurzorem
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// adresa bufferu
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // identifikátor položky
	short itemN = buf->SrcItem(htree);			// èislo položky
	CEdit* inplace;							// okno inplace editoru jména

// zákaz editace položky
	*pResult = TRUE;							// je pøerušení operace
	if (itemN != -1)							// je platná aktivní položka ?
		if (!(buf->m_Items[itemN].param & (PR_LOCK | PR_LOCK_DEP))) // je zákaz ?
		{

// pøíznak zahájení editace
			m_Editing = TRUE;					// pøíznak editace
			*pResult = FALSE;					// není pøerušení operace

// úschova pùvodního textu
			inplace = m_Buf[m_AktBufID].m_Tree->GetEditControl();
			if (inplace != NULL)				// je editor platný ?
				inplace->GetWindowText(m_OldName);	// úschova textu
		}
}


/////////////////////////////////////////////////////////////////////////////
// konec editace jména ve stromu

void CProg::OnEndLabelEdit(NMHDR* pNMHDR, LRESULT* pResult) 
{
// lokální promìnné
	CEdit* name;							// okno editoru jména
	CEdit* inplace;							// okno inplace editoru jména
	CString txt;							// buffer k naètení textu

// okno editoru jména
	name = (CEdit*)(MainFrame->m_wndPropBar.GetDlgItem(IDC_PROG_EDIT));

// okno inplace editoru jména
	inplace = m_Buf[m_AktBufID].m_Tree->GetEditControl();

// kontrola, zda jsou editory platné
	if ((name != NULL) && (inplace != NULL))
	{

// naètení textu z inplace editoru
		inplace->GetWindowText(txt);		// naètení textu z editoru

// je-li text nezmìnìn, nemìní se pøíznak implicitního textu
		if (txt.Compare(m_OldName))			// je text zmìnìn ?
		{

// uložení textu do editoru jména (provede se aktualizace)
			name->SetWindowText(txt);		// uložení textu do editoru

// pro prázdný text se zapne implicitní jméno
			if (!(txt.GetLength()))			// je text prázdný ?
				OnProgDef();				// zapnutí implicitního textu
		}

// zrušení pøíznaku editace
		m_Editing = FALSE;					// zrušení pøíznaku editace
	}

// návratový kód - vše OK
	*pResult = FALSE;			// není pøerušení
}


/////////////////////////////////////////////////////////////////////////////
// zahájení editace jména stiskem Alt+Enter

void CProg::OnKeyDownProg(NMHDR* pNMHDR, LRESULT* pResult) 
{
	TV_KEYDOWN* pTVKeyDown = (TV_KEYDOWN*)pNMHDR;
	
	if (pTVKeyDown->wVKey == VK_RETURN)
	{
		if (GetKeyState(VK_MENU) < 0)
			::PostMessage(m_Buf[m_AktBufID].m_Tree->m_hWnd, 
				TVM_EDITLABEL, 0, (LPARAM)m_Buf[m_AktBufID].m_Tree->GetSelectedItem());
	}
	*pResult = 0;
}


/////////////////////////////////////////////////////////////////////////////
// editace ikony

void CProg::OnProgIcon() 
{
// lokální promìnné
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktuální buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezení aktivní položky
	int itemN = buf->SrcItem(htree);			// nalezení indexu aktivní položky
	PROGITEM* item;								// ukazatel na položku
	int icon;									// editovaná ikona

	if (itemN == -1) return;
	
	item = &(buf->m_Items[itemN]);			// ukazatel na prvek

	icon = item->icon;

	if (icon == -1)
	{
		icon = m_Icon.Duplik(buf->GetIcon(itemN));
		item->icon = icon;
		buf->m_Tree->SetItemImage(item->htree,icon,icon);

		m_Ico32->DeleteImageList();
		delete m_Ico32;
		m_Ico32 = m_Icon.GenerList();

		m_Object.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Local.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Struc.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Class.SetImageList(m_Ico32, TVSIL_NORMAL);
		m_Edit.SetImageList(m_Ico32, TVSIL_NORMAL);

		if (item->counter)						// jsou reference z jiných bufferù ?
		{
			AktIconTree(BufObjID, icon, m_AktBufID, itemN);
			AktIconTree(BufLocID, icon, m_AktBufID, itemN);
			AktIconTree(BufClsID, icon, m_AktBufID, itemN);
			AktIconTree(BufEdiID, icon, m_AktBufID, itemN);
		}
	}

	m_EditItem = icon;
	SetEditMode(TYP_PIC);
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace zobrazení ikony závislých položek

void CProg::AktIconTree(short bufID, int icon, short bufrefID, short itemref)
{
// lokální promìnné
	CProgBuf* buf = &(m_Buf[bufID]);			// adresa bufferu
	short num = buf->m_Num;						// poèet položek v bufferu
	PROGITEM* item;								// ukazatel položek
	short i;									// ukazatel èísla položky

// cyklus pøes všechny položky
	for (i = num-1; i >= 0; i--)
	{
		item = &(buf->m_Items[i]);				// adresa položky

// test, zda je to položka s hledanou referencí
		if (item->refer == itemref)				// je to hledaná reference ?
		{

// kontrola ostatních parametrù, zda je implicitní ikona
			if ((item->typ == bufrefID) &&		// je to hledaný buffer ?
				(item->icon == -1))				// je implicitní ikona ?
			{

// oprava ikony položky ve stromu
				if (item->htree != NULL)		// je platná položka stromu ?
					buf->m_Tree->SetItemImage(item->htree,icon,icon);

// aktualizace zobrazení v závislém bufferu OBJECT -> EDIT
				if (bufID == BufObjID)
					AktIconTree(BufEdiID, icon, BufObjID, i);

// aktualizace zobrazení v závislém bufferu LOCAL -> EDIT
				if (bufID == BufLocID)
					AktIconTree(BufEdiID, icon, BufLocID, i);

// aktualizace zobrazení v závislém bufferu CLASS -> OBJECT, LOCAL
				if (bufID == BufClsID)
				{
					AktIconTree(BufObjID, icon, BufClsID, i);
					AktIconTree(BufLocID, icon, BufClsID, i);
				}
			}
		}
	}
}



/////////////////////////////////////////////////////////////////////////////
// zrušení položky pod kurzorem

void CProg::OnProgDel() 
{
}


/////////////////////////////////////////////////////////////////////////////
// úschova položky

void CProg::OnProgClip() 
{
}

