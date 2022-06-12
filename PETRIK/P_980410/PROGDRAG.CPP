
/////////////////////////////////////////////////////////////////////////////
// zahájení tažení

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
	NM_TREEVIEW*	pnm = (NM_TREEVIEW*)pNMHDR; // notifikaèní zpráva
	CPoint			pt; 				// souøadnice kurzoru myši na obrazovce
	UINT			nFlags; 			// pøíznaky, kam bylo kliknuto
	RECT			rect;				// naètené souøadnice textu prvku
	int 			width, height;		// zjištìná velikost ikon stromu

// nesmí probíhat tažení
	*pResult = 0;
	if (m_Dragging) return;

// pøíprava taženého a cílového prvku
	m_itemDrag = m_TreeSrc->HitTest(pnm->ptDrag, &nFlags);
	if (m_itemDrag == NULL) return;
	m_itemDragN = m_Buf[m_DragSrc].SrcItem(m_itemDrag);
	if (m_itemDragN == -1) return;
	m_itemDragPar = m_Buf[m_DragSrc].m_Items[m_itemDragN].param;
	m_itemDragModel = m_Buf[m_DragSrc].m_Items[m_itemDragN].model;
	m_itemDrop = NULL;

// zakázaný prvek pro tažení
	if ((m_itemDragPar & (PR_NOMOVE | PR_LOCK | PR_LOCK_DEP)) != 0) return;

// zjíštìní souøadnic textu prvku
	if(!m_TreeSrc->GetItemRect(m_itemDrag,&rect,TRUE)) return;

// zjištìní velikosti ikony ve stromu
	ImageList_GetIconSize(
		m_TreeSrc->GetImageList(TVSIL_NORMAL)->m_hImageList,
		&width, 
		&height);

// výpoèet vzdálenosti kurzoru myši od poèátku prvku
	m_HotSpot = CPoint(pnm->ptDrag) - CPoint(rect.left-width-3, rect.top);
	m_TestSpot = CSize(width/2, 0);

// pøíprava seznamu obrázkù tažení
	m_DragList = m_TreeSrc->CreateDragImage(m_itemDrag);
	if (m_DragList == NULL) return;

// nastavení pøíznaku zahájení tažení (teï již se nesmí pøerušit)
	m_Dragging = TRUE;
	m_TreeDst = NULL;
	m_DropIndex = -1;
//	m_DropParent = -1;

// výbìr cílového prvku
	m_TreeSrc->SelectDropTarget(m_itemDrag);

// zapnutí zobrazení obrázku tažení (bez uzamykání okna)
	m_DragList->DragShowNolock(TRUE);

// rozlišení módu pøesunu nebo kopie podle tlaèítek myši
	if (pnm->hdr.code == TVN_BEGINRDRAG)	// je pravé tlaèítko ?
		m_DragRight = TRUE; 				// je pravé tlaèítko
	else
		m_DragRight = FALSE;				// není pravé tlaèítko

// korekce, které prvky budou vždy jen kopírovány
	if (m_itemDragPar & (PR_INTERNAL | PR_LOCK | PR_LOCK_DEP))
		m_DragRight = TRUE;

// pøíprava pøíznaku kopírování
	m_DragCopy = TRUE;						// bude se kopírovat
	m_DragDelete =	!m_DragRight;			// ruší se pøi pøesunu levým tlaèítkem

// zapnutí kurzoru pro tažení
//	m_OldCursor = ::GetCursor();
	if (m_DragRight)
		m_CurAkt = m_CurCopy;
	else
		m_CurAkt = m_CurMove;
	::SetCursor(m_CurAkt);

// vytvoøení nového obrázku tažení
	m_DragList->SetDragCursorImage(0, CPoint(m_HotSpot));

// zahájení operace tažení
	m_DragList->BeginDrag(0, CPoint(0,0));

// naètení souøadnic kurzoru myši
	GetCursorPos(&pt);

// pro strom struktur zrušení výbìru cíle
//	if (m_DragSrc == BufStrID)
	m_TreeSrc->SelectDropTarget(NULL);

// zahájení operace tažení, zákaz aktualizace okna
	m_DragList->DragEnter(NULL, pt - m_HotSpot);

// pøetažení obrázku na aktuální pozici myši
	m_DragList->DragMove(pt - m_HotSpot);

// zahájení zachytávání myši
	SetCapture();
}

/////////////////////////////////////////////////////////////////////////////
// posun myší pøi tažení

