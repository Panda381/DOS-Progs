
/////////////////////////////////////////////////////////////////////////////
//																		   //
//					obsluha ta�en� rozd�lova�� oken						   //
//																		   //
/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
// zobrazen� kurzoru my�i, nen�-li ta�en� ikon

BOOL CProg::OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message) 
{
	if (!m_Dragging)						// jen nen�-li ta�en� ikon
	{
// p��prava kurzoru my�i, je-li ta�en� p�ed�l�
		if (m_Tracking)						// je ta�en� p�ed�l� ?
		{
			if (m_HTracking)				// je ta�en� horizont�ln�ho p�ed�lu ?
				m_CurAkt = m_CurVSize;		// vertik�ln� kurzor my�i
			else
				m_CurAkt = m_CurHSize;		// horizont�ln� kurzor my�i
		}
		else

// p��prava kurzoru my�i, nen�-li ��dn� ta�en�
		{
			m_CurAkt = m_CurArrow;			// implicitn� kurzor �ipky

			POINT pt;
			::GetCursorPos(&pt);			// na�ten� kurzoru my�i

			if (WndHitTest(m_Split1, pt) ||	// je lev� vertik�ln� p�ed�l ?
				WndHitTest(m_Split3, pt))	// je prav� vertik�ln� p�ed�l ?
				m_CurAkt = m_CurHSize;		// horizont�ln� kurzor my�i
			else
				if (WndHitTest(m_Split2, pt) ||	// je lev� horizont�ln� p�ed�l ?
					WndHitTest(m_Split4, pt))	// je prav� horizont�ln� p�ed�l ?
					m_CurAkt = m_CurVSize;		// vertik�ln� kurzor my�i
		}

// zobrazen� nov�ho kurzoru my�i
		::SetCursor(m_CurAkt);				// zobrazen� kurzoru my�i
		return TRUE;						// p��znak, �e se nem� pokra�ovat
	}

// pokra�ov�n� implicitn� obsluhou
	return CFormView::OnSetCursor(pWnd, nHitTest, message);
}


/////////////////////////////////////////////////////////////////////////////
// test kurzoru my�i, zda je nad p�ed�lem

BOOL CProg::WndHitTest(CWnd& wnd, POINT& pt)
{
	CRect rc;
	wnd.GetWindowRect(&rc);					// na�ten� pozice a rozm�r� okna
	return rc.PtInRect(pt);					// test, zda je kurzor my�i nad oknem
}


/////////////////////////////////////////////////////////////////////////////
// stisk lev�ho tla��tka my�i - zah�jen� ta�en� p�ed�lu

void CProg::OnLButtonDown(UINT nFlags, CPoint point) 
{
	if (!m_Tracking && !m_Dragging)			// jen nen�-li ��dn� ta�en�
	{
		POINT pt;
		::GetCursorPos(&pt);				// na�ten� pozice kurzoru my�i

		if (BegTrack(m_Split1, pt, FALSE)	||	// lev� vertik�ln� p�ed�l
			BegTrack(m_Split2, pt, TRUE)	||	// prav� vertik�ln� p�ed�l
			BegTrack(m_Split3, pt, FALSE)	||	// lev� horizont�ln� p�ed�l
			BegTrack(m_Split4, pt, TRUE))		// prav� horizont�ln� p�ed�l
			return;
	}
	CFormView::OnLButtonDown(nFlags, point);
}


/////////////////////////////////////////////////////////////////////////////
// zah�jen� ta�en� jednoho p�ed�lu

