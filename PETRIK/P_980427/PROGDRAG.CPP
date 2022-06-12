
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
	if (m_itemDragPar & PR_INTERNAL)
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


	m_ProgMap.m_X = -1;
	m_ProgMap.m_Y = -1;

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

// tažení do okna editoru mapy
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
				if (m_DragRight || (m_DragDst != m_DragSrc) ||
					((m_DragDst == BufClsID) && (m_DragSrc == BufClsID)))
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
							m_itemDropModel, m_itemDropPar, m_DragDst, m_itemDragN, m_itemDropN))
						{

// jinak zmìna na vedlejší cílový prvek
							m_itemDropN = AlterDstN;

// naètení parametrù vedlejšího cílového prvku (nemùže být = -1)
							m_itemDrop = m_Buf[m_DragDst].m_Items[m_itemDropN].htree;
							m_itemDropPar = m_Buf[m_DragDst].m_Items[m_itemDropN].param;
							m_itemDropModel = m_Buf[m_DragDst].m_Items[m_itemDropN].model;

// est vedlejšího cílového prvku
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

// test, zda je operace platná
				if (m_DropIndex != -1)
				{

// kontrola, zda není cyklické kopírování uvnitø okna
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
// test povolení spojení dvou prvkù

BOOL CProg::TestDropItem(int srcModel, int srcPar, int srcBuff, int dstModel,
						 int dstPar, int dstBuff, int srcItem, int dstItem)
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

// pøetažení funkce
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
// zablokovat vytvoøení skupiny v parametrech funkce èi objektu!

	case BufLocID:
		if (srcBuff == BufEdiID) return FALSE;		// z editoru nelze nikdy táhnout

		if (srcBuff == BufObjID) return FALSE;		// z objektù nelze nikdy táhnout

		if ((srcBuff == BufStrID) && 
			(srcModel != TYP_GROUP) && 
			(srcModel != TYP_LIST)) return FALSE;	// z okna struktur jen skupinu a seznam

		if ((dstModel != TYP_GROUP) &&				// cílem jen skupina, ROOT nebo parametr
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

////////////////////////// cílem okno tøíd - nelze táhnout
//	case BufClsID:
//		if ((srcBuff == BufStrID) && (srcModel == TYP_GROUP)) // kopie skupiny ze struktur
//			return TRUE;

//		if (srcBuff != BufClsID)
//			return FALSE;							// z jiných oken nelze táhnout

//		if ((srcModel == TYP_FUNC) || (srcModel == TYP_EVENT))
//		if ((srcModel != TYP_CLASS) || (dstModel != TYP_CLASS))
//			return FALSE;							// funkci ani událost nelze dìdit

//		if (srcModel != dstModel)					// musí být stejný model
//			return FALSE;

//		if (m_Buf[srcBuff].m_Items[srcItem].parent == // stejný rodiè je OK
//			dstItem)
//			return TRUE;

//		if (srcItem == dstItem)						// bude vlastní potomek
//			return TRUE;

//		return FALSE;
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
// provedení kopie, pøesunu nebo zrušení položky
	switch (mode)
	{
	case 0:											// kopie
		dst = m_Buf[dstID].Copy(dst, parent, srcID, src);
		if ((srcID == dstID) &&	(dst < src))		// je cílová položka pøed zdrojovou ?
			src += m_Buf[dstID].m_Items[dst].items;	// oprava indexu zdrojové položky
		break;

	case 1:											// pøesun
		dst = m_Buf[dstID].MoveTre(dst, parent, src);
		break;

	case 2:
		m_Buf[srcID].DeleteTre(src);				// zrušení položky
		break;
	}

// zajištìní viditelnosti
	if ((mode <= 1) && (m_Buf[dstID].m_Tree != NULL))
		m_Buf[dstID].m_Tree->EnsureVisible(m_Buf[dstID].m_Items[dst].htree);

// pøepnutí na vloženou položku funkce (je to potøebné i pøi kopírování v jednom oknì !)
	if ((mode == 0) &&
		(m_Buf[dstID].m_Items[dst].model == TYP_FUNC))
	{

		if (dstID == BufLocID)						// je cílem okno lokálních objektù ?
			DblclkLocal(dst);						// aktualizace lokálních objektù

		if (dstID == BufObjID)						// je cílem okno globálních objektù ?
			DblclkObject(dst);						// aktualizace globálních objektù
	}

	m_BufLoc.SetFirst(m_BufLoc.m_First-1);
	m_BufEdi.SetFirst(m_BufEdi.m_First-1);

	AktAllDef();								// aktualizace definièních ukazatelù

// navrácení indexu cílové položky
	return dst;						// nový index cílové položky
}


