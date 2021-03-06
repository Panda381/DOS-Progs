
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
	if (m_itemDragPar & PR_INTERNAL)
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


	m_ProgMap.m_X = -1;
	m_ProgMap.m_Y = -1;

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

// ta�en� do okna editoru mapy
			if (m_DragDst == BufMapID)
			{
				CPoint pt2 = point - m_HotSpot + m_TestSpot + CPoint(0,m_ProgMap.m_IconHeight/2);
				ClientToScreen(&pt2);
				m_ProgMap.ScreenToClient(&pt2);
				m_ProgMap.OnMouseMove(nFlags, pt2);
				if ((m_ProgMap.m_X != -1) &&
					(m_ProgMap.m_Y != -1))
					hCurNew = m_CurCopy;
			}
			else

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
				if (m_DragRight || (m_DragDst != m_DragSrc) ||
					((m_DragDst == BufClsID) && (m_DragSrc == BufClsID)))
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
							m_DragSrc, TYP_ROOT, PR_GET_COMMAND, m_DragDst, m_itemDragN, m_itemDropN))
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
							m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDragN, m_itemDropN))
						{

// jinak zm�na na vedlej�� c�lov� prvek
							m_itemDropN = AlterDstN;

// na�ten� parametr� vedlej��ho c�lov�ho prvku (nem��e b�t = -1)
							m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
							m_itemDropPar = m_Buf[m_DragDst].m_Items[m_itemDropN].param;
							m_itemDropModel = m_Buf[m_DragDst].m_Items[m_itemDropN].model;

// �est vedlej��ho c�lov�ho prvku
							if (!TestDropItem(m_itemDragModel, m_itemDragPar, m_DragSrc,
							m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDragN, m_itemDropN))
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

						if ((m_DragSrc != BufClsID) && (m_DragDst != BufClsID))
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
							m_DragSrc, m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDragN, m_itemDropN))
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

	if (!m_Dragging && m_ProgMap.m_Draging)
	{
		if (m_ProgMap.m_Copy)
			::SetCursor(m_ProgMap.m_CurNoDrag);
		else
			::SetCursor(m_ProgMap.m_CurDelete);
	}

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

// okno mapy
	if ((hwnd == m_ProgMap.m_hWnd) &&
		((m_DragSrc == BufObjID) ||
		(m_DragSrc == BufLocID)) &&
		(m_itemDragModel == TYP_PIC))
	{
		m_DragDst = BufMapID;
		return TRUE;
	}

// okno nenalezeno
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// test povolen� spojen� dvou prvk�

BOOL CProg::TestDropItem(int srcModel, int srcPar, int srcBuff, int dstModel,
						 int dstPar, int dstBuff, int srcItem, int dstItem)
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

// p�eta�en� funkce
		if (srcModel == TYP_FUNC)
		{
			switch (dstModel)
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
				return TRUE;
			}
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
// zablokovat vytvo�en� skupiny v parametrech funkce �i objektu!

	case BufLocID:
		if (srcBuff == BufEdiID) return FALSE;		// z editoru nelze nikdy t�hnout

		if (srcBuff == BufObjID) return FALSE;		// z objekt� nelze nikdy t�hnout

		if ((srcBuff == BufStrID) && 
			(srcModel != TYP_GROUP) && 
			(srcModel != TYP_LIST)) return FALSE;	// z okna struktur jen skupinu a seznam

		if ((dstModel != TYP_GROUP) &&				// c�lem jen skupina, ROOT nebo parametr
			(dstModel != TYP_ROOT) &&
			(dstModel != TYP_PROPERTIES) &&
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

////////////////////////// c�lem okno t��d - nelze t�hnout
//	case BufClsID:
//		if ((srcBuff == BufStrID) && (srcModel == TYP_GROUP)) // kopie skupiny ze struktur
//			return TRUE;

//		if (srcBuff != BufClsID)
//			return FALSE;							// z jin�ch oken nelze t�hnout

//		if ((srcModel == TYP_FUNC) || (srcModel == TYP_EVENT))
//		if ((srcModel != TYP_CLASS) || (dstModel != TYP_CLASS))
//			return FALSE;							// funkci ani ud�lost nelze d�dit

//		if (srcModel != dstModel)					// mus� b�t stejn� model
//			return FALSE;

//		if (m_Buf[srcBuff].m_Items[srcItem].parent == // stejn� rodi� je OK
//			dstItem)
//			return TRUE;

//		if (srcItem == dstItem)						// bude vlastn� potomek
//			return TRUE;

//		return FALSE;
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

		if (m_DragCopy || m_DragDelete)
		{

			int mode = 1;
			if (m_DragCopy) mode = 0;
			if (m_DragDelete) mode++;

			DragItem(m_DragSrc, m_itemDragN, m_DragDst, m_DropIndex, m_itemDropN, mode);

			UpdateLock();
		}
		else
		{
			if ((m_DragDst == BufMapID) &&
				(m_ProgMap.m_X != -1) &&
				(m_ProgMap.m_Y != -1))
			{
				m_ProgMap.DragDrop(m_Buf[m_DragSrc].GetIcon(m_itemDragN));
			}
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
// proveden� kopie, p�esunu nebo zru�en� polo�ky
	switch (mode)
	{
	case 0:											// kopie
		dst = m_Buf[dstID].Copy(dst, parent, srcID, src);
		if ((srcID == dstID) &&	(dst < src))		// je c�lov� polo�ka p�ed zdrojovou ?
			src += m_Buf[dstID].m_Items[dst].items;	// oprava indexu zdrojov� polo�ky
		break;

	case 1:											// p�esun
		dst = m_Buf[dstID].MoveTre(dst, parent, src);
		break;

	case 2:
		m_Buf[srcID].DeleteTre(src);				// zru�en� polo�ky
		break;
	}

// zaji�t�n� viditelnosti
	if ((mode <= 1) && (m_Buf[dstID].m_Tree != NULL))
		m_Buf[dstID].m_Tree->EnsureVisible(m_Buf[dstID].m_Items[dst].htree);

// p�epnut� na vlo�enou polo�ku funkce (je to pot�ebn� i p�i kop�rov�n� v jednom okn� !)
	if ((mode == 0) &&
		(m_Buf[dstID].m_Items[dst].model == TYP_FUNC))
	{

		if (dstID == BufLocID)						// je c�lem okno lok�ln�ch objekt� ?
			DblclkLocal(dst);						// aktualizace lok�ln�ch objekt�

		if (dstID == BufObjID)						// je c�lem okno glob�ln�ch objekt� ?
			DblclkObject(dst);						// aktualizace glob�ln�ch objekt�
	}

	m_BufLoc.SetFirst(m_BufLoc.m_First-1);
	m_BufEdi.SetFirst(m_BufEdi.m_First-1);

	AktAllDef();								// aktualizace defini�n�ch ukazatel�

// navr�cen� indexu c�lov� polo�ky
	return dst;						// nov� index c�lov� polo�ky
}