BOOL CProg::BegTrack(CStatic& wnd, POINT& pt, BOOL HTrack)
{
// na�ten� rozm�r� testovan�ho p�ed�lu
	wnd.GetWindowRect(&m_TrackRect);

// test, zda je kurzor my�i nad p�ed�lem
	if (!m_TrackRect.PtInRect(pt))
		return FALSE;				// kurzor my�i nen� na p�ed�lu

// zah�jen� ta�en� - nastaven� prom�nn�ch
	m_Tracking = TRUE;			// p��znak prob�haj�c�ho ta�en�
	m_HTracking = HTrack;		// p��znak horizont�ln�ho p�ed�lu
	m_TrackSplit = &wnd;		// okno ta�en�ho p�ed�lu
	m_TrackDisp = FALSE;		// nen� zobrazen p�ed�l ta�en�

// �schova offsetu kurzoru my�i od okraje p�ed�lu
	if (HTrack)					// je horizont�ln� p�ed�l ?
		m_TrackSpot = pt.y - m_TrackRect.top; // vertik�ln� offset kurzoru
	else
		m_TrackSpot = pt.x - m_TrackRect.left; // horizont�ln� offset kurzoru

// inicializace ta�en�
	ScreenToClient(&m_TrackRect); // p�evod na klientsk� sou�adnice
	SetCapture();				// zah�jen� zachyt�v�n� my�i
	InvertTrack();				// zobrazen� ta�en�ho obd�ln�ku
	m_ReDispCount = 0;			// nen� po�adov�no p�ekreslen�
	m_TrackTimer = SetTimer(20,20,NULL); // vytvo�en� �asova�e
	return TRUE;				// p��znak zah�jen� ta�en�
}

/////////////////////////////////////////////////////////////////////////////
// ukon�en� ta�en� p�ed�lu (uvoln�n� lev�ho tla��tka my�i)

void CProg::EndTrack()
{
// test, zda prob�h� ta�en� p�ed�lu
	if (m_Tracking)
	{

// vypnut� zobrazen� p�ed�lu
		if (m_TrackDisp) InvertTrack(); // vypnut� obd�ln�ku ta�en�

// ukon�en� ta�en�
		ReleaseCapture();			// ukon�en� zachyt�v�n� my�i
		m_Tracking = FALSE;			// zru�en� p��znaku ta�en�
		KillTimer(m_TrackTimer);	// zru�en� �asova�e
		m_ReDispCount = 0;			// nen� po�adov�no p�ekreslen�

// p�ekreslen� oken p�i ukon�en� ta�en�
		ReSize();					// p�epo�et oken

// aktualizace zobrazen� li�ty p�ep�na��
		CRect rect;
		m_Edit.GetWindowRect(&rect); // na�ten� pozice edit��n�ho okna
		ScreenToClient(&rect);		// p�epo�et na klientsk� sou�adnice
		rect.bottom = rect.top;		// spodn� okraj
		rect.top = 0;				// horn� okraj
		RedrawWindow(&rect);		// p�ekreslen� li�ty p�ep�na��

// aktualizace zobrazen� okna
		Invalidate(FALSE);			// obsah okna neplatn�
		UpdateWindow();				// zobrazen� okna
	}
}


/////////////////////////////////////////////////////////////////////////////
// zapnut�/vypnut� obd�ln�ku p�ed�lu

void CProg::InvertTrack()
{
	CDC* pDC = GetDC();			// otev�en� DC
	HBRUSH hOldBrush = NULL;	// p�vodn� �t�tec
	CBrush* pBrush = CDC::GetHalftoneBrush(); // prokl�dan� �t�tec
	if (pBrush != NULL)			// je �t�tec platn� ?
		hOldBrush = (HBRUSH)SelectObject(pDC->m_hDC, pBrush->m_hObject);
	pDC->PatBlt(m_TrackRect.left, m_TrackRect.top, // zobrazen� obd�ln�ku
		m_TrackRect.Width(), m_TrackRect.Height(), PATINVERT);
	m_TrackDisp = !m_TrackDisp;	// zm�na p��znaku zobrazen� obd�ln�ku
	if (hOldBrush != NULL)
		SelectObject(pDC->m_hDC, hOldBrush); // n�vrat p�vodn�ho �t�tce
	ReleaseDC(pDC);				// uvoln�n� DC
}


/////////////////////////////////////////////////////////////////////////////
// posun my�� - ta�en� p�ed�lu

