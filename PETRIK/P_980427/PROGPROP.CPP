
/////////////////////////////////////////////////////////////////////////////
//																		   //
//						obsluha vlastnost� prvk�						   //
//																		   //
/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
// p�epnut� stavu LOCK prvku pod kurzorem pomoc� tla��tka LOCK

void CProg::OnProgLock() 
{
// lok�ln� prom�nn�, nalezen� aktu�ln�ho prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktu�ln� buffer
	CTreeCtrl* tree = buf->m_Tree;				// strom v aktu�ln�m bufferu
	HTREEITEM htree = tree->GetSelectedItem();	// nalezen� aktivn�ho prvku
	int itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn�ho prvku
	unsigned short* param;						// ukazatel na parametry prvku

// zm�na p��znaku uzamknut�
	if (itemN != -1)							// pokud je vybr�n n�jak� prvek
	{
		param = &(buf->m_Items[itemN].param);	// ukazatel na parametry prvku
		*param ^= PR_LOCK;						// zm�na p�iznaku uzam�en�

// aktualizace zobrazen� prvku ve stromu
		if (*param & (PR_LOCK | PR_LOCK_DEP))	// je prvek uzam�en ?
			tree->SetItemState(htree, TVIS_BOLD, TVIS_BOLD); // zapnut� zv�razn�n�
		else
			tree->SetItemState(htree, 0, TVIS_BOLD);	// vypnut� zv�razn�n�

// aktualizace prvk� v bufferech
		UpdateLock();							// aktualizace buffer�
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace stavu p�ep�nac�ho tla��tka LOCK (prvek uzam�en)

void CProg::OnUpdateProgLock(CCmdUI* pCmdUI) 
{
// lok�ln� prom�nn�, nalezen� aktu�ln�ho prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktu�ln� buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezen� aktivn�ho prvku
	int itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn�ho prvku
	unsigned short* param;						// ukazatel na parametry prvku

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybr�n n�jak� prvek
	{
		param = &(buf->m_Items[itemN].param);	// ukazatel na parametry prvku

// z�kaz tla��tka, je-li prvek z�visle uzam�en
		if (*param & PR_LOCK_DEP)				// je prvek z�visle uzam�en ?
			pCmdUI->Enable(FALSE);				// prvek uzam�en - z�kaz tla��tka
		else
			pCmdUI->Enable(TRUE);				// prvek odemknut - povolen� tla��tka

// nastaven� stavu tla��tka
		if (*param & PR_LOCK)					// je prvek uzam�en ?
			pCmdUI->SetCheck(1);				// prvek uzam�en - tla��tko stisknuto
		else
			pCmdUI->SetCheck(0);				// prvek odemknut - tla��tko nestisknuto
	}

// nen� vybr�n prvek - tla��tko nedefinovan�, ale povolen�
	else
	{
		pCmdUI->Enable(TRUE);					// tla��tko povoleno
		pCmdUI->SetCheck(2);					// tla��tko nedefinovan�
	}
}


/////////////////////////////////////////////////////////////////////////////
// p�epnut� stavu OFF prvku pod kurzorem pomoc� tla��tka OFF

void CProg::OnProgOff() 
{
// lok�ln� prom�nn�, nalezen� aktu�ln�ho prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktu�ln� buffer
	CTreeCtrl* tree = buf->m_Tree;				// strom v aktu�ln�m bufferu
	HTREEITEM htree = tree->GetSelectedItem();	// nalezen� aktivn�ho prvku
	int itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn�ho prvku
	unsigned short* param;						// ukazatel na parametry prvku

// zm�na p��znaku vypnut�
	if (itemN != -1)							// pokud je vybr�n n�jak� prvek
	{
		param = &(buf->m_Items[itemN].param);	// ukazatel na parametry prvku
		*param ^= PR_OFF;						// zm�na p��znaku vypnut�

// aktualizace zobrazen� prvku ve stromu
		if (*param & (PR_OFF | PR_OFF_DEP))		// je prvek vypnut ?
			tree->SetItemState(htree, TVIS_CUT, TVIS_CUT); // zapnut� ze�ednut�
		else
			tree->SetItemState(htree, 0, TVIS_CUT);		// vypnut� ze�ednut�

// aktualizace prvk� v bufferech
		UpdateLock();							// aktualizace buffer�
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace stavu p�ep�nac�ho tla��tka OFF (prvek vypnut)

void CProg::OnUpdateProgOff(CCmdUI* pCmdUI) 
{
// lok�ln� prom�nn�, nalezen� aktu�ln�ho prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktu�ln� buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezen� aktivn�ho prvku
	int itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn�ho prvku
	unsigned short* param;						// ukazatel na parametry prvku

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybr�n n�jak� prvek
	{
		param = &(buf->m_Items[itemN].param);	// ukazatel na parametry prvku

// z�kaz tla��tka, je-li prvek uzam�en
		if (*param & (PR_LOCK | PR_LOCK_DEP))	// je prvek uzam�en ?
			pCmdUI->Enable(FALSE);				// prvek uzam�en - z�kaz tla��tka
		else
			pCmdUI->Enable(TRUE);				// prvek odemknut - povolen� tla��tka

// nastaven� stavu tla��tka
		if (*param & PR_OFF)					// je prvek vypnut ?
			pCmdUI->SetCheck(1);				// prvek vypnut - tla��tko stisknuto
		else
			pCmdUI->SetCheck(0);				// prvek nen� vypnut - tla��tko nestisknuto
	}

// nen� vybr�n prvek - tla��tko nedefinovan�, ale povolen�
	else
	{
		pCmdUI->Enable(TRUE);					// tla��tko povoleno
		pCmdUI->SetCheck(2);					// tla��tko nedefinovan�
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace p��znak� LOCK a OFF buffer�
// Pozor - stav prvk� stromu mus� souhlasit se stavem v seznamu !!!

void CProg::UpdateLock()
{
// prvn� pr�chod
// buffery LOCALL a EDIT jsou aktualizov�ny z OBJECT a CLASS
	UpdateLockBuf(BufStrID);			// buffer struktur
	UpdateLockBuf(BufClsID);			// buffer t��d
	UpdateLockBuf(BufObjID);			// buffer glob�ln�ch objekt�

// druh� pr�chod - n�kter� buffery jsou aktualizov�ny k��ov�
	UpdateLockBuf(BufClsID);			// buffer t��d
	UpdateLockBuf(BufObjID);			// buffer glob�ln�ch objekt�

// t�et� pr�chod - lok�ln� buffer je dvojn�sobn� k��ov� z�visl�
	UpdateLockBuf(BufClsID);			// buffer t��d
	UpdateLockBuf(BufObjID);			// buffer glob�ln�ch objekt�
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace p��znak� LOCK a OFF pro jeden buffer

void CProg::UpdateLockBuf(short bufID)
{
// lok�ln� prom�nn�
	CProgBuf* buf = &(m_Buf[bufID]);	// adresa bufferu
	CTreeCtrl* tree = buf->m_Tree;		// adresa stromu bufferu
	short num = buf->m_Num;				// po�et polo�ek v bufferu
	short index;						// pracovn� index polo�ky

// cyklus p�es v�echny polo�ky
	for (index = 0; index < num; index += buf->m_Items[index].items)
		UpdateLockItem(tree, &(buf->m_Items[index]), 0);
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace p��znak� LOCK a OFF pro jednu polo�ku
// - nesm� realokovat buffer polo�ek, uchov�vaj� se ukazatele na polo�ky

void CProg::UpdateLockItem(CTreeCtrl* tree, PROGITEM* item, int state)
{
// lok�ln� prom�nn�
	unsigned short* param;			// adresa parametr� polo�ky
	int oldstate;					// star� stav polo�ky
	short childs;					// ��ta� potomk�

// oprava nov�ho stavu podle deklara�n� polo�ky
	if (item->refer != -1)
	{
		param = &(m_Buf[item->typ].m_Items[item->refer].param);
		if (*param & (PR_LOCK | PR_LOCK_DEP)) state |= TVIS_BOLD;
		if (*param & (PR_OFF | PR_OFF_DEP)) state |= TVIS_CUT;		
	}

// p��prava star�ho stavu polo�ky
	param = &(item->param);			// adresa parametr� aktu�ln� polo�ky
	oldstate = 0;
	if (*param & (PR_LOCK | PR_LOCK_DEP)) oldstate = TVIS_BOLD;
	if (*param & (PR_OFF | PR_OFF_DEP)) oldstate |= TVIS_CUT;

// nastaven� z�visl�ch p��znak� (pro ROOT definici se nenuluje, je ji� nastaveno)
	*param &= ~(PR_LOCK_DEP | PR_OFF_DEP);
	if (state & TVIS_BOLD) *param |= PR_LOCK_DEP;
	if (state & TVIS_CUT) *param |= PR_OFF_DEP;

// oprava stavu polo�ky stromu
	if (*param & (PR_LOCK | PR_LOCK_DEP)) state |= TVIS_BOLD;
	if (*param & (PR_OFF | PR_OFF_DEP)) state |= TVIS_CUT;

// oprava stavu zobrazen� polo�ky stromu
	if ((item->htree != NULL) && (state != oldstate))
		tree->SetItemState(item->htree, state, TVIS_CUT | TVIS_BOLD);

// nastaven� parametr� defini�n� polo�ky
	if ((item->index != -1) && ((item->data == BufLocID) || (item->data == BufEdiID)))
		UpdateLockItem(m_Buf[item->data].m_Tree, 
			&(m_Buf[item->data].m_Items[item->index]), state);

// nastaven� potomk�
	childs = item->childs;			// po�et potomk� polo�ky
	item++;							// adresa prvn�ho potomka
	for (; childs > 0; childs--)
	{
		UpdateLockItem(tree, item, state);
		item += item->items;		// adresa dal��ho potomka
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace stavu p�ep�nac�ho tla��tka DEF (implicitn� jm�no)

void CProg::OnUpdateProgDef(CCmdUI* pCmdUI) 
{
// lok�ln� prom�nn�, nalezen� aktu�ln�ho prvku
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktu�ln� buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezen� aktivn�ho prvku
	int itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn�ho prvku
	PROGITEM* item;								// ukazatel na prvek

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybr�n n�jak� prvek
	{
		item = &(buf->m_Items[itemN]);			// ukazatel na prvek

// z�kaz tla��tka, je-li prvek uzam�en
		if (item->param & (PR_LOCK | PR_LOCK_DEP))	// je prvek uzam�en ?
			pCmdUI->Enable(FALSE);				// prvek uzam�en - z�kaz tla��tka
		else
			pCmdUI->Enable(TRUE);				// prvek odemknut - povolen� tla��tka

// nastaven� stavu tla��tka
		if (item->name == -1)					// je implicitn� jm�no ?
			pCmdUI->SetCheck(1);				// implicitn� jm�no - tla��tko stisknuto
		else
			pCmdUI->SetCheck(0);				// nen� implicitn� jm�no - tla��tko nestisknuto
	}

// nen� vybr�n prvek - tla��tko nedefinovan�, ale povolen�
	else
	{
		pCmdUI->Enable(TRUE);					// tla��tko povoleno
		pCmdUI->SetCheck(2);					// tla��tko nedefinovan�
	}
}


/////////////////////////////////////////////////////////////////////////////
// p�ep�na� DEF (implicitn� jm�no prvku)

void CProg::OnProgDef() 
{
// lok�ln� prom�nn�, nalezen� aktu�ln� polo�ky
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktu�ln� buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezen� aktivn� polo�ky
	int itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn� polo�ky
	PROGITEM* item;								// ukazatel na polo�ku
	CString txt = _T("");						// buffer textu
	CEdit* name;								// editor jm�na prvku

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybr�n n�jak� prvek
	{
		item = &(buf->m_Items[itemN]);			// ukazatel na prvek

// test, zda je text implicitn�
		if (item->name == -1)					// je text implicitn� ?
		{

// na�ten� textu k polo�ce
			txt = buf->GetName(itemN);			// na�ten� jm�na k polo�ce

// p�id�n� textu do bufferu text�
			item->name = buf->m_Text->Add(txt);		// p�id�n� textu do bufferu
		}

// jinak uvoln�n� star�ho textu polo�ky
		else
		{
			buf->m_Text->ElementAt(item->name).Empty(); // zru�en� star�ho textu
			item->name = -1;					// zru�en� p��znaku platnosti polo�ky
		}

// aktualizace zobrazen� textu v editoru jm�na polo�ky
		DispName();								// aktualizace zobrazen� jm�na

// p��prava editoru jm�na
		name = (CEdit*)(MainFrame->m_wndPropBar.GetDlgItem(IDC_PROG_EDIT));

// na�ten� textu z editoru
		if (name != NULL)
			name->GetWindowText(txt);			// na�ten� textu do bufferu

// nastaven� textu do stromu
		buf->m_Tree->SetItemText(item->htree,txt); // nastaven� textu

// aktualizace zobrazen� z�visl�ch buffer�
		if (item->counter)						// jsou reference z jin�ch buffer� ?
		{
			AktNameTree(BufObjID, txt, m_AktBufID, itemN);
			AktNameTree(BufLocID, txt, m_AktBufID, itemN);
			AktNameTree(BufClsID, txt, m_AktBufID, itemN);
			AktNameTree(BufEdiID, txt, m_AktBufID, itemN);
		}

	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace zobrazen� jm�na polo�ky v editoru jm�na

void CProg::DispName() 
{
// lok�ln� prom�nn�, nalezen� aktu�ln� polo�ky
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktu�ln� buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezen� aktivn� polo�ky
	int itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn� polo�ky
	CEdit* name;								// editor jm�na polo�ky
	CString txt;								// nov� text k nastaven�
	CString txtold;								// p�vodn� text v okn�

// na�ten� jm�na polo�ky
	txt = buf->GetName(itemN);				// na�ten� jm�na polo�ky

// okno editoru jm�na
	name = (CEdit*)(MainFrame->m_wndPropBar.GetDlgItem(IDC_PROG_EDIT));

// nastaven� nov�ho textu do editoru jm�na
	if (name != NULL)							// je okno editoru jm�na platn� ?
	{
		name->GetWindowText(txtold);			// na�ten� star�ho textu v editoru
		if (txt.Compare(txtold))				// byl text zm�n�n ?
		{
			m_FilName = TRUE;					// p��znak pln�n� editoru jm�na
			name->SetWindowText(txt);			// nastaven� nov�ho textu editoru jm�na
			m_FilName = FALSE;					// ukon�en� pln�n� editoru jm�na
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// zm�na jm�na v editoru jm�na polo�ky

void CProg::OnChangeName() 
{
// test, zda prob�h� pln�n� editoru jm�na programem
	if (m_FilName) return;						// prob�h� pln�n� programem - konec

// lok�ln� prom�nn�, nalezen� aktu�ln� polo�ky
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktu�ln� buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezen� aktivn� polo�ky
	int itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn� polo�ky
	PROGITEM* item;								// ukazatel na polo�ku
	CString txt = _T("");						// buffer textu
	CEdit* name;								// editor jm�na prvku

// test, zda byl prvek nalezen
	if (itemN != -1)							// pokud je vybr�n n�jak� prvek
	{
		item = &(buf->m_Items[itemN]);			// ukazatel na prvek

// p��prava editoru jm�na
		name = (CEdit*)(MainFrame->m_wndPropBar.GetDlgItem(IDC_PROG_EDIT));

// na�ten� textu z editoru
		if (name != NULL)
			name->GetWindowText(txt);			// na�ten� textu do bufferu

// vytvo�en� nov�ho textu nebo zm�na aktu�ln�ho textu
		if (item->name == -1)					// byl text dosud implicitn� ?
			item->name = buf->m_Text->Add(txt);	// vytvo�en� nov�ho textu
		else
			buf->m_Text->Set(item->name, txt);	// zm�na aktu�ln�ho textu

// nastaven� textu do stromu
		buf->m_Tree->SetItemText(item->htree,txt); // nastaven� textu

// aktualizace zobrazen� z�visl�ch buffer�
		if (item->counter)						// jsou reference z jin�ch buffer� ?
		{
			AktNameTree(BufObjID, txt, m_AktBufID, itemN);
			AktNameTree(BufLocID, txt, m_AktBufID, itemN);
			AktNameTree(BufClsID, txt, m_AktBufID, itemN);
			AktNameTree(BufEdiID, txt, m_AktBufID, itemN);
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// aktualizace zobrazen� jm�na z�visl�ch polo�ek

void CProg::AktNameTree(short bufID, CString& txt, short bufrefID, short itemref)
{
// lok�ln� prom�nn�
	CProgBuf* buf = &(m_Buf[bufID]);			// adresa bufferu
	short num = buf->m_Num;						// po�et polo�ek v bufferu
	PROGITEM* item;								// ukazatel polo�ek
	short i;									// ukazatel ��sla polo�ky

// cyklus p�es v�echny polo�ky
	for (i = num-1; i >= 0; i--)
	{
		item = &(buf->m_Items[i]);				// adresa polo�ky

// test, zda je to polo�ka s hledanou referenc�
		if (item->refer == itemref)				// je to hledan� reference ?
		{

// kontrola ostatn�ch parametr�, zda je implicitn� text
			if ((item->typ == bufrefID) &&		// je to hledan� buffer ?
				(item->name == -1))				// je implicitn� jm�no ?
			{

// oprava textu polo�ky ve stromu
				if (item->htree != NULL)		// je platn� polo�ka stromu ?
					buf->m_Tree->SetItemText(item->htree,txt);

// aktualizace zobrazen� v z�visl�m bufferu OBJECT -> EDIT
				if (bufID == BufObjID)
					AktNameTree(BufEdiID, txt, BufObjID, i);

// aktualizace zobrazen� v z�visl�m bufferu LOCAL -> EDIT
				if (bufID == BufLocID)
					AktNameTree(BufEdiID, txt, BufLocID, i);

// aktualizace zobrazen� v z�visl�m bufferu CLASS -> OBJECT, LOCAL
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
// zah�jen� editace jm�na ve stromu

void CProg::OnBeginLabelEdit(NMHDR* pNMHDR, LRESULT* pResult) 
{
// lok�ln� prom�nn�, nalezen� polo�ky pod kurzorem
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// adresa bufferu
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // identifik�tor polo�ky
	short itemN = buf->SrcItem(htree);			// �islo polo�ky
	CEdit* inplace;							// okno inplace editoru jm�na

// z�kaz editace polo�ky
	*pResult = TRUE;							// je p�eru�en� operace
	if (itemN != -1)							// je platn� aktivn� polo�ka ?
		if (!(buf->m_Items[itemN].param & (PR_LOCK | PR_LOCK_DEP))) // je z�kaz ?
		{

// p��znak zah�jen� editace
			m_Editing = TRUE;					// p��znak editace
			*pResult = FALSE;					// nen� p�eru�en� operace

// �schova p�vodn�ho textu
			inplace = m_Buf[m_AktBufID].m_Tree->GetEditControl();
			if (inplace != NULL)				// je editor platn� ?
				inplace->GetWindowText(m_OldName);	// �schova textu
		}
}


/////////////////////////////////////////////////////////////////////////////
// konec editace jm�na ve stromu

void CProg::OnEndLabelEdit(NMHDR* pNMHDR, LRESULT* pResult) 
{
// lok�ln� prom�nn�
	CEdit* name;							// okno editoru jm�na
	CEdit* inplace;							// okno inplace editoru jm�na
	CString txt;							// buffer k na�ten� textu

// okno editoru jm�na
	name = (CEdit*)(MainFrame->m_wndPropBar.GetDlgItem(IDC_PROG_EDIT));

// okno inplace editoru jm�na
	inplace = m_Buf[m_AktBufID].m_Tree->GetEditControl();

// kontrola, zda jsou editory platn�
	if ((name != NULL) && (inplace != NULL))
	{

// na�ten� textu z inplace editoru
		inplace->GetWindowText(txt);		// na�ten� textu z editoru

// je-li text nezm�n�n, nem�n� se p��znak implicitn�ho textu
		if (txt.Compare(m_OldName))			// je text zm�n�n ?
		{

// ulo�en� textu do editoru jm�na (provede se aktualizace)
			name->SetWindowText(txt);		// ulo�en� textu do editoru

// pro pr�zdn� text se zapne implicitn� jm�no
			if (!(txt.GetLength()))			// je text pr�zdn� ?
				OnProgDef();				// zapnut� implicitn�ho textu
		}

// zru�en� p��znaku editace
		m_Editing = FALSE;					// zru�en� p��znaku editace
	}

// n�vratov� k�d - v�e OK
	*pResult = FALSE;			// nen� p�eru�en�
}


/////////////////////////////////////////////////////////////////////////////
// zah�jen� editace jm�na stiskem Alt+Enter

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
// lok�ln� prom�nn�
	CProgBuf* buf = &(m_Buf[m_AktBufID]);		// aktu�ln� buffer
	HTREEITEM htree = buf->m_Tree->GetSelectedItem(); // nalezen� aktivn� polo�ky
	int itemN = buf->SrcItem(htree);			// nalezen� indexu aktivn� polo�ky
	PROGITEM* item;								// ukazatel na polo�ku
	int icon;									// editovan� ikona

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

		if (item->counter)						// jsou reference z jin�ch buffer� ?
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
// aktualizace zobrazen� ikony z�visl�ch polo�ek

void CProg::AktIconTree(short bufID, int icon, short bufrefID, short itemref)
{
// lok�ln� prom�nn�
	CProgBuf* buf = &(m_Buf[bufID]);			// adresa bufferu
	short num = buf->m_Num;						// po�et polo�ek v bufferu
	PROGITEM* item;								// ukazatel polo�ek
	short i;									// ukazatel ��sla polo�ky

// cyklus p�es v�echny polo�ky
	for (i = num-1; i >= 0; i--)
	{
		item = &(buf->m_Items[i]);				// adresa polo�ky

// test, zda je to polo�ka s hledanou referenc�
		if (item->refer == itemref)				// je to hledan� reference ?
		{

// kontrola ostatn�ch parametr�, zda je implicitn� ikona
			if ((item->typ == bufrefID) &&		// je to hledan� buffer ?
				(item->icon == -1))				// je implicitn� ikona ?
			{

// oprava ikony polo�ky ve stromu
				if (item->htree != NULL)		// je platn� polo�ka stromu ?
					buf->m_Tree->SetItemImage(item->htree,icon,icon);

// aktualizace zobrazen� v z�visl�m bufferu OBJECT -> EDIT
				if (bufID == BufObjID)
					AktIconTree(BufEdiID, icon, BufObjID, i);

// aktualizace zobrazen� v z�visl�m bufferu LOCAL -> EDIT
				if (bufID == BufLocID)
					AktIconTree(BufEdiID, icon, BufLocID, i);

// aktualizace zobrazen� v z�visl�m bufferu CLASS -> OBJECT, LOCAL
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
// zru�en� polo�ky pod kurzorem

void CProg::OnProgDel() 
{
}


/////////////////////////////////////////////////////////////////////////////
// �schova polo�ky

void CProg::OnProgClip() 
{
}

