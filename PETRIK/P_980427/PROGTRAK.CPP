
/////////////////////////////////////////////////////////////////////////////
//																		   //
//					obsluha tažení rozdìlovaèù oken						   //
//																		   //
/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
// zobrazení kurzoru myši, není-li tažení ikon

BOOL CProg::OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message) 
{
	if (!m_Dragging)						// jen není-li tažení ikon
	{
// pøíprava kurzoru myši, je-li tažení pøedìlù
		if (m_Tracking)						// je tažení pøedìlù ?
		{
			if (m_HTracking)				// je tažení horizontálního pøedìlu ?
				m_CurAkt = m_CurVSize;		// vertikální kurzor myši
			else
				m_CurAkt = m_CurHSize;		// horizontální kurzor myši
		}
		else

// pøíprava kurzoru myši, není-li žádné tažení
		{
			m_CurAkt = m_CurArrow;			// implicitní kurzor šipky

			POINT pt;
			::GetCursorPos(&pt);			// naètení kurzoru myši

			if (WndHitTest(m_Split1, pt) ||	// je levý vertikální pøedìl ?
				WndHitTest(m_Split3, pt))	// je pravý vertikální pøedìl ?
				m_CurAkt = m_CurHSize;		// horizontální kurzor myši
			else
				if (WndHitTest(m_Split2, pt) ||	// je levý horizontální pøedìl ?
					WndHitTest(m_Split4, pt))	// je pravý horizontální pøedìl ?
					m_CurAkt = m_CurVSize;		// vertikální kurzor myši
		}

// zobrazení nového kurzoru myši
		::SetCursor(m_CurAkt);				// zobrazení kurzoru myši
		return TRUE;						// pøíznak, že se nemá pokraèovat
	}

// pokraèování implicitní obsluhou
	return CFormView::OnSetCursor(pWnd, nHitTest, message);
}


/////////////////////////////////////////////////////////////////////////////
// test kurzoru myši, zda je nad pøedìlem

BOOL CProg::WndHitTest(CWnd& wnd, POINT& pt)
{
	CRect rc;
	wnd.GetWindowRect(&rc);					// naètení pozice a rozmìrù okna
	return rc.PtInRect(pt);					// test, zda je kurzor myši nad oknem
}


/////////////////////////////////////////////////////////////////////////////
// stisk levého tlaèítka myši - zahájení tažení pøedìlu

void CProg::OnLButtonDown(UINT nFlags, CPoint point) 
{
	if (!m_Tracking && !m_Dragging)			// jen není-li žádné tažení
	{
		POINT pt;
		::GetCursorPos(&pt);				// naètení pozice kurzoru myši

		if (BegTrack(m_Split1, pt, FALSE)	||	// levý vertikální pøedìl
			BegTrack(m_Split2, pt, TRUE)	||	// pravý vertikální pøedìl
			BegTrack(m_Split3, pt, FALSE)	||	// levý horizontální pøedìl
			BegTrack(m_Split4, pt, TRUE))		// pravý horizontální pøedìl
			return;
	}
	CFormView::OnLButtonDown(nFlags, point);
}


/////////////////////////////////////////////////////////////////////////////
// zahájení tažení jednoho pøedìlu

