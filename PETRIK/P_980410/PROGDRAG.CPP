
/////////////////////////////////////////////////////////////////////////////
// zah�jen� ta�en�

void CProg::OnBeginDragProgObj(NMHDR* pNMHDR, LRESULT* pResult) 
{	m_DragSrc = BufObjID;
	m_TreeSrc = &m_Object;
	OnBeginDragProg(pNMHDR, pResult); }

void CProg::OnBeginDragProgLoc(NMHDR* pNMHDR, LRESULT* pResult) 
{	m_DragSrc = BufLocID;
	m_TreeSrc = &m_Local;
	OnBeginDragProg(pNMHDR, pResult); }

void CProg::OnBeginDragProgStr(NMHDR* pNMHDR, LRESULT* pResult) 
{	m_DragSrc = BufStrID;
	m_TreeSrc = &m_Struc;
	OnBeginDragProg(pNMHDR, pResult); }

void CProg::OnBeginDragProgCls(NMHDR* pNMHDR, LRESULT* pResult) 
{	m_DragSrc = BufClsID;
	m_TreeSrc = &m_Class;
	OnBeginDragProg(pNMHDR, pResult); }

void CProg::OnBeginDragProgEdi(NMHDR* pNMHDR, LRESULT* pResult) 
{	m_DragSrc = BufEdiID;
	m_TreeSrc = &m_Edit;
	OnBeginDragProg(pNMHDR, pResult); }

void CProg::OnBeginDragProg(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_TREEVIEW*	pnm = (NM_TREEVIEW*)pNMHDR; // notifika�n� zpr�va
	CPoint			pt; 				// sou�adnice kurzoru my�i na obrazovce
	UINT			nFlags; 			// p��znaky, kam bylo kliknuto
	RECT			rect;				// na�ten� sou�adnice textu prvku
	int 			width, height;		// zji�t�n� velikost ikon stromu

// nesm� prob�hat ta�en�
	*pResult = 0;
	if (m_Dragging) return;

// p��prava ta�en�ho a c�lov�ho prvku
	m_itemDrag = m_TreeSrc->HitTest(pnm->ptDrag, &nFlags);
	if (m_itemDrag == NULL) return;
	m_itemDragN = m_Buf[m_DragSrc].SrcItem(m_itemDrag);
	if (m_itemDragN == -1) return;
	m_itemDragPar = m_Buf[m_DragSrc].m_Items[m_itemDragN].param;
	m_itemDragModel = m_Buf[m_DragSrc].m_Items[m_itemDragN].model;
	m_itemDrop = NULL;

// zak�zan� prvek pro ta�en�
	if ((m_itemDragPar & (PR_NOMOVE | PR_LOCK | PR_LOCK_DEP)) != 0) return;

// zj�t�n� sou�adnic textu prvku
	if(!m_TreeSrc->GetItemRect(m_itemDrag,&rect,TRUE)) return;

// zji�t�n� velikosti ikony ve stromu
	ImageList_GetIconSize(
		m_TreeSrc->GetImageList(TVSIL_NORMAL)->m_hImageList,
		&width, 
		&height);

// v�po�et vzd�lenosti kurzoru my�i od po��tku prvku
	m_HotSpot = CPoint(pnm->ptDrag) - CPoint(rect.left-width-3, rect.top);
	m_TestSpot = CSize(width/2, 0);

// p��prava seznamu obr�zk� ta�en�
	m_DragList = m_TreeSrc->CreateDragImage(m_itemDrag);
	if (m_DragList == NULL) return;

// nastaven� p��znaku zah�jen� ta�en� (te� ji� se nesm� p�eru�it)
	m_Dragging = TRUE;
	m_TreeDst = NULL;
	m_DropIndex = -1;
//	m_DropParent = -1;

// v�b�r c�lov�ho prvku
	m_TreeSrc->SelectDropTarget(m_itemDrag);

// zapnut� zobrazen� obr�zku ta�en� (bez uzamyk�n� okna)
	m_DragList->DragShowNolock(TRUE);

// rozli�en� m�du p�esunu nebo kopie podle tla��tek my�i
	if (pnm->hdr.code == TVN_BEGINRDRAG)	// je prav� tla��tko ?
		m_DragRight = TRUE; 				// je prav� tla��tko
	else
		m_DragRight = FALSE;				// nen� prav� tla��tko

// korekce, kter� prvky budou v�dy jen kop�rov�ny
	if (m_itemDragPar & (PR_INTERNAL | PR_LOCK | PR_LOCK_DEP))
		m_DragRight = TRUE;

// p��prava p��znaku kop�rov�n�
	m_DragCopy = TRUE;						// bude se kop�rovat
	m_DragDelete =	!m_DragRight;			// ru�� se p�i p�esunu lev�m tla��tkem

// zapnut� kurzoru pro ta�en�
//	m_OldCursor = ::GetCursor();
	if (m_DragRight)
		m_CurAkt = m_CurCopy;
	else
		m_CurAkt = m_CurMove;
	::SetCursor(m_CurAkt);

// vytvo�en� nov�ho obr�zku ta�en�
	m_DragList->SetDragCursorImage(0, CPoint(m_HotSpot));

// zah�jen� operace ta�en�
	m_DragList->BeginDrag(0, CPoint(0,0));

// na�ten� sou�adnic kurzoru my�i
	GetCursorPos(&pt);

// pro strom struktur zru�en� v�b�ru c�le
//	if (m_DragSrc == BufStrID)
	m_TreeSrc->SelectDropTarget(NULL);

// zah�jen� operace ta�en�, z�kaz aktualizace okna
	m_DragList->DragEnter(NULL, pt - m_HotSpot);

// p�eta�en� obr�zku na aktu�ln� pozici my�i
	m_DragList->DragMove(pt - m_HotSpot);

// zah�jen� zachyt�v�n� my�i
	SetCapture();
}