void CProg::OnMouseMove(UINT nFlags, CPoint point) 
{
	UINT		flags;				// pøíznaky cílového prvku
	HCURSOR 	hCurNew = m_CurNoDrag; // nový kurzor myši
	CPoint		ptScreen, ptTree;	// pozice tažené ikony na obrazovce a ve stromu
	CTreeCtrl*	OldTree;			// pùvodní cílový strom
	int 		OldItem;			// pùvodní vybraná položka
	CRect		rect;				// souøadnice prvku pod kurzorem
	int 		width, height;		// zjištìná velikost ikon stromu
	UINT		indent; 			// odsazování položek v cílovém stromu
	int 		AlterDstN;			// alternativní cíl položení
	
// obsluha tažení pøedìlu
	if (m_Tracking)
		MoveTrack(point);
	else

// musí probíhat tažení
	if (m_Dragging)
	{
// pøednastavení neplatného cíle operace
		OldTree = m_TreeDst;		// úschova pùvodního cílového stromu
		OldItem = m_itemDropN;		// úschova pùvodní cílové položky
		m_TreeDst = NULL;			// není cílový strom
		m_DragDst = -1; 			// ID cílového stromu - není
		m_itemDrop = NULL;			// není cílová položka
		m_itemDropN = -1;			// není cílová položka
		m_DropIndex = -1;			// zákaz uložení
		m_DragCopy = FALSE; 		// není kopírování
		m_DragDelete = FALSE;		// není rušení

// pøetažení obrázku na novou pozici
		ptScreen = point - m_HotSpot;
		ClientToScreen(&ptScreen);
		m_DragList->DragMove(ptScreen);

// nalezení okna, nad kterým je taženo
		if (SrcDropWin(point))
		{

// pøi tažení do okna struktur bude odhození
			if ((m_DragDst == BufStrID) && 
				(m_DragSrc != BufStrID) &&
				!m_DragRight
				)
			{
				m_DragDelete = TRUE;
				hCurNew = m_CurDelete;
			}

			else

// test, zda je tažení pro cílové okno platné
//			if (TestDropWin())
			{			
	
// nastavení pøíznakù módu kopie nebo pøesunu
				m_DragCopy = TRUE;
				if (m_DragRight || (m_DragDst != m_DragSrc))
					m_DragDelete = FALSE;
				else
					m_DragDelete = TRUE;

// pøíprava kurzoru pro kopírování nebo pøesun
				if (m_DragDelete)
					hCurNew = m_CurMove;
				else
					hCurNew = m_CurCopy;

// pøepoèet støedu tažené ikony na klientské souøadnice
				ptTree = ptScreen + m_TestSpot;
				m_TreeDst->ScreenToClient(&ptTree);

// nalezení cílové položky pod kurzorem
				m_itemDrop = m_TreeDst->HitTest(ptTree, &flags);
				m_itemDropN = m_Buf[m_DragDst].SrcItem(m_itemDrop);

// pøíprava indexu k uložení položky
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

// zjištìní velikosti ikony v cílovém stromu
					ImageList_GetIconSize(
						m_TreeDst->GetImageList(TVSIL_NORMAL)->m_hImageList,
						&width, 
						&height);

// zjištìní odsazování potomkù
					indent = m_TreeDst->GetIndent();

// zjištìní pozice prvku pod kurzorem
					m_TreeDst->GetItemRect(m_itemDrop, &rect, TRUE);

// výpoèet støedu X ikony pod kurzorem
					rect.left = rect.left - width/2 + width/10;

// pøíprava alternativního cílového prvku
					AlterDstN = m_Buf[m_DragDst].m_Items[m_itemDropN].parent;

// zjištìní rodièe podle X polohy kurzoru
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

// hlavní prvek -1 je povolen, alternativní tehdy není = -1
					if (m_itemDropN != -1)
					{

// naètení parametrù hlavního cílového prvku
						m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
						m_itemDropPar = m_Buf[m_DragDst].m_Items[m_itemDropN].param;
						m_itemDropModel = m_Buf[m_DragDst].m_Items[m_itemDropN].model;

// est hlavního cílového prvku
						if (!TestDropItem(m_itemDragModel, m_itemDragPar, m_DragSrc,
							m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDropN))
						{

// jinak zmìna na vedlejší cílový prvek
							m_itemDropN = AlterDstN;

// naètení parametrù vedlejšího cílového prvku (nemùže být = -1)
							m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
							m_itemDropPar = m_Buf[m_DragDst].m_Items[m_itemDropN].param;
							m_itemDropModel = m_Buf[m_DragDst].m_Items[m_itemDropN].model;

// est vedlejšího cílového prvku
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

// test, zda je operace platná
				if (m_DropIndex != -1)
				{

// kontrola, zda není cyklické kopírování uvnitø okna
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

// upøesnìní indexu a cíle, je-li hození za konec stromu
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

// nastavení nového kurzoru myši
		if (hCurNew != m_CurAkt)
		{
			m_CurAkt = hCurNew;
			::SetCursor(m_CurAkt);
		}

// zrušení výbìru staré cílové položky pøi zmìnì okna stromu
		if ((OldTree != NULL) && (OldTree != m_TreeDst))
		{
			m_DragList->DragLeave(NULL);
			OldTree->SelectDropTarget(NULL);
			m_DragList->DragEnter(NULL, ptScreen);
		}

// výbìr nové cílové položky
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
// nalezení cílového okna pod kurzorem myši pøi tažení

BOOL CProg::SrcDropWin(CPoint point)
{
// pøednastavení neplatné operace
	m_TreeDst = NULL;
	m_DragDst = -1;

// nalezení okna, nad kterým je taženo
	CWnd* wnd = ChildWindowFromPoint(point - m_HotSpot + m_TestSpot,
					CWP_SKIPINVISIBLE | CWP_SKIPDISABLED);
	if (wnd == NULL) return FALSE;
	HWND hwnd = wnd->m_hWnd;

// test okna veøejných objektù
	if (hwnd == m_Object.m_hWnd)
	{
		m_TreeDst = &m_Object;
		m_DragDst = BufObjID;
		return TRUE;
	}

// test okna lokálních objektù
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

// test okna tøíd
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
// test povolení spojení dvou prvkù

BOOL CProg::TestDropItem(int srcModel, int srcPar, int srcBuff, int dstModel,
						 int dstPar, int dstBuff, int dstItem)
{
	if (dstPar & (PR_LOCK | PR_LOCK_DEP))			// prvek chránìný proti modifikaci
		return FALSE;

	switch (dstBuff)
	{
///////////////////////// cílem okno objektù
	case BufObjID:
		if (srcBuff == BufEdiID) return FALSE;		// z editoru nelze nikdy táhnout

		if (srcBuff == BufLocID) return FALSE;		// z lokálních objektù nelze nikdy táhnout

		if ((srcBuff == BufStrID) && 
			(srcModel != TYP_GROUP) && 
			(srcModel != TYP_LIST)) return FALSE;	// z okna struktur jen skupinu a seznam

		if ((dstModel != TYP_GROUP) &&				// cílem jen skupina nebo ROOT
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

////////////////////////// cílem okno editoru
	case BufEdiID:
// z tøíd nelze nikdy táhnout
		if (srcBuff == BufClsID) return FALSE;

// skupinu objektù nelze táhnout
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

// pøetažení pøíkazu
		if (((srcPar & PR_AS_COMMAND) != 0) &&
			((dstPar & PR_GET_COMMAND) != 0)) return TRUE;

// pøetažení výrazu
		if (((srcPar & PR_AS_EXPRES) != 0) &&
			((dstPar & PR_GET_EXPRES) != 0)) return TRUE;

// pøetažení logického výrazu
		if (((srcPar & PR_AS_BOOL) != 0) &&
			((dstPar & PR_GET_BOOL) != 0)) return TRUE;

// pøetažení vìtve CASE
		if (srcModel == TYP_CASE_ON)
		{
			if (dstModel == TYP_CASE)
				return TRUE;
			else
				return FALSE;
		}

// pøetažení testu vìtve CASE
		if (srcModel == TYP_CASE_TEST)
		{
			if (dstModel == TYP_CASE_ON)
				return TRUE;
			else
				return FALSE;
		}

// pøetažení èíslice do èíselné konstanty
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

// pøetažení textu
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

// pøetažení obrázku
		if (srcModel == TYP_PIC)
		{
			if ((dstModel == TYP_PIC) ||
					(dstModel == TYP_EQU_PIC))
				return TRUE;
			else
				return FALSE;
		}

// pøetažení promìnné
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

////////////////////////// cílem okno lokálních objektù
	case BufLocID:
		if (srcBuff == BufEdiID) return FALSE;		// z editoru nelze nikdy táhnout

		if (srcBuff == BufObjID) return FALSE;		// z objektù nelze nikdy táhnout

		if ((srcBuff == BufStrID) && 
			(srcModel != TYP_GROUP) && 
			(srcModel != TYP_LIST)) return FALSE;	// z okna struktur jen skupinu a seznam

		if ((dstModel != TYP_GROUP) &&				// cílem jen skupina, ROOT nebo parametr
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
// ukonèení tažení uvolnìním tlaèítka myši

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
// test, zda probíhá tažení
	if (m_Dragging)
	{
// ukonèení pøíznaku tažení
		m_Dragging = FALSE;

// pozastavení tažení
		m_DragList->DragLeave(NULL);

// ukonèení tažení
		m_DragList->EndDrag();

// zrušení seznamu obrázkù tažení
		delete m_DragList;
		m_DragList = NULL;

// zrušení výbìru cíle operace u cílového okna
		if (m_TreeDst != NULL)
			m_TreeDst->SelectDropTarget(NULL);

// uvolnìní zachytávání myši
		ReleaseCapture();

// zrušení pøekreslení cílového prvku
		::SetCursor(m_CurArrow /*m_OldCursor*/);



//		if ((m_Buf[m_DragSrc].m_Items[m_itemDragN].counter) &&
//			(m_DragDelete && !m_DragCopy))
//			m_DragDelete = FALSE;



// test, zda není jen pøetažení na místì
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

// pøi pøetažení pøesmìrování referencí
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

// zrušení taženého prvku
				if (m_DragDelete)
					m_Buf[m_DragSrc].Delete(m_itemDragN);

// založení deklarace (je kopie, ne pøesun)
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
// kopie, pøetažení nebo odhození položky
//
// parametry:
//		srcID	- zdrojový buffer
//		src		- zdrojový index
//		dstID	- cílový buffer
//		dst		- cílový index
//		parent	- index rodièe v cílovém bufferu
//		mode	- mód operace (0 = kopie, 1 = pøesun, 2 = zrušení)
//
// vrací nový index cílové položky
//
// pøi pøetažení na místì se nic neprovede
// na pøetaženou položku se zamìøí fokus

short CProg::DragItem(short srcID, short src, short dstID, short dst, short parent, short mode)
{
// lokální promìnné
	short i, b;											// pracovní èítaèe
	short last;											// poslední pøetahovaná zdrojová položka
	CProgBuf* buf;										// adresa bufferu pøi korekci referencí
	PROGITEM* item;										// adresa korigované položky
	PROGITEM pri;										// položka k doplnìní (deklarace)
	short refer;										// referenèní index korigované položky

// kontrola, zda není jen pøetažení položky na místì
	if	(
		 (mode == 1) &&									// je pøesun ?
		 (srcID == dstID) &&							// je operace v jednom oknì ?
		 (src == dst || src == dst-1) &&				// je zdrojová a cílová pozice shodná ?
		 (m_Buf[srcID].m_Items[src].parent == parent)	// je shodný rodiè ?
		)
		return dst;										// pøi pøetažení na místì se nic neprovede

// provedení kopie položky
	if (mode <= 1)										// je kopie nebo pøesun ?
	{
		dst = m_Buf[dstID].Copy(dst, parent, srcID, src, mode == 1);	// kopie položky

// oprava indexu zdrojové položky, 
		if (srcID == dstID)								// je operace v jednom oknì ?
			if (dst <= src)								// je cílová položka pøed zdrojovou ?
				src += m_Buf[dstID].m_Items[dst].items;	// oprava indexu zdrojové položky

// zamìøení fokusu na cílový strom a položku
		if (m_Buf[dstID].m_Tree != NULL)
		{
			m_Buf[dstID].m_Tree->SetFocus();			// zamìøení na strom v oknì
			if ((dst > -1)	&& (dst < m_Buf[dstID].m_Num))	// je cílová položka platná ?
				m_Buf[dstID].m_Tree->Select(m_Buf[dstID].	// zamìøení na položenou položku
					m_Items[dst].htree, TVGN_CARET | TVGN_DROPHILITE);
		}
	}

// pøi pøesunu v jednom oknì pøesmìrování referencí na položky
	if ((mode == 1)	&&	(srcID == dstID))				// je pøesun v jednom oknì ?
	{
		last = src + m_Buf[srcID].m_Items[src].items - 1; // poslední pøetahovaná položka
					
		for (b = 0; b < PROGBUFNUM; b++)				// cyklus pøes všechny buffery
		{
			if (b != srcID)								// pøeskoèení okna s pøetahovanou položkou
			{
				buf = &m_Buf[b];						// adresa bufferu

				for (i = buf->m_Num-1; i >= 0; i--)		// cyklus pøes všechny položky (shora dolù)
				{
					item = &(buf->m_Items[i]);			// adresa testované položky

					if (item->typ == srcID)				// je deklaraèní odkaz na tento buffer ?
					{
						refer = item->refer;			// reference z testované položky

						if ((refer >= src) &&			// ukazuje na pøetahovanou položku ?
							(refer <= last))
						{
							m_Buf[srcID].m_Items[refer].counter--; // snížení èítaèe referencí
							item->refer = refer - src + dst;	// pøesmìrování reference
							m_Buf[dstID].m_Items[item->refer].counter++; // zvýšení èítaèe referencí
						}
					}
				}
			}
		}
	}

// zrušení definice položky
	short data = m_Buf[srcID].m_Items[src].data;
	short index = m_Buf[srcID].m_Items[src].index;

	if ((mode >= 1) && 
		(index != -1) &&
		((data == BufLocID) || (data == BufEdiID)))
	{
		m_Buf[data].Delete(index);
		m_Buf[srcID].m_Items[src].index = -1;
	}

// zrušení taženého prvku pøi módu pøesunu nebo zrušení
	if (mode >= 1) 
	{
		if ((dstID == srcID) && (src < dst))
			dst -= m_Buf[srcID].m_Items[src].items;
		m_Buf[srcID].Delete(src);
	}

// založení deklarace pøi kopii funkce do lokálních nebo globálních objektù
	if ( (mode == 0) &&										// je kopie položky ?
		(m_Buf[dstID].m_Items[dst].model == TYP_FUNC) &&	// je to funkce ?
		((dstID == BufObjID) || (dstID == BufLocID)))		// cílem nìkteré okno objektù ?
	{

// pøi kopii z okna tøíd se musí založit nová deklarace
		if (dstID != srcID)								// je kopírování z jiného okna
		{
// vytvoøení deklarace v editaèním oknì
			pri.param = PR_NOMOVE | PR_EXP | PR_GET_COMMAND; // parametry
			pri.model = TYP_FUNC;						// model - jako funkce
			pri.typ = -1;								// blok s deklarací - nepoužívá se
			pri.refer = -1;								// index deklarace - nepoužívá se
			pri.data = -1;								// není buffer s daty
			pri.index = -1;								// není index s daty
			pri.parent = -1;							// není rodiè
			pri.icon = INTERNALNUM;						// ikona (nepoužívá se)
			pri.name = 0;								// jméno (nepoužívá se)
			refer = m_BufEdi.Insert(&pri);				// vložení položky do editaèního stromu

// inicializace odkazu z funkce na data pro lokální buffer
			if (dstID == BufLocID)						// je cílem okno lokálních objektù ?
			{
				m_Buf[dstID].m_Items[dst].data = BufEdiID;	// identifikátor editaèního bloku
				m_Buf[dstID].m_Items[dst].index = refer;	// index datové položky
			}
			else
			{

// vytvoøení deklarace v oknì lokálních objektù
				pri.data = BufEdiID;					// odkaz na editaèní buffer
				pri.index = refer;						// index 
				pri.parent = m_BufLoc.Insert(&pri);		// vložení položky do lokálních objektù

// vložení záhlaví pro vstupní parametry
				pri.param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL; // parametry
				pri.model = TYP_IPARAM;					// model - vstupní parametry
				pri.typ = BufIntID;						// deklarace je v interních funkcích
				pri.refer = FncPar;						// reference na vstupní parametry
				pri.data = -1;							// nejsou data
				pri.index = -1;
				pri.icon = -1;							// ikona (implicitní)
				pri.name = -1;							// jméno (implicitní)
				m_BufLoc.Insert(&pri);					// vložení položky do bufferu

// vložení záhlaví pro výstupní parametr
				pri.param = PR_NOMOVE | PR_EXP | PR_GET_EXPRES | PR_GET_BOOL | PR_ONE; // parametry
				pri.model = TYP_OPARAM;					// model - výstupni parametr
				pri.refer = FncOut;						// reference na výstupní parametr
				m_BufLoc.Insert(&pri);					// vložení položky do bufferu

// inicializace odkazu z funkce na data pro globální buffer
				m_Buf[dstID].m_Items[dst].data = BufLocID;	// identifikátor lokálního bloku
				m_Buf[dstID].m_Items[dst].index = pri.parent; // index datové položky
			}
		}

	}

// pøepnutí na vloženou položku funkce (je to potøebné i pøi kopírování v jednom oknì !)
		if (dstID == BufLocID)						// je cílem okno lokálních objektù ?
			DblclkLocal(dst);						// aktualizace lokálních objektù

		if (dstID == BufObjID)						// je cílem okno globálních objektù ?
			DblclkObject(dst);						// aktualizace globálních objektù

// navrácení indexu cílové položky
	return dst;						// nový index cílové položky
}