BOOL CProg::BegTrack(CStatic& wnd, POINT& pt, BOOL HTrack)
{
// naètení rozmìrù testovaného pøedìlu
	wnd.GetWindowRect(&m_TrackRect);

// test, zda je kurzor myši nad pøedìlem
	if (!m_TrackRect.PtInRect(pt))
		return FALSE;				// kurzor myši není na pøedìlu

// zahájení tažení - nastavení promìnných
	m_Tracking = TRUE;			// pøíznak probíhajícího tažení
	m_HTracking = HTrack;		// pøíznak horizontálního pøedìlu
	m_TrackSplit = &wnd;		// okno taženého pøedìlu
	m_TrackDisp = FALSE;		// není zobrazen pøedìl tažení

// úschova offsetu kurzoru myši od okraje pøedìlu
	if (HTrack)					// je horizontální pøedìl ?
		m_TrackSpot = pt.y - m_TrackRect.top; // vertikální offset kurzoru
	else
		m_TrackSpot = pt.x - m_TrackRect.left; // horizontální offset kurzoru

// inicializace tažení
	ScreenToClient(&m_TrackRect); // pøevod na klientské souøadnice
	SetCapture();				// zahájení zachytávání myši
	InvertTrack();				// zobrazení taženého obdélníku
	m_ReDispCount = 0;			// není požadováno pøekreslení
	m_TrackTimer = SetTimer(20,20,NULL); // vytvoøení èasovaèe
	return TRUE;				// pøíznak zahájení tažení
}

/////////////////////////////////////////////////////////////////////////////
// ukonèení tažení pøedìlu (uvolnìní levého tlaèítka myši)

void CProg::EndTrack()
{
// test, zda probíhá tažení pøedìlu
	if (m_Tracking)
	{

// vypnutí zobrazení pøedìlu
		if (m_TrackDisp) InvertTrack(); // vypnutí obdélníku tažení

// ukonèení tažení
		ReleaseCapture();			// ukonèení zachytávání myši
		m_Tracking = FALSE;			// zrušení pøíznaku tažení
		KillTimer(m_TrackTimer);	// zrušení èasovaèe
		m_ReDispCount = 0;			// není požadováno pøekreslení

// pøekreslení oken pøi ukonèení tažení
		ReSize();					// pøepoèet oken

// aktualizace zobrazení lišty pøepínaèù
		CRect rect;
		m_Edit.GetWindowRect(&rect); // naètení pozice editáèního okna
		ScreenToClient(&rect);		// pøepoèet na klientské souøadnice
		rect.bottom = rect.top;		// spodní okraj
		rect.top = 0;				// horní okraj
		RedrawWindow(&rect);		// pøekreslení lišty pøepínaèü

// aktualizace zobrazení okna
		Invalidate(FALSE);			// obsah okna neplatný
		UpdateWindow();				// zobrazení okna
	}
}


/////////////////////////////////////////////////////////////////////////////
// zapnutí/vypnutí obdélníku pøedìlu

void CProg::InvertTrack()
{
	CDC* pDC = GetDC();			// otevøení DC
	HBRUSH hOldBrush = NULL;	// pùvodní štìtec
	CBrush* pBrush = CDC::GetHalftoneBrush(); // prokládaný štìtec
	if (pBrush != NULL)			// je štìtec platný ?
		hOldBrush = (HBRUSH)SelectObject(pDC->m_hDC, pBrush->m_hObject);
	pDC->PatBlt(m_TrackRect.left, m_TrackRect.top, // zobrazení obdélníku
		m_TrackRect.Width(), m_TrackRect.Height(), PATINVERT);
	m_TrackDisp = !m_TrackDisp;	// zmìna pøíznaku zobrazení obdélníku
	if (hOldBrush != NULL)
		SelectObject(pDC->m_hDC, hOldBrush); // návrat pùvodního štìtce
	ReleaseDC(pDC);				// uvolnìní DC
}


/////////////////////////////////////////////////////////////////////////////
// posun myší - tažení pøedìlu