/////////////////////////////////////////////////////////////////////////////
// posun my�� p�i ta�en�

void CProg::OnMouseMove(UINT nFlags, CPoint point) 
{
	UINT		flags;				// p��znaky c�lov�ho prvku
	HCURSOR 	hCurNew = m_CurNoDrag; // nov� kurzor my�i
	CPoint		ptScreen, ptTree;	// pozice ta�en� ikony na obrazovce a ve stromu
	CTreeCtrl*	OldTree;			// p�vodn� c�lov� strom
	int 		OldItem;			// p�vodn� vybran� polo�ka
	CRect		rect;				// sou�adnice prvku pod kurzorem
	int 		width, height;		// zji�t�n� velikost ikon stromu
	UINT		indent; 			// odsazov�n� polo�ek v c�lov�m stromu
	int 		AlterDstN;			// alternativn� c�l polo�en�
	
// obsluha ta�en� p�ed�lu
	if (m_Tracking)
		MoveTrack(point);
	else

// mus� prob�hat ta�en�
	if (m_Dragging)
	{
// p�ednastaven� neplatn�ho c�le operace
		OldTree = m_TreeDst;		// �schova p�vodn�ho c�lov�ho stromu
		OldItem = m_itemDropN;		// �schova p�vodn� c�lov� polo�ky
		m_TreeDst = NULL;			// nen� c�lov� strom
		m_DragDst = -1; 			// ID c�lov�ho stromu - nen�
		m_itemDrop = NULL;			// nen� c�lov� polo�ka
		m_itemDropN = -1;			// nen� c�lov� polo�ka
		m_DropIndex = -1;			// z�kaz ulo�en�
		m_DragCopy = FALSE; 		// nen� kop�rov�n�
		m_DragDelete = FALSE;		// nen� ru�en�

// p�eta�en� obr�zku na novou pozici
		ptScreen = point - m_HotSpot;
		ClientToScreen(&ptScreen);
		m_DragList->DragMove(ptScreen);

// nalezen� okna, nad kter�m je ta�eno
		if (SrcDropWin(point))
		{

// p�i ta�en� do okna struktur bude odhozen�
			if ((m_DragDst == BufStrID) && 
				(m_DragSrc != BufStrID) &&
				!m_DragRight
				)
			{
				m_DragDelete = TRUE;
				hCurNew = m_CurDelete;
			}

			else

// test, zda je ta�en� pro c�lov� okno platn�
//			if (TestDropWin())
			{			
	
// nastaven� p��znak� m�du kopie nebo p�esunu
				m_DragCopy = TRUE;
				if (m_DragRight || (m_DragDst != m_DragSrc))
					m_DragDelete = FALSE;
				else
					m_DragDelete = TRUE;

// p��prava kurzoru pro kop�rov�n� nebo p�esun
				if (m_DragDelete)
					hCurNew = m_CurMove;
				else
					hCurNew = m_CurCopy;

// p�epo�et st�edu ta�en� ikony na klientsk� sou�adnice
				ptTree = ptScreen + m_TestSpot;
				m_TreeDst->ScreenToClient(&ptTree);

// nalezen� c�lov� polo�ky pod kurzorem
				m_itemDrop = m_TreeDst->HitTest(ptTree, &flags);
				m_itemDropN = m_Buf[m_DragDst].SrcItem(m_itemDrop);

// p��prava indexu k ulo�en� polo�ky
				if (m_itemDropN == -1)
				{
					if (TestDropItem(m_itemDragModel, m_itemDragPar,
							m_DragSrc, TYP_ROOT, PR_GET_COMMAND, m_DragDst, m_itemDropN))
					{
						m_DropIndex = m_Buf[m_DragDst].m_Next;
					}
					else
					{
						m_itemDrop = NULL;
						m_DropIndex = -1;
						hCurNew = m_CurNoDrag;
						m_DragCopy = FALSE;
						m_DragDelete = FALSE;
					}
				}
				else
				{
					m_DropIndex = m_itemDropN+1;

// zji�t�n� velikosti ikony v c�lov�m stromu
					ImageList_GetIconSize(
						m_TreeDst->GetImageList(TVSIL_NORMAL)->m_hImageList,
						&width, 
						&height);

// zji�t�n� odsazov�n� potomk�
					indent = m_TreeDst->GetIndent();

// zji�t�n� pozice prvku pod kurzorem
					m_TreeDst->GetItemRect(m_itemDrop, &rect, TRUE);

// v�po�et st�edu X ikony pod kurzorem
					rect.left = rect.left - width/2 + width/10;

// p��prava alternativn�ho c�lov�ho prvku
					AlterDstN = m_Buf[m_DragDst].m_Items[m_itemDropN].parent;

// zji�t�n� rodi�e podle X polohy kurzoru
					while ((ptTree.x < rect.left) && (m_itemDropN != -1))
					{
						AlterDstN = m_itemDropN;
						m_itemDropN = m_Buf[m_DragDst].m_Items[m_itemDropN].parent;
						if (m_itemDropN != -1)
							m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
						else
							m_itemDrop = NULL;
						rect.left -= indent;
					}

// hlavn� prvek -1 je povolen, alternativn� tehdy nen� = -1
					if (m_itemDropN != -1)
					{

// na�ten� parametr� hlavn�ho c�lov�ho prvku
						m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
						m_itemDropPar = m_Buf[m_DragDst].m_Items[m_itemDropN].param;
						m_itemDropModel = m_Buf[m_DragDst].m_Items[m_itemDropN].model;

// �est hlavn�ho c�lov�ho prvku
						if (!TestDropItem(m_itemDragModel, m_itemDragPar, m_DragSrc,
							m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDropN))
						{

// jinak zm�na na vedlej�� c�lov� prvek
							m_itemDropN = AlterDstN;

// na�ten� parametr� vedlej��ho c�lov�ho prvku (nem��e b�t = -1)
							m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
							m_itemDropPar = m_Buf[m_DragDst].m_Items[m_itemDropN].param;
							m_itemDropModel = m_Buf[m_DragDst].m_Items[m_itemDropN].model;

// �est vedlej��ho c�lov�ho prvku
							if (!TestDropItem(m_itemDragModel, m_itemDragPar, m_DragSrc,
							m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDropN))
							{
								hCurNew = m_CurNoDrag;
								m_DropIndex = -1;
								m_DragCopy = FALSE;
								m_DragDelete = FALSE;
								m_itemDropN = -1;
								m_itemDrop = NULL;
							}
						}
					} // if (m_itemDropN != -1)
				} // m_itemDropN != -1

// test, zda je operace platn�
				if (m_DropIndex != -1)
				{

// kontrola, zda nen� cyklick� kop�rov�n� uvnit� okna
					if (m_DragDst == m_DragSrc)
					{
						int xitem = m_itemDropN;

						while ((xitem >= 0) && (xitem < m_Buf[m_DragDst].m_Num))
							if (xitem == m_itemDragN)
							{
								hCurNew = m_CurNoDrag;
								m_itemDropN = -1;
								m_DropIndex = -1;
								xitem = -1;
								m_DragCopy = FALSE;
								m_itemDrop = NULL;
								m_DragDelete = FALSE;
							}
							else
								xitem = m_Buf[m_DragDst].m_Items[xitem].parent;
					}

// up�esn�n� indexu a c�le, je-li hozen� za konec stromu
					if (m_itemDropN == -1)
					{
						if (m_Buf[m_DragDst].m_First > 0)
						{
							m_itemDropN = m_Buf[m_DragDst].m_First - 1;
							m_itemDrop = NULL; //m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
						}
						else
						{
							m_itemDrop = NULL;
						}
					}
					else
						m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;

					if (/*m_itemDrop == NULL*/ m_itemDropN == -1)
					{
						m_itemDropModel = TYP_ROOT;
						m_itemDropPar = PR_GET_COMMAND;
					}
					else
					{
						if ((m_DragDst == BufLocID) && (m_itemDropN == (m_Buf[m_DragDst].m_First-1)))
							m_itemDropModel = TYP_ROOT;
						else
							m_itemDropModel = m_Buf[m_DragDst].m_Items[m_itemDropN].model;
						m_itemDropPar = m_Buf[m_DragDst].m_Items[m_itemDropN].param;
					}

					if (!TestDropItem(m_itemDragModel, m_itemDragPar,
							m_DragSrc, m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDropN))
					{
						m_DropIndex = -1;
						hCurNew = m_CurNoDrag;
						m_DragCopy = FALSE;
						m_itemDrop = NULL;
						m_itemDropN = -1;
						m_DragDelete = FALSE;
					}

				} // if(m_DropIndex != -1)
			} // if(TestDropWin())
		} // if(SrcDropWin(point))

// nastaven� nov�ho kurzoru my�i
		if (hCurNew != m_CurAkt)
		{
			m_CurAkt = hCurNew;
			::SetCursor(m_CurAkt);
		}

// zru�en� v�b�ru star� c�lov� polo�ky p�i zm�n� okna stromu
		if ((OldTree != NULL) && (OldTree != m_TreeDst))
		{
			m_DragList->DragLeave(NULL);
			OldTree->SelectDropTarget(NULL);
			m_DragList->DragEnter(NULL, ptScreen);
		}

// v�b�r nov� c�lov� polo�ky
		if (((m_itemDropN != OldItem) || (OldTree != m_TreeDst))
			&& (m_TreeDst != NULL))
		{
			m_DragList->DragLeave(NULL);
			m_TreeDst->SelectDropTarget(m_itemDrop);
			m_DragList->DragEnter(NULL, ptScreen);
		}

	} // if(m_Dragging)
	CFormView::OnMouseMove(nFlags, point);
}