void CProg::MoveTrack(CPoint pt)
{
// jen je-li ta�en� p�ed�lu
	if (m_Tracking)				// je ta�en� p�ed�lu ?
	{

// na�ten� rozm�r� hlavn�ho okna
		CRect rcw;				// klientsk� rozm�ry okna
		GetClientRect(&rcw);	// na�ten� rozm�r� okna
		CRect rc = m_TrackRect;	// p�vodn� pozice obd�ln�ku

// test, zda je ta�en� horizont�ln�ho p�ed�lu
		if (m_HTracking)
		{

// nov� okraje horizont�ln�ho p�ed�lu
			rc.top = pt.y - m_TrackSpot;	// horn� okraj p�ed�lu
			if (rc.top < 0) rc.top = 0;		// omezen� p�i podte�en�
			if (rc.top > rcw.bottom - SplitSize) // omezen� p�i p�ete�en�
				rc.top = rcw.bottom - SplitSize;
			rc.bottom = rc.top + SplitSize;	// spodn� okraj p�ed�lu

// nov� relativn� pozice horizont�ln�ho p�ed�lu
			if (m_TrackSplit == &m_Split2)	// je lev� p�ed�l ?
				LeftHeight = (rc.top*Scale + rcw.bottom/2)/rcw.bottom;
			else
				RightHeight = (rc.top*Scale + rcw.bottom/2)/rcw.bottom;
		}
		else
		{

// nov� okraje vertik�ln�ho p�ed�lu
			rc.left = pt.x - m_TrackSpot;	// lev� okraj p�ed�lu
			if (rc.left < 0) rc.left = 0;	// omezen� p�i podte�en�
			if (rc.left > rcw.right - SplitSize) // omezen� p�i p�ete�en�
				rc.left = rcw.right - SplitSize;

// nov� relativn� pozice vertik�ln�ho p�ed�lu
			if (m_TrackSplit == &m_Split1)	// je lev� p�ed�l ?
			{
				LeftWidth = (rc.left*Scale + rcw.right/2)/rcw.right;
				if (rc.left > rcw.right - 2*SplitSize) // omezen� lev�ho p�ed�lu
					rc.left = rcw.right - 2*SplitSize;
			}
			else
				RightWidth = Scale - (rc.left*Scale + rcw.right/2)/rcw.right;

			rc.right = rc.left + SplitSize;	// prav� okraj p�ed�lu
		}

// aktualizace zobrazen� p�ed�lu
		if (rc != m_TrackRect)				// zm�nila se pozice p�ed�lu ?
		{
			InvertTrack();					// vypnut� p�ed�lu
			m_TrackRect = rc;				// nov� pozice
			m_ReDispCount = 2;				// po�adavek p�ekreslen� okna
			InvertTrack();					// zapnut� p�ed�lu
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// obsluha �asova�e pro p�ekreslen� okna p�i ta�en� p�ed�lu

void CProg::OnTimer(UINT nIDEvent) 
{
// ��ta� pro obsluhu zobrazen�
	if (m_ReDispCount)						// je po�adov�no zobrazen� ?
	{
		m_ReDispCount--;					// sn�en� ��ta�e �ek�n� na zobrazen�

// test, zda je ji� dosa�eno �asu k zobrazen� p�ed�lu
		if (!m_ReDispCount)					// uplynula doba k zobrazen� ?
		{			

// vypnut� p��padn� zobrazen�ho p�ed�lu
			BOOL OldTrackDisp = m_TrackDisp;// �schova p��znaku zobrazen� p�ed�lu
			if (m_TrackDisp) InvertTrack();	// vypnut� p�ed�lu

// p�epo�et nov�ho rozlo�en� okna
			ValidateRect(NULL);				// zat�m okno nezobrazovat
			ReSize();						// p�epo�et rozlo�en� okna

// aktualizace zobrazen� li�ty s tla��tky
			CRect rect;
			m_Edit.GetWindowRect(&rect);	// na�ten� pozice edita�n�ho okna
			ScreenToClient(&rect);			// p�epo�et na klientsk� sou�adnice
			rect.bottom = rect.top;			// spodn� okraj li�ty s tla��tky
			rect.top = 0;					// horn� okraj li�ty s tla��tky
			RedrawWindow(&rect);			// p�ekreslen� li�ty s tla��tky

// aktualizace zobrazen� okna (bez p�ekreslen� pozad�)
			Invalidate(FALSE);				// zneplatn�n� cel�ho okna
			UpdateWindow();					// aktualizace zobrazen� okna

// p��padn� zapnut� zobrazen� p�ed�lu
			if (OldTrackDisp) InvertTrack(); // zobrazen� p�ed�lu
		}
	}
	CFormView::OnTimer(nIDEvent);			// pokra�ov�n� p�vodn� obsluhou �asova�e
}