void CProg::MoveTrack(CPoint pt)
{
// jen je-li tažení pøedìlu
	if (m_Tracking)				// je tažení pøedìlu ?
	{

// naètení rozmìrù hlavního okna
		CRect rcw;				// klientské rozmìry okna
		GetClientRect(&rcw);	// naètení rozmìrù okna
		CRect rc = m_TrackRect;	// pùvodní pozice obdélníku

// test, zda je tažení horizontálního pøedìlu
		if (m_HTracking)
		{

// nové okraje horizontálního pøedìlu
			rc.top = pt.y - m_TrackSpot;	// horní okraj pøedìlu
			if (rc.top < 0) rc.top = 0;		// omezení pøi podteèení
			if (rc.top > rcw.bottom - SplitSize) // omezení pøi pøeteèení
				rc.top = rcw.bottom - SplitSize;
			rc.bottom = rc.top + SplitSize;	// spodní okraj pøedìlu

// nová relativní pozice horizontálního pøedìlu
			if (m_TrackSplit == &m_Split2)	// je levý pøedìl ?
				LeftHeight = (rc.top*Scale + rcw.bottom/2)/rcw.bottom;
			else
				RightHeight = (rc.top*Scale + rcw.bottom/2)/rcw.bottom;
		}
		else
		{

// nové okraje vertikálního pøedìlu
			rc.left = pt.x - m_TrackSpot;	// levý okraj pøedìlu
			if (rc.left < 0) rc.left = 0;	// omezení pøi podteèení
			if (rc.left > rcw.right - SplitSize) // omezení pøi pøeteèení
				rc.left = rcw.right - SplitSize;

// nová relativní pozice vertikálního pøedìlu
			if (m_TrackSplit == &m_Split1)	// je levý pøedìl ?
			{
				LeftWidth = (rc.left*Scale + rcw.right/2)/rcw.right;
				if (rc.left > rcw.right - 2*SplitSize) // omezení levého pøedìlu
					rc.left = rcw.right - 2*SplitSize;
			}
			else
				RightWidth = Scale - (rc.left*Scale + rcw.right/2)/rcw.right;

			rc.right = rc.left + SplitSize;	// pravý okraj pøedìlu
		}

// aktualizace zobrazení pøedìlu
		if (rc != m_TrackRect)				// zmìnila se pozice pøedìlu ?
		{
			InvertTrack();					// vypnutí pøedìlu
			m_TrackRect = rc;				// nová pozice
			m_ReDispCount = 2;				// požadavek pøekreslení okna
			InvertTrack();					// zapnutí pøedìlu
		}
	}
}


/////////////////////////////////////////////////////////////////////////////
// obsluha èasovaèe pro pøekreslení okna pøi tažení pøedìlu

void CProg::OnTimer(UINT nIDEvent) 
{
// èítaè pro obsluhu zobrazení
	if (m_ReDispCount)						// je požadováno zobrazení ?
	{
		m_ReDispCount--;					// snížení èítaèe èekání na zobrazení

// test, zda je již dosaženo èasu k zobrazení pøedìlu
		if (!m_ReDispCount)					// uplynula doba k zobrazení ?
		{			

// vypnutí pøípadnì zobrazeného pøedìlu
			BOOL OldTrackDisp = m_TrackDisp;// úschova pøíznaku zobrazení pøedìlu
			if (m_TrackDisp) InvertTrack();	// vypnutí pøedìlu

// pøepoèet nového rozložení okna
			ValidateRect(NULL);				// zatím okno nezobrazovat
			ReSize();						// pøepoèet rozložení okna

// aktualizace zobrazení lišty s tlaèítky
			CRect rect;
			m_Edit.GetWindowRect(&rect);	// naètení pozice editaèního okna
			ScreenToClient(&rect);			// pøepoèet na klientské souøadnice
			rect.bottom = rect.top;			// spodní okraj lišty s tlaèítky
			rect.top = 0;					// horní okraj lišty s tlaèítky
			RedrawWindow(&rect);			// pøekreslení lišty s tlaèítky

// aktualizace zobrazení okna (bez pøekreslení pozadí)
			Invalidate(FALSE);				// zneplatnìní celého okna
			UpdateWindow();					// aktualizace zobrazení okna

// pøípadné zapnutí zobrazení pøedìlu
			if (OldTrackDisp) InvertTrack(); // zobrazení pøedìlu
		}
	}
	CFormView::OnTimer(nIDEvent);			// pokraèování pùvodní obsluhou èasovaèe
}