/////////////////////////////////////////////////////////////////////////////
// nalezen� c�lov�ho okna pod kurzorem my�i p�i ta�en�

BOOL CProg::SrcDropWin(CPoint point)
{
// p�ednastaven� neplatn� operace
	m_TreeDst = NULL;
	m_DragDst = -1;

// nalezen� okna, nad kter�m je ta�eno
	CWnd* wnd = ChildWindowFromPoint(point - m_HotSpot + m_TestSpot,
					CWP_SKIPINVISIBLE | CWP_SKIPDISABLED);
	if (wnd == NULL) return FALSE;
	HWND hwnd = wnd->m_hWnd;

// test okna ve�ejn�ch objekt�
	if (hwnd == m_Object.m_hWnd)
	{
		m_TreeDst = &m_Object;
		m_DragDst = BufObjID;
		return TRUE;
	}

// test okna lok�ln�ch objekt�
	if (hwnd == m_Local.m_hWnd)
	{
		m_TreeDst = &m_Local;
		m_DragDst = BufLocID;
		return TRUE;
	}

// test okna struktur
	if (hwnd == m_Struc.m_hWnd)
	{
		m_TreeDst = &m_Struc;
		m_DragDst = BufStrID;
		return TRUE;
	}

// test okna t��d
	if (hwnd == m_Class.m_hWnd)
	{
		m_TreeDst = &m_Class;
		m_DragDst = BufClsID;
		return TRUE;
	}

// test okna editace
	if (hwnd == m_Edit.m_hWnd)
	{
		m_TreeDst = &m_Edit;
		m_DragDst = BufEdiID;
		return TRUE;
	}

// okno nenalezeno
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// test povolen� spojen� dvou prvk�

BOOL CProg::TestDropItem(int srcModel, int srcPar, int srcBuff, int dstModel,
						 int dstPar, int dstBuff, int dstItem)
{
	if (dstPar & (PR_LOCK | PR_LOCK_DEP))			// prvek chr�n�n� proti modifikaci
		return FALSE;

	switch (dstBuff)
	{
///////////////////////// c�lem okno objekt�
	case BufObjID:
		if (srcBuff == BufEdiID) return FALSE;		// z editoru nelze nikdy t�hnout

		if (srcBuff == BufLocID) return FALSE;		// z lok�ln�ch objekt� nelze nikdy t�hnout

		if ((srcBuff == BufStrID) && 
			(srcModel != TYP_GROUP) && 
			(srcModel != TYP_LIST)) return FALSE;	// z okna struktur jen skupinu a seznam

		if ((dstModel != TYP_GROUP) &&				// c�lem jen skupina nebo ROOT
			(dstModel != TYP_ROOT)) return FALSE;

		switch (srcModel)
		{
		case TYP_GROUP:
		case TYP_LIST:
		case TYP_NUM:
		case TYP_FUNC:
		case TYP_REAL:
		case TYP_BOOL:
		case TYP_TEXT:
		case TYP_PIC:
		case TYP_MAP:
		case TYP_SND:
		case TYP_MUS:
		case TYP_SPRITE:
		case TYP_DIALOG:
		case TYP_EVENT:
		case TYP_TXT:
		case TYP_CLASS:
			return TRUE;
		}
		return FALSE;

////////////////////////// c�lem okno editoru
	case BufEdiID:
// z t��d nelze nikdy t�hnout
		if (srcBuff == BufClsID) return FALSE;

// skupinu objekt� nelze t�hnout
		if (((srcBuff == BufObjID) || (srcBuff == BufLocID)) && 
			(srcModel == TYP_GROUP)) return FALSE;

// test, zda je povolen pouze jeden parametr
		if (((dstPar & PR_ONE) != 0) && (dstItem != -1))
		{
			if (m_Buf[dstBuff].m_Items[dstItem].items > 1)
			{
				return FALSE;
			}
		}

// p�eta�en� p��kazu
		if (((srcPar & PR_AS_COMMAND) != 0) &&
			((dstPar & PR_GET_COMMAND) != 0)) return TRUE;

// p�eta�en� v�razu
		if (((srcPar & PR_AS_EXPRES) != 0) &&
			((dstPar & PR_GET_EXPRES) != 0)) return TRUE;

// p�eta�en� logick�ho v�razu
		if (((srcPar & PR_AS_BOOL) != 0) &&
			((dstPar & PR_GET_BOOL) != 0)) return TRUE;

// p�eta�en� v�tve CASE
		if (srcModel == TYP_CASE_ON)
		{
			if (dstModel == TYP_CASE)
				return TRUE;
			else
				return FALSE;
		}

// p�eta�en� testu v�tve CASE
		if (srcModel == TYP_CASE_TEST)
		{
			if (dstModel == TYP_CASE_ON)
				return TRUE;
			else
				return FALSE;
		}

// p�eta�en� ��slice do ��seln� konstanty
		if (dstModel == TYP_NUM)
		{
			switch (srcModel)
			{
			case TYP_CIS:
			case TYP_TECKA:
			case TYP_MINUS:
			case TYP_EXPONENT:
				return TRUE;
			}
			return FALSE;
		}

// p�eta�en� textu
		switch (srcModel)
		{
		case TYP_FTN:
		case TYP_FT:
		case TYP_TXT:
		case TYP_FTT:
		case TYP_FTNT:
		case TYP_TEXT:
			switch (dstModel)
			{
			case TYP_FTT:
			case TYP_FTNT:
			case TYP_FNT:
			case TYP_TEXT:
			case TYP_EQU_TEXT:
				return TRUE;
			}
			return FALSE;
		}

// p�eta�en� obr�zku
		if (srcModel == TYP_PIC)
		{
			if ((dstModel == TYP_PIC) ||
					(dstModel == TYP_EQU_PIC))
				return TRUE;
			else
				return FALSE;
		}

// p�eta�en� prom�nn�
		switch (srcModel)
		{
		case TYP_TEXT:
		case TYP_PIC:
		case TYP_MAP:
		case TYP_SND:
		case TYP_MUS:
		case TYP_SPRITE:
		case TYP_DIALOG:
		case TYP_EVENT:
		case TYP_CLASS:
			if (srcModel == dstModel)
				return TRUE;
			else
				return FALSE;
		}



		return FALSE;

////////////////////////// c�lem okno lok�ln�ch objekt�
	case BufLocID:
		if (srcBuff == BufEdiID) return FALSE;		// z editoru nelze nikdy t�hnout

		if (srcBuff == BufObjID) return FALSE;		// z objekt� nelze nikdy t�hnout

		if ((srcBuff == BufStrID) && 
			(srcModel != TYP_GROUP) && 
			(srcModel != TYP_LIST)) return FALSE;	// z okna struktur jen skupinu a seznam

		if ((dstModel != TYP_GROUP) &&				// c�lem jen skupina, ROOT nebo parametr
			(dstModel != TYP_ROOT) &&
			(dstModel != TYP_IPARAM) &&
			(dstModel != TYP_OPARAM)) return FALSE;

// test, zda je povolen pouze jeden parametr
		if (((dstPar & PR_ONE) != 0) && (dstItem != -1))
		{
			if (m_Buf[dstBuff].m_Items[dstItem].items > 1)
			{
				return FALSE;
			}
		}

		switch (srcModel)
		{
		case TYP_GROUP:
		case TYP_LIST:
		case TYP_NUM:
		case TYP_FUNC:
		case TYP_REAL:
		case TYP_BOOL:
		case TYP_TEXT:
		case TYP_PIC:
		case TYP_MAP:
		case TYP_SND:
		case TYP_MUS:
		case TYP_SPRITE:
		case TYP_DIALOG:
		case TYP_EVENT:
		case TYP_TXT:
		case TYP_CLASS:
			return TRUE;
		}
		return FALSE;


	}
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// ukon�en� ta�en� uvoln�n�m tla��tka my�i

void CProg::OnLButtonUp(UINT nFlags, CPoint point) 
{
	if (m_Tracking)
		EndTrack();
	else
		OnButtonUp();	
	CFormView::OnLButtonUp(nFlags, point);
}

void CProg::OnRButtonUp(UINT nFlags, CPoint point) 
{
	OnButtonUp();
	CFormView::OnRButtonUp(nFlags, point);
}

void CProg::OnButtonUp()
{
// test, zda prob�h� ta�en�
	if (m_Dragging)
	{
// ukon�en� p��znaku ta�en�
		m_Dragging = FALSE;

// pozastaven� ta�en�
		m_DragList->DragLeave(NULL);

// ukon�en� ta�en�
		m_DragList->EndDrag();

// zru�en� seznamu obr�zk� ta�en�
		delete m_DragList;
		m_DragList = NULL;

// zru�en� v�b�ru c�le operace u c�lov�ho okna
		if (m_TreeDst != NULL)
			m_TreeDst->SelectDropTarget(NULL);

// uvoln�n� zachyt�v�n� my�i
		ReleaseCapture();

// zru�en� p�ekreslen� c�lov�ho prvku
		::SetCursor(m_CurArrow /*m_OldCursor*/);



//		if ((m_Buf[m_DragSrc].m_Items[m_itemDragN].counter) &&
//			(m_DragDelete && !m_DragCopy))
//			m_DragDelete = FALSE;



// test, zda nen� jen p�eta�en� na m�st�
		if (m_DragCopy || m_DragDelete)
		{

			int mode = 1;
			if (m_DragCopy) mode = 0;
			if (m_DragDelete) mode++;
			DragItem(m_DragSrc, m_itemDragN, m_DragDst, m_DropIndex, m_itemDropN, mode);


					UpdateLock();

/*
			if ((m_DragDst != m_DragSrc) ||
				((m_itemDragN != m_DropIndex) && (m_itemDragN != m_DropIndex-1)) ||
				(m_Buf[m_DragSrc].m_Items[m_itemDragN].parent != m_itemDropN) ||
				!m_DragDelete)
			{
				int newDst;
// kopie prvku
				if (m_DragCopy)
				{
					newDst = m_Buf[m_DragDst].Copy(m_DropIndex, m_itemDropN, m_DragSrc, m_itemDragN);

					if (m_DragSrc == m_DragDst)
						if (newDst <= m_itemDragN)
							m_itemDragN += m_Buf[m_DragDst].m_Items[newDst].items;	

					m_TreeDst->SetFocus();
					if ((newDst != -1) && (newDst < m_Buf[m_DragDst].m_Num))
						m_TreeDst->Select(m_Buf[m_DragDst].m_Items[newDst].htree, TVGN_CARET | TVGN_DROPHILITE);
				}

// p�i p�eta�en� p�esm�rov�n� referenc�
				if ((m_DragSrc == m_DragDst) && m_DragCopy && m_DragDelete && (m_DragSrc != BufEdiID))
				{
					int nFirst = m_itemDragN;
					int nLast = nFirst + m_Buf[m_DragSrc].m_Items[m_itemDragN].items - 1;
					
					for (int b = 0; b < PROGBUFNUM; b++)
					{
						if (b != m_DragSrc)
						{
							CProgBuf* buf = &m_Buf[b];
							PROGITEM* item;
							for (int i = buf->m_Num-1; i >= 0; i--)
							{
								item = &(buf->m_Items[i]);

								if (item->typ == m_DragSrc)
								{
									if ((item->refer >= nFirst) &&
										(item->refer <= nLast))
									{
										m_Buf[m_DragSrc].m_Items[item->refer].counter--;
										item->refer = item->refer - nFirst + newDst;
										m_Buf[m_DragDst].m_Items[item->refer].counter++;
									}
								}
							}
						}
					}
				}

// zru�en� ta�en�ho prvku
				if (m_DragDelete)
					m_Buf[m_DragSrc].Delete(m_itemDragN);

// zalo�en� deklarace (je kopie, ne p�esun)
				else
				{
					PROGITEM pri;
					pri.icon = -1;
					pri.name = -1;
					pri.childs = 0;
					pri.items = 1;
					pri.htree = NULL;
					pri.counter = 0;
					pri.parent = -1;
					pri.model = TYP_NONE;

					if (((m_DragDst == BufObjID) || (m_DragDst == BufLocID)) &&
						((m_itemDragPar & PR_FUNC) != 0))
					{
						pri.typ = m_DragDst;
						pri.refer = newDst;
						pri.param = PR_NOMOVE | PR_EXP;
						m_BufEdi.Insert(&pri);

						if (m_DragDst == BufLocID)
							DblclkLocal(newDst);
					}
		
					if ((m_DragDst == BufObjID) &&
						((m_itemDragPar & PR_FUNC) != 0))
					{
						int par;

						pri.typ = m_DragDst;
						pri.refer = newDst;
						pri.param = PR_NOMOVE | PR_EXP;
						par = m_BufLoc.Insert(&pri);

						pri.typ = BufIntID;
						pri.refer = FncOut;
						pri.parent = par;
						pri.model = TYP_OPARAM;
						pri.param = PR_NOMOVE | PR_ONE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL;
						m_BufLoc.Insert(&pri);

						pri.refer = FncPar;
						pri.model = TYP_IPARAM;
						pri.param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL;
						m_BufLoc.Insert(&pri);

						DblclkObject(newDst);
					}

				}

			}
*/
		}
		DispName();
	}
}


/////////////////////////////////////////////////////////////////////////////
// kopie, p�eta�en� nebo odhozen� polo�ky
//
// parametry:
//		srcID	- zdrojov� buffer
//		src		- zdrojov� index
//		dstID	- c�lov� buffer
//		dst		- c�lov� index
//		parent	- index rodi�e v c�lov�m bufferu
//		mode	- m�d operace (0 = kopie, 1 = p�esun, 2 = zru�en�)
//
// vrac� nov� index c�lov� polo�ky
//
// p�i p�eta�en� na m�st� se nic neprovede
// na p�eta�enou polo�ku se zam��� fokus

short CProg::DragItem(short srcID, short src, short dstID, short dst, short parent, short mode)
{
// lok�ln� prom�nn�
	short i, b;											// pracovn� ��ta�e
	short last;											// posledn� p�etahovan� zdrojov� polo�ka
	CProgBuf* buf;										// adresa bufferu p�i korekci referenc�
	PROGITEM* item;										// adresa korigovan� polo�ky
	PROGITEM pri;										// polo�ka k dopln�n� (deklarace)
	short refer;										// referen�n� index korigovan� polo�ky

// kontrola, zda nen� jen p�eta�en� polo�ky na m�st�
	if	(
		 (mode == 1) &&									// je p�esun ?
		 (srcID == dstID) &&							// je operace v jednom okn� ?
		 (src == dst || src == dst-1) &&				// je zdrojov� a c�lov� pozice shodn� ?
		 (m_Buf[srcID].m_Items[src].parent == parent)	// je shodn� rodi� ?
		)
		return dst;										// p�i p�eta�en� na m�st� se nic neprovede

// proveden� kopie polo�ky
	if (mode <= 1)										// je kopie nebo p�esun ?
	{
		dst = m_Buf[dstID].Copy(dst, parent, srcID, src, mode == 1);	// kopie polo�ky

// oprava indexu zdrojov� polo�ky, 
		if (srcID == dstID)								// je operace v jednom okn� ?
			if (dst <= src)								// je c�lov� polo�ka p�ed zdrojovou ?
				src += m_Buf[dstID].m_Items[dst].items;	// oprava indexu zdrojov� polo�ky

// zam��en� fokusu na c�lov� strom a polo�ku
		if (m_Buf[dstID].m_Tree != NULL)
		{
			m_Buf[dstID].m_Tree->SetFocus();			// zam��en� na strom v okn�
			if ((dst > -1)	&& (dst < m_Buf[dstID].m_Num))	// je c�lov� polo�ka platn� ?
				m_Buf[dstID].m_Tree->Select(m_Buf[dstID].	// zam��en� na polo�enou polo�ku
					m_Items[dst].htree, TVGN_CARET | TVGN_DROPHILITE);
		}
	}

// p�i p�esunu v jednom okn� p�esm�rov�n� referenc� na polo�ky
	if ((mode == 1)	&&	(srcID == dstID))				// je p�esun v jednom okn� ?
	{
		last = src + m_Buf[srcID].m_Items[src].items - 1; // posledn� p�etahovan� polo�ka
					
		for (b = 0; b < PROGBUFNUM; b++)				// cyklus p�es v�echny buffery
		{
			if (b != srcID)								// p�esko�en� okna s p�etahovanou polo�kou
			{
				buf = &m_Buf[b];						// adresa bufferu

				for (i = buf->m_Num-1; i >= 0; i--)		// cyklus p�es v�echny polo�ky (shora dol�)
				{
					item = &(buf->m_Items[i]);			// adresa testovan� polo�ky

					if (item->typ == srcID)				// je deklara�n� odkaz na tento buffer ?
					{
						refer = item->refer;			// reference z testovan� polo�ky

						if ((refer >= src) &&			// ukazuje na p�etahovanou polo�ku ?
							(refer <= last))
						{
							m_Buf[srcID].m_Items[refer].counter--; // sn�en� ��ta�e referenc�
							item->refer = refer - src + dst;	// p�esm�rov�n� reference
							m_Buf[dstID].m_Items[item->refer].counter++; // zv��en� ��ta�e referenc�
						}
					}
				}
			}
		}
	}

// zru�en� definice polo�ky
	short data = m_Buf[srcID].m_Items[src].data;
	short index = m_Buf[srcID].m_Items[src].index;

	if ((mode >= 1) && 
		(index != -1) &&
		((data == BufLocID) || (data == BufEdiID)))
	{
		m_Buf[data].Delete(index);
		m_Buf[srcID].m_Items[src].index = -1;
	}

// zru�en� ta�en�ho prvku p�i m�du p�esunu nebo zru�en�
	if (mode >= 1) 
	{
		if ((dstID == srcID) && (src < dst))
			dst -= m_Buf[srcID].m_Items[src].items;
		m_Buf[srcID].Delete(src);
	}

// zalo�en� deklarace p�i kopii funkce do lok�ln�ch nebo glob�ln�ch objekt�
	if ( (mode == 0) &&										// je kopie polo�ky ?
		(m_Buf[dstID].m_Items[dst].model == TYP_FUNC) &&	// je to funkce ?
		((dstID == BufObjID) || (dstID == BufLocID)))		// c�lem n�kter� okno objekt� ?
	{

// p�i kopii z okna t��d se mus� zalo�it nov� deklarace
		if (dstID != srcID)								// je kop�rov�n� z jin�ho okna
		{
// vytvo�en� deklarace v edita�n�m okn�
			pri.param = PR_NOMOVE | PR_EXP | PR_GET_COMMAND; // parametry
			pri.model = TYP_FUNC;						// model - jako funkce
			pri.typ = -1;								// blok s deklarac� - nepou��v� se
			pri.refer = -1;								// index deklarace - nepou��v� se
			pri.data = -1;								// nen� buffer s daty
			pri.index = -1;								// nen� index s daty
			pri.parent = -1;							// nen� rodi�
			pri.icon = INTERNALNUM;						// ikona (nepou��v� se)
			pri.name = 0;								// jm�no (nepou��v� se)
			refer = m_BufEdi.Insert(&pri);				// vlo�en� polo�ky do edita�n�ho stromu

// inicializace odkazu z funkce na data pro lok�ln� buffer
			if (dstID == BufLocID)						// je c�lem okno lok�ln�ch objekt� ?
			{
				m_Buf[dstID].m_Items[dst].data = BufEdiID;	// identifik�tor edita�n�ho bloku
				m_Buf[dstID].m_Items[dst].index = refer;	// index datov� polo�ky
			}
			else
			{

// vytvo�en� deklarace v okn� lok�ln�ch objekt�
				pri.data = BufEdiID;					// odkaz na edita�n� buffer
				pri.index = refer;						// index 
				pri.parent = m_BufLoc.Insert(&pri);		// vlo�en� polo�ky do lok�ln�ch objekt�

// vlo�en� z�hlav� pro vstupn� parametry
				pri.param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL; // parametry
				pri.model = TYP_IPARAM;					// model - vstupn� parametry
				pri.typ = BufIntID;						// deklarace je v intern�ch funkc�ch
				pri.refer = FncPar;						// reference na vstupn� parametry
				pri.data = -1;							// nejsou data
				pri.index = -1;
				pri.icon = -1;							// ikona (implicitn�)
				pri.name = -1;							// jm�no (implicitn�)
				m_BufLoc.Insert(&pri);					// vlo�en� polo�ky do bufferu

// vlo�en� z�hlav� pro v�stupn� parametr
				pri.param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL | PR_ONE; // parametry
				pri.model = TYP_OPARAM;					// model - v�stupni parametr
				pri.refer = FncOut;						// reference na v�stupn� parametr
				m_BufLoc.Insert(&pri);					// vlo�en� polo�ky do bufferu

// inicializace odkazu z funkce na data pro glob�ln� buffer
				m_Buf[dstID].m_Items[dst].data = BufLocID;	// identifik�tor lok�ln�ho bloku
				m_Buf[dstID].m_Items[dst].index = pri.parent; // index datov� polo�ky
			}
		}

	}

// p�epnut� na vlo�enou polo�ku funkce (je to pot�ebn� i p�i kop�rov�n� v jednom okn� !)
		if (dstID == BufLocID)						// je c�lem okno lok�ln�ch objekt� ?
			DblclkLocal(dst);						// aktualizace lok�ln�ch objekt�

		if (dstID == BufObjID)						// je c�lem okno glob�ln�ch objekt� ?
			DblclkObject(dst);						// aktualizace glob�ln�ch objekt�

// navr�cen� indexu c�lov� polo�ky
	return dst;						// nov� index c�lov� polo�ky
}


