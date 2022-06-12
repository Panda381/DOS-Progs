
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Render                                   //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

#define FILENAMECHAR TCHAR('#')

// current render or preview values (thread specific)
__declspec (thread) real CurRenderX, CurRenderY;	// current render X and Y coordinates (range 0..1)
__declspec (thread) real CurRenderDX, CurRenderDY;	// current render X and Y deltas (range 0..1)

volatile BOOL RenderMode = FALSE;

// render parameters
int RenderWidth = 512;			// render width
int RenderHeight = 512;			// render height
BOOL RenderAnti = TRUE;			// render antialiasing
BOOL RenderCont = TRUE;			// continue rendering
CText RenderFile(_T("Texture.tga")); // render file (FILENAMECHAR = frame number)
BOOL RenderTrans = FALSE;		// render transparency
int RenderPriority = CPUPRIOR_IDLE; // CPU render priority
int RenderThreads = 0;			// number of threads (0=default)
CFilterOut* RenderFilter;		// render filter
int RenderEstTime = 0;			// render estimate time in seconds
int RenderFrames = 0;			// render number of frames (0=no video)
int RenderFrame = 0;			// render current frame
int RenderLast = 0;				// render last frame
BOOL RenderJPG = FALSE;			// save to JPG
int RenderQuality = 100;		// JPG quality

int RenderCPUNum = 1;			// number of processors

BOOL RenderQueueOn = FALSE;		// queue list is enabled
BOOL RenderAuto = TRUE;			// auto name

int RendTransByte = 3;			// number of bytes per pixel
int RenderThreadsNew;			// new number of threads
int RenderUpdateProg = 1;		// update progress counter

// queue
SRendQueue RendQueue[RENDQUEUEMAX]; // render queue
int RendQueueNum = 0;			// length of render queue
int RendQueueSel = -1;			// selected render queue entry

// dialog controls
CWindow RenderDialog;			// render dialog window
CButton RenderStartButton;		// render start button
CCheckBox RenderQueueOnCheck;	// render queue on check
CListBox RenderQueueList;		// render queue list
CButton RenderClearBtn;			// render queue clear
CEdit RenderWidthEdit;			// render width edit
CEdit RenderHeightEdit;			// render height edit
CDropList RenderPresetsList;	// render presets list box
CCheckBox RenderAntiCheck;		// render antialiasing check box
CCheckBox RenderContCheck;		// render continue check box
CDropList RenderFilterList;		// render filters list box
CEdit RenderFramesEdit;			// render frames edit
CEdit RenderFrameEdit;			// render frame edit
CEdit RenderLastEdit;			// render last frame edit
CEdit RenderFileEdit;			// render file edit
CButton RenderBrowseBtn;		// render browse button
CCheckBox RenderTransCheck;		// render transparency check box
CCheckBox RenderAutoCheck;		// render auto name check box
CButton RenderQLoadBtn;			// render queue load button
CButton RenderQStartBtn;		// render queue start button
CButton RenderQUpBtn;			// render queue up button
CButton RenderQDownBtn;			// render queue down button
CButton RenderQClearBtn;		// render queue clear button
CLabel RenderEstTimeLab;		// label of estimate time
CLabel RenderEstTimeLab2;		// label of estimate time total
CCheckBox RenderJPGCheck;		// render to JPG check box
CSlider RenderJPGSlider;		// render JPG quality slider
CEdit RenderJPGEdit;			// render JPG quality edit

// progress controls
CWindow ProgDialog;				// render progress dialog
CProgress RenderProg;			// render progress bar
CLabel RenderElapTxt;			// elapsed time label
CLabel RenderRemTxt;			// remaining time label
CLabel RenderInQueueTxt;		// in queue label
CLabel RenderTotalTxt;			// remaining total label
CCheckBox RenderPauseCheck;		// render pause check box
CDropList RenderPriorList;		// render priority list box
CDropList RenderThreadsList;	// render threads list box
CLabel RenderFileTxt;			// rendered file label

// render priority constants (on change update CPUPRIOR)
const int RenderPriorityTab[] = {
	THREAD_PRIORITY_IDLE,
	-4,
	-3,
	THREAD_PRIORITY_LOWEST,
	THREAD_PRIORITY_BELOW_NORMAL,
	THREAD_PRIORITY_NORMAL,
};

// timer
#define RENDTIMERID		5786
#define RENDTIMER		30		// timer in [ms]

#define RENDTIMERID2	5787
#define RENDTIMER2		100		// timer in [ms]

// render buffer
int RendTotal;					// render total pixels
int RendInx0;					// render start index (to compute elapsed time after continue)
int RendInx;					// render current index shifted with save (number of saved pixels)
int RendInxProg;				// render current index as progress indicator (number of rendered pixels)
int RendDiv;					// progress divider
volatile u8 RenderPause;		// render pause
FILE* RenderF;					// render file
BOOL RenderSaveErr;				// save error flag
int RenderTimeElapsed;			// elapsed time in [ms]
BOOL RendAllOK = FALSE;			// all buffers rendered OK

// presets
#define RENDPRES_N	20
const int RendPresX[RENDPRES_N] = { 64, 160, 128, 160, 320, 256, 320, 640, 512, 640, 1024, 1280, 1920, 2048, 3840, 4096, 6000, 8192, 10000, 16384 };
const int RendPresY[RENDPRES_N] = { 64,  90, 128, 120, 180, 256, 240, 360, 512, 480, 1024,  720, 1080, 2048, 2160, 4096, 6000, 8192, 10000, 16384 };

// render objects
int RendObjNum = 0;
CRender RendObj[RENDMAX];

///////////////////////////////////////////////////////////////////////////////
// render thread

#define RDIST (real)0.35 //(real)0.35
#define RWGHT (real)0.2 //(real)0.2

DWORD WINAPI RenderThread(void* lParam)
{
	CRender* r = (CRender*)lParam;
	CFilterOut* f;

	CColor col, col2;
	real xx, yy;
	real dx = (real)RDIST/RenderWidth;
	real dy = (real)RDIST/RenderHeight;
	int n, x, y;
	CurRenderDX = (real)1/RenderWidth;
	CurRenderDY = (real)1/RenderHeight;

	// request to stop render thread
	while (!r->m_StopReq)
	{
		// request to render next pixel
		if (!r->m_OK && !RenderPause)
		{
			// there is data to render
			if (r->m_Num < r->m_Max)
			{
				x = r->m_X;
				y = r->m_Y;
				xx = (x + (real)0.5)/RenderWidth;
				yy = (y + (real)0.5)/RenderHeight;
				f = r->m_OutFilter;

				// use antialiasing
				CurRenderX = xx;
				CurRenderY = yy;
				if (RenderAnti)
				{
					f->RenderCol(&col, xx, yy);
					col.MulA((real)(1/RWGHT-4));
					CurRenderX = xx - dx;
					CurRenderY = yy - dy;
					f->RenderCol(&col2, xx - dx, yy - dy);
					col.AddA(col2);
					CurRenderX = xx + dx;
					f->RenderCol(&col2, xx + dx, yy - dy);
					col.AddA(col2);
					CurRenderY = yy + dy;
					f->RenderCol(&col2, xx + dx, yy + dy);
					col.AddA(col2);
					CurRenderX = xx - dx;
					f->RenderCol(&col2, xx - dx, yy + dy);
					col.AddA(col2);
					col.MulA((real)RWGHT);
				}

				// not using antialiasing
				else
					f->RenderCol(&col, xx, yy);

				// write color
				n = r->m_Num;
				r->m_Data[n++] = col.GetB();
				r->m_Data[n++] = col.GetG();
				r->m_Data[n++] = col.GetR();
				if (RenderTrans) r->m_Data[n++] = col.GetA();
				r->m_Num = n;

				// increase coordinates
				x++;
				r->m_X = x;
				if (x >= RenderWidth)
				{
					r->m_X = 0;
					y++;
					r->m_Y = y;
					if (y >= RenderHeight)
					{
						r->m_OK = TRUE;
						r->m_StopReq = TRUE;
					}
				}

				// sleep
				r->m_Sleep--;
				if (r->m_Sleep <= 0)
				{
					r->m_Sleep = RENDSLEEPN;
					::Sleep(0);
				}
			}
			else
				r->m_OK = TRUE;
		}
		else
			// waiting to save render buffer
			::Sleep(15);
	}
	return 1;
}

///////////////////////////////////////////////////////////////////////////////
// start render object (returns FALSE on error)

BOOL CRender::Start()
{
	// buffer is rendered OK
	m_OK = TRUE;

	// render sleep counter
	m_Sleep = RENDSLEEPN;

	// stop render thread request
	m_StopReq = FALSE;

	// duplicate graph of filters
	FLock.Lock();
	CFilter* f;
	CFilter* f2;
	ListForEach(f, &FGraph)
	{
		if (f->Category() == FCAT_INIMAGE) ((CFilterImage*)f)->FileLoad();

		f2 = f->Duplicate();
		if (f2 == NULL)
		{
			FLock.Unlock();
			return FALSE;
		}
		f->SetFilterMap(f2);
		if (f == (CFilter*)RenderFilter) m_OutFilter = (CFilterOut*)f2;
		m_Graph.AddLast(f2);
	}

	int i;
	CProperty* p;
	ListForEach(f, &m_Graph)
	{
		for (i = 0; i < f->PropNum(); i++)
		{
			p = f->Prop(i);
			f2 = p->Filter();
			if ((f2 != NULL) && (f2 != &FLinear)) p->SetFilter(f2->FilterMap());
		}
	}
	FLock.Unlock();

	// start render thread
	m_RenderThreadH = ::CreateThread(NULL, 0, RenderThread, (void*)this, 0, NULL);
	if (m_RenderThreadH == NULL) return FALSE;
	::SetThreadPriority(m_RenderThreadH, RenderPriorityTab[RenderPriority]);
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// stop render object

void CRender::Stop()
{
	// stop render thread
	m_StopReq = TRUE;
	::WaitForSingleObject(m_RenderThreadH, 500);
	::CloseHandle(m_RenderThreadH);
	::Sleep(5);

	// destroy graph of filters
	while (!m_Graph.IsEmpty())
	{
		CFilter* f = m_Graph.First();
		m_Graph.Delete(f);
		delete f;
	}
}

/////////////////////////////////////////////////////////////////////////////
// load render configuration

void LoadRenderIni()
{
	// render queue on check
	RenderQueueOn = ReadIniBool("RenderQueueOn", (ReadIniInt("Queue", 0) > 0));

	// render width
	RenderWidth = ReadIniInt("RenderWidth", RenderWidth);
	if (RenderWidth < 1) RenderWidth = 1;
	if (RenderWidth > 32767) RenderWidth = 32767;

	// render height
	RenderHeight = ReadIniInt("RenderHeight", RenderHeight);
	if (RenderHeight < 1) RenderHeight = 1;
	if (RenderHeight > 32767) RenderHeight = 32767;

	// render antialiasing
	RenderAnti = ReadIniBool("RenderAnti", RenderAnti);

	// continue rendering
	RenderCont = ReadIniBool("RenderCont", RenderCont);

	// render fle
	RenderFile = ReadIniTxt("RenderFile", RenderFile);

	// render transparency
	RenderTrans = ReadIniBool("RenderTrans", RenderTrans);

	// render priority
	RenderPriority = ReadIniInt("RenderPriority", RenderPriority);
	if (RenderPriority < 0) RenderPriority = 0;
	if (RenderPriority >= CPUPRIOR_NUM) RenderPriority = CPUPRIOR_NUM-1;

	// number of threads
	RenderThreads = ReadIniInt("RenderThreads", RenderThreads);
	if (RenderThreads < 0) RenderThreads = 0;
	if (RenderThreads > RENDMAX) RenderThreads = RENDMAX;

	// render auto name
	RenderAuto = ReadIniBool("RenderAuto", RenderAuto);

	// number of frames
	RenderFrames = ReadIniInt("RenderFrames", RenderFrames);
	if (RenderFrames < 0) RenderFrames = 0;

	// current frame
	RenderFrame = ReadIniInt("RenderFrame", RenderFrame);

	// last frame
	RenderLast = ReadIniInt("RenderLast", RenderLast);

	// render JPG
	RenderJPG = ReadIniBool("RenderJPG", RenderJPG);

	// current JPG quality
	RenderQuality = ReadIniInt("RenderQuality", RenderQuality);
}

/////////////////////////////////////////////////////////////////////////////
// save render configuration

void SaveRenderIni()
{
	WriteIniBool("RenderQueueOn", RenderQueueOn);
	WriteIniInt("RenderWidth", RenderWidth);
	WriteIniInt("RenderHeight", RenderHeight);
	WriteIniBool("RenderAnti", RenderAnti);
	WriteIniBool("RenderCont", RenderCont);
	WriteIniInt("Output", OutFilterInx);
	WriteIniTxt("RenderFile", RenderFile);
	WriteIniBool("RenderTrans", RenderTrans);
	WriteIniBool("RenderAuto", RenderAuto);
	WriteIniInt("RenderFrames", RenderFrames);
	WriteIniInt("RenderFrame", RenderFrame);
	WriteIniInt("RenderLast", RenderLast);
	WriteIniBool("RenderJPG", RenderJPG);
	WriteIniInt("RenderQuality", RenderQuality);
}

/////////////////////////////////////////////////////////////////////////////
// save queue list

void SaveRenderQueueList()
{
	WriteIniInt("Queue", RendQueueNum);

	int i;
	CText txt;
	CText grp;
	SRendQueue* q;
	for (i = 0; i < RendQueueNum; i++)
	{
		grp = _T("Queue");
		grp.AddInt(i+1);
		q = &RendQueue[i];

		WriteIniTxt(grp, "Group", q->m_Group);
		WriteIniTxt(grp, "Filter", q->m_Filter);
		WriteIniTxt(grp, "Variant", q->m_Variant);
		WriteIniTxt(grp, "Presets", q->m_Presets);
		WriteIniTxt(grp, "File", q->m_File);
		WriteIniInt(grp, "Width", q->m_Width);
		WriteIniInt(grp, "Height", q->m_Height);
		WriteIniBool(grp, "Anti", q->m_Anti);
		WriteIniBool(grp, "Cont", q->m_Cont);
		WriteIniBool(grp, "Trans", q->m_Trans);
		WriteIniInt(grp, "Out", q->m_Out);
		WriteIniInt(grp, "Time", q->m_Time);
		WriteIniInt(grp, "Frames", q->m_Frames);
		WriteIniInt(grp, "Frame", q->m_Frame);
		WriteIniInt(grp, "Last", q->m_Last);
		WriteIniBool(grp, "JPG", q->m_JPG);
		WriteIniInt(grp, "Quality", q->m_Quality);
		WriteIniInt(grp, "Auto", q->m_Auto);
	}

	for (; i < RendQueueNum+30; i++)
	{
		grp = _T("Queue");
		grp.AddInt(i+1);
		WriteIniDelGrp(grp);
	}
}

///////////////////////////////////////////////////////////////////////////////
// load render queue (return FALSE on error)

BOOL LoadRenderQueue(int inx)
{
	if (!SelectMode || (inx < 0) || (inx >= RendQueueNum)) return FALSE;
	SRendQueue* q = &RendQueue[inx];

	GroupList.SetSelName(q->m_Group);
	GraphList.SetPath(EmptyText);
	VarList.SetPath(EmptyText);
	WriteIniTxt("Group", GroupList.SelName());
	GraphList.SetSelName(q->m_Filter);
	WriteIniTxt("Graph", GraphList.SelName());
	VarList.SetSelName(q->m_Variant);
	WriteIniTxt("Variation", VarList.SelName());
	GroupList.Load();
	LoadGraphList();
	if (VarList.SelInx() < 0) SetVarProp(q->m_Presets);
	if (OutFilterNum <= 0) return FALSE;

	// set properties
	RenderWidth = q->m_Width;
	if (RenderWidth < 1) RenderWidth = 1;
	if (RenderWidth > 32767) RenderWidth = 32767;
	RenderHeight = q->m_Height;
	if (RenderHeight < 1) RenderHeight = 1;
	if (RenderHeight > 32767) RenderHeight = 32767;
	RenderAnti = q->m_Anti;
	RenderCont = q->m_Cont;
	RenderFile = q->m_File;
	RenderTrans = q->m_Trans;
	OutFilterInx = q->m_Out;
	OutSelBox.SetSelect(OutFilterInx);
	RenderEstTime = q->m_Time;
	RenderFrames = q->m_Frames;
	RenderFrame = q->m_Frame;
	RenderLast = q->m_Last;
	RenderJPG = q->m_JPG;
	RenderQuality = q->m_Quality;
	RenderAuto = q->m_Auto;

	SaveRenderIni();
	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// load queue list

void LoadRenderQueueList()
{
	RendQueueNum = ReadIniInt("Queue", 0);
	if (RendQueueNum < 0) RendQueueNum = 0;
	if (RendQueueNum > RENDQUEUEMAX) RendQueueNum = RENDQUEUEMAX;

	int i;
	CText txt;
	CText grp;
	SRendQueue* q;
	for (i = 0; i < RendQueueNum; i++)
	{
		grp = _T("Queue");
		grp.AddInt(i+1);
		q = &RendQueue[i];

		q->m_Group = ReadIniTxt(grp, "Group", EmptyText);
		q->m_Filter = ReadIniTxt(grp, "Filter", EmptyText);
		q->m_Variant = ReadIniTxt(grp, "Variant", EmptyText);
		q->m_Presets = ReadIniTxt(grp, "Presets", EmptyText);
		q->m_File = ReadIniTxt(grp, "File", _T("Texture.tga"));
		q->m_Width = ReadIniInt(grp, "Width", 512);
		q->m_Height = ReadIniInt(grp, "Height", 512);
		q->m_Anti = ReadIniBool(grp, "Anti", FALSE);
		q->m_Cont = ReadIniBool(grp, "Cont", TRUE);
		q->m_Trans = ReadIniBool(grp, "Trans", FALSE);
		q->m_Out = ReadIniInt(grp, "Out", 0);
		q->m_Time = ReadIniInt(grp, "Time", 0);
		q->m_Frames = ReadIniInt(grp, "Frames", 0);
		q->m_Frame = ReadIniInt(grp, "Frame", 0);
		q->m_Last = ReadIniInt(grp, "Last", 0);
		q->m_JPG = ReadIniBool(grp, "JPG", FALSE);
		q->m_Quality = ReadIniInt(grp, "Quality", 100);
		q->m_Auto = ReadIniInt(grp, "Auto", RenderAuto);
	}
}

/////////////////////////////////////////////////////////////////////////////
// update preset list box

void UpdateRenderPresets()
{
	int i;
	for (i = 0; i < RENDPRES_N; i++)
	{
		if ((RendPresX[i] == RenderWidth) && (RendPresY[i] == RenderHeight)) break;
	}
	RenderPresetsList.SetSelect(i);
}

/////////////////////////////////////////////////////////////////////////////
// update queue list

void UpdateRenderQueueList()
{
	int n = 0;

	RenderQueueList.DelAll();
	int i;
	for (i = 0; i < RendQueueNum; i++)
	{
		RenderQueueList.Add(RendQueue[i].m_File);
		n += RendQueue[i].m_Time;
	}
	RenderQueueList.SetSelect(RendQueueSel);

	CText t;
	t.SetTime(n);
	RenderEstTimeLab2.SetText(t);
}

/////////////////////////////////////////////////////////////////////////////
// set auto name

void RenderDoAuto()
{
	CText txt = GraphList.SelName();
	CText txt2 = VarList.SelName();
	int i = txt2.Int();
	if (txt2.IsEmpty())
	{
		CText txt3;
		for (i = 1; i < 100; i++)
		{
			txt3 = txt;
			txt3 += TCHAR(' ');
			txt3.AddInt(i);
			txt3 += _T(".tga");
			if (!FileExists(txt3)) break;
		}
	}
	txt += TCHAR(' ');
	txt.AddInt(i);
	i = RenderFrames;
	if (i > 0)
	{
		i--;
		txt += TCHAR('-');
		while (i > 0)
		{
			txt += FILENAMECHAR;
			i /= 10;
		}
	}
	txt += _T(".tga");
	RenderFile = txt;
	RenderFileEdit.SetText(txt);
}

/////////////////////////////////////////////////////////////////////////////
// render dialog

INT_PTR CALLBACK RenderProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
	case WM_INITDIALOG:
		{
			// initialize controls
			RenderDialog.SetHandle(hWnd);
			RenderStartButton.InitDlg(IDOK, &RenderDialog);
			RenderQueueOnCheck.InitDlg(IDC_QUEUEON, &RenderDialog);
			RenderQueueList.InitDlg(IDC_QUEUE, &RenderDialog);
			RenderClearBtn.InitDlg(IDC_CLEAR, &RenderDialog);
			RenderWidthEdit.InitDlg(IDC_WIDTH, &RenderDialog);
			RenderHeightEdit.InitDlg(IDC_HEIGHT, &RenderDialog);
			RenderPresetsList.InitDlg(IDC_PRESET, &RenderDialog);
			RenderAntiCheck.InitDlg(IDC_ANTI, &RenderDialog);
			RenderContCheck.InitDlg(IDC_CONTINUE, &RenderDialog);
			RenderFilterList.InitDlg(IDC_OUTPUT, &RenderDialog);
			RenderFileEdit.InitDlg(IDC_FILE, &RenderDialog);
			RenderBrowseBtn.InitDlg(IDC_BROWSE, &RenderDialog);
			RenderTransCheck.InitDlg(IDC_TRANS, &RenderDialog);
			RenderAutoCheck.InitDlg(IDC_AUTOCHECK, &RenderDialog);
			RenderQLoadBtn.InitDlg(IDC_QLOAD, &RenderDialog);
			RenderQStartBtn.InitDlg(IDC_QSTART, &RenderDialog);
			RenderQUpBtn.InitDlg(IDC_QUP, &RenderDialog);
			RenderQDownBtn.InitDlg(IDC_QDOWN, &RenderDialog);
			RenderQClearBtn.InitDlg(IDC_QCLEAR, &RenderDialog);
			RenderEstTimeLab.InitDlg(IDC_TIME, &RenderDialog);
			RenderEstTimeLab2.InitDlg(IDC_TIMEALL, &RenderDialog);
			RenderFramesEdit.InitDlg(IDC_FRAMES, &RenderDialog);
			RenderFrameEdit.InitDlg(IDC_FROM, &RenderDialog);
			RenderLastEdit.InitDlg(IDC_TO, &RenderDialog);
			RenderJPGCheck.InitDlg(IDC_JPG, &RenderDialog);
			RenderJPGSlider.InitDlg(IDC_JPGSLIDER, &RenderDialog);
			RenderJPGSlider.SetRange(0, 100, TRUE);
			RenderJPGSlider.SetPage(10);
			RenderJPGSlider.SetFreq(10);
			RenderJPGEdit.InitDlg(IDC_JPGQUALITY, &RenderDialog);

			// set controls
			RenderWidthEdit.SetNum(RenderWidth);
			RenderHeightEdit.SetNum(RenderHeight);
			int i;
			CText txt;
			for (i = 0; i < RENDPRES_N; i++)
			{
				txt.SetInt(RendPresX[i]);
				txt += _T(" x ");
				txt.AddInt(RendPresY[i]);
				RenderPresetsList.Add(txt);
			}
			txt.Load(IDS_CUSTOM);
			RenderPresetsList.Add(txt);
			RenderPresetsList.Resize(RenderPresetsList.Width(), 300);
			UpdateRenderPresets();

			RenderAntiCheck.SetCheck(RenderAnti);
			RenderContCheck.SetCheck(RenderCont);
			RenderAutoCheck.SetCheck(RenderAuto);

			for (i = 0; i < OutFilterNum; i++)
			{
				RenderFilterList.Add(OutFilter[i]->Label());
			}
			RenderFilterList.Resize(RenderFilterList.Width(), 300);
			RenderFilterList.SetSelect(((DWORD)OutFilterInx >= (DWORD)OutFilterNum) ? -1 : OutFilterInx);

			RenderFileEdit.SetText(RenderFile);
			RenderFileEdit.Enable(!RenderAuto);
			RenderTransCheck.SetCheck(RenderTrans);
			RenderJPGCheck.SetCheck(RenderJPG);
			RenderJPGSlider.SetPos(RenderQuality);
			RenderJPGEdit.SetInt(RenderQuality);

			LoadRenderQueueList();
			RendQueueSel = -1;
			UpdateRenderQueueList();
			if (RenderAuto) RenderDoAuto();

			if (RendQueueNum == 0) RenderQueueOn = FALSE;
			RenderQueueOnCheck.SetCheck(RenderQueueOn && SelectMode);
			RenderQueueOnCheck.Enable(SelectMode);
			RenderQueueList.Enable(RenderQueueOn && SelectMode);

			RenderClearBtn.Enable(RendQueueNum > 0);
			RenderQLoadBtn.Enable(FALSE);
			RenderQStartBtn.Enable(FALSE);
			RenderQUpBtn.Enable(FALSE);
			RenderQDownBtn.Enable(FALSE);
			RenderQClearBtn.Enable(FALSE);

			RenderFramesEdit.SetNum(RenderFrames);
			if (RenderFrames > 0)
			{
				RenderFrameEdit.SetNum(RenderFrame);
				RenderLastEdit.SetNum(RenderLast);
			}
			else
			{
				RenderFrameEdit.Enable(FALSE);
				RenderLastEdit.Enable(FALSE);
			}

			// create timer
			RenderEstTime = 0;
			::SetTimer(hWnd, RENDTIMERID2, RENDTIMER2, NULL);
		}
		return TRUE;

	case WM_COMMAND:
		switch(HIWORD(wParam))
		{
		case EN_CHANGE:
			switch (LOWORD(wParam))
			{
			case IDC_WIDTH:
				if (!RenderWidthEdit.Filling())
				{
					RenderWidth = RenderWidthEdit.GetInt();
					if (RenderWidth < 1) RenderWidth = 1;
					if (RenderWidth > 32767) RenderWidth = 32767;
					UpdateRenderPresets();
				}
				break;

			case IDC_HEIGHT:
				if (!RenderWidthEdit.Filling())
				{
					RenderHeight = RenderHeightEdit.GetInt();
					if (RenderHeight < 1) RenderHeight = 1;
					if (RenderHeight > 32767) RenderHeight = 32767;
					UpdateRenderPresets();
				}
				break;

			case IDC_FRAMES:
				if (!RenderFramesEdit.Filling())
				{
					int n = RenderFramesEdit.GetInt();
					if (n != RenderFrames)
					{
						RenderFrames = n;
						RenderFrame = 0;
						if (RenderFrames > 0)
						{
							RenderLast = RenderFrames - 1;
							RenderFrameEdit.SetNum(RenderFrame);
							RenderLastEdit.SetNum(RenderLast);
							RenderFrameEdit.Enable(TRUE);
							RenderLastEdit.Enable(TRUE);
						}
						else
						{
							RenderLast = 0;
							RenderFrames = 0;
							RenderFrameEdit.SetText(EmptyText);
							RenderLastEdit.SetText(EmptyText);
							RenderFrameEdit.Enable(FALSE);
							RenderLastEdit.Enable(FALSE);
						}
						if (RenderAuto) RenderDoAuto();
					}
				}
				break;

			case IDC_FROM:
				if (!RenderFrameEdit.Filling() && (RenderFrames > 0))
				{
					RenderFrame = RenderFrameEdit.GetInt();
				}
				break;

			case IDC_TO:
				if (!RenderLastEdit.Filling() && (RenderFrames > 0))
				{
					RenderLast = RenderLastEdit.GetInt();
				}
				break;

			case IDC_JPGQUALITY:
				if (!RenderJPGEdit.Filling())
				{
					RenderQuality = RenderJPGEdit.GetInt();
					RenderJPGSlider.SetPos(RenderQuality);
				}
				break;

			case IDC_FILE:
				if (!RenderFileEdit.Filling())
				{
					RenderFile = RenderFileEdit.GetText();
				}
				break;
			}
			break;

		case BN_CLICKED:
		case 1:
			switch (LOWORD(wParam))
			{
			// Help
			case ID_HELP:
				HelpHelp(HELP_RENDER);
				break;

			case IDC_PRESET:
				if (!RenderPresetsList.Filling())
				{
					int i = RenderPresetsList.GetSelect();
					if ((DWORD)i < (DWORD)RENDPRES_N)
					{
						RenderWidth = RendPresX[i];
						RenderHeight = RendPresY[i];
						RenderWidthEdit.SetInt(RendPresX[i]);
						RenderHeightEdit.SetInt(RendPresY[i]);
					}
				}
				break;

			case IDC_QUEUE:
				if (!RenderQueueList.Filling() && SelectMode && RenderQueueOn)
				{
					RendQueueSel = RenderQueueList.GetSelect();
					if (RendQueueSel >= RendQueueNum) RendQueueSel = -1;
					RenderQLoadBtn.Enable(RendQueueSel >= 0);
					RenderQStartBtn.Enable(RendQueueSel >= 0);
					RenderQUpBtn.Enable(RendQueueSel > 0);
					RenderQDownBtn.Enable((RendQueueSel >= 0) && (RendQueueSel < RendQueueNum-1));
					RenderQClearBtn.Enable(RendQueueSel >= 0);
				}
				break;

			case IDC_QUEUEON:
				if (!RenderQueueOnCheck.Filling() && SelectMode)
				{
					RenderQueueOn = RenderQueueOnCheck.GetCheck();
					RenderQueueList.Enable(RenderQueueOn);
				}
				break;

			case IDC_QSTART:
				if (!RenderQLoadBtn.Filling() && (RendQueueSel >= 0))
				{
					if (LoadRenderQueue(RendQueueSel))
					{
						// delete entry from render queue
						int i;
						for (i = RendQueueSel; i < RendQueueNum-1; i++)
						{
							RendQueue[i] = RendQueue[i+1];
						}
						RendQueueNum--;
						SaveRenderQueueList();
						SaveRenderIni();
						::KillTimer(hWnd, RENDTIMERID2);
						::EndDialog(hWnd, IDOK);
						return TRUE;
					}
				}
				break;

			case IDC_QLOAD:
				if (!RenderQLoadBtn.Filling() && (RendQueueSel >= 0))
				{
					LoadRenderQueue(RendQueueSel);
					RenderWidthEdit.SetNum(RenderWidth);
					RenderHeightEdit.SetNum(RenderHeight);
					UpdateRenderPresets();
					RenderAntiCheck.SetCheck(RenderAnti);
					RenderContCheck.SetCheck(RenderCont);
					RenderAutoCheck.SetCheck(RenderAuto);
					RenderFilterList.SetSelect(((DWORD)OutFilterInx >= (DWORD)OutFilterNum) ? -1 : OutFilterInx);
					RenderFileEdit.SetText(RenderFile);
					RenderFileEdit.Enable(!RenderAuto);
					RenderTransCheck.SetCheck(RenderTrans);
					RenderFramesEdit.SetNum(RenderFrames);
					RenderJPGCheck.SetCheck(RenderJPG);
					RenderJPGSlider.SetPos(RenderQuality);
					RenderJPGEdit.SetInt(RenderQuality);
					if (RenderFrames > 0)
					{
						RenderFrameEdit.SetNum(RenderFrame);
						RenderLastEdit.SetNum(RenderLast);
						RenderFrameEdit.Enable(TRUE);
						RenderLastEdit.Enable(TRUE);
					}
					else
					{
						RenderFrameEdit.SetText(EmptyText);
						RenderLastEdit.SetText(EmptyText);
						RenderFrameEdit.Enable(FALSE);
						RenderLastEdit.Enable(FALSE);
					}
					if (RenderAuto) RenderDoAuto();
				}
				break;

			case IDC_QUP:
				if (!RenderQUpBtn.Filling() && (RendQueueSel > 0))
				{
					RenderStartButton.SetFocus();
					RendQueueSel--;
					SRendQueue q = RendQueue[RendQueueSel];
					RendQueue[RendQueueSel] = RendQueue[RendQueueSel+1];
					RendQueue[RendQueueSel+1] = q;
					UpdateRenderQueueList();
					RenderQUpBtn.Enable(RendQueueSel > 0);
					RenderQDownBtn.Enable(TRUE);
					SaveRenderQueueList();
				}
				break;

			case IDC_QDOWN:
				if (!RenderQDownBtn.Filling() && (RendQueueSel >= 0) && (RendQueueSel < RendQueueNum-1))
				{
					RenderStartButton.SetFocus();
					RendQueueSel++;
					SRendQueue q = RendQueue[RendQueueSel];
					RendQueue[RendQueueSel] = RendQueue[RendQueueSel-1];
					RendQueue[RendQueueSel-1] = q;
					UpdateRenderQueueList();
					RenderQUpBtn.Enable(TRUE);
					RenderQDownBtn.Enable(RendQueueSel < RendQueueNum-1);
					SaveRenderQueueList();
				}
				break;

			case IDC_ANTI:
				if (!RenderAntiCheck.Filling())
				{
					RenderAnti = RenderAntiCheck.GetCheck();
				}
				break;

			case IDC_CONTINUE:
				if (!RenderContCheck.Filling())
				{
					RenderCont = RenderContCheck.GetCheck();
				}
				break;

			case IDC_JPG:
				if (!RenderJPGCheck.Filling())
				{
					RenderJPG = RenderJPGCheck.GetCheck();
				}
				break;

			case IDC_OUTPUT:
				if (!RenderFilterList.Filling())
				{
					OutFilterInx = RenderFilterList.GetSelect();
					if (SelectMode) OutSelBox.SetSelect(OutFilterInx);
				}
				break;

			case IDC_TRANS:
				if (!RenderTransCheck.Filling())
				{
					RenderTrans = RenderTransCheck.GetCheck();
				}
				break;

			case IDC_BROWSE:
				{
					CText txt = GetSaveLoadFile(IDS_PICMASK, _T("tga"), RenderFile, &RenderDialog, TRUE);
					if (txt.IsNotEmpty())
					{
						RenderFile = txt;
						RenderFileEdit.SetText(txt);
						RenderAuto = FALSE;
						RenderFileEdit.Enable(TRUE);
						RenderAutoCheck.SetCheck(FALSE);
					}
				}
				break;

			case IDC_QCLEAR:
				if (!RenderQClearBtn.Filling() && (RendQueueSel >= 0))
				{
					if (RendQueueNum == 1) goto QCLEARLAST;
					RenderStartButton.SetFocus();

					int i;
					for (i = RendQueueSel; i < RendQueueNum-1; i++)
					{
						RendQueue[i] = RendQueue[i+1];
					}
					RendQueueNum--;
					if (RendQueueSel == RendQueueNum) RendQueueSel--;

					UpdateRenderQueueList();
					RenderQUpBtn.Enable(RendQueueSel > 0);
					RenderQDownBtn.Enable(RendQueueSel < RendQueueNum-1);
					SaveRenderQueueList();
				}
				break;

			case IDC_CLEAR:
QCLEARLAST:
				RenderStartButton.SetFocus();
				RendQueueNum = 0;
				RendQueueSel = -1;
				UpdateRenderQueueList();
				SaveRenderQueueList();
				RenderQueueOn = FALSE;
				RenderQueueOnCheck.SetCheck(FALSE);
				RenderPresetsList.Enable(FALSE);
				RenderClearBtn.Enable(FALSE);
				RenderQLoadBtn.Enable(FALSE);
				RenderQStartBtn.Enable(FALSE);
				RenderQUpBtn.Enable(FALSE);
				RenderQDownBtn.Enable(FALSE);
				RenderQClearBtn.Enable(FALSE);
				break;

			case IDC_AUTOCHECK:
				if (!RenderAutoCheck.Filling())
				{
					RenderAuto = RenderAutoCheck.GetCheck();
					RenderFileEdit.Enable(!RenderAuto);
					if (RenderAuto) RenderDoAuto();
				}
				break;

			case IDC_AUTO:
				RenderDoAuto();
				break;

			case IDC_LATER:
				if (RendQueueNum >= RENDQUEUEMAX)
					break;
				{
					RenderQueueOn = TRUE;

					int i;
					for (i = RendQueueNum; i >= 0; i--)
					{
						RendQueue[i+1] = RendQueue[i];
					}
					RendQueueNum++;

					SRendQueue* q = &RendQueue[0];
					q->m_Group = GroupList.SelName();
					q->m_Filter = GraphList.SelName();
					q->m_Variant = VarList.SelName();
					q->m_Presets = GetVarProp();
					q->m_File = RenderFile;
					q->m_Width = RenderWidth;
					q->m_Height = RenderHeight;
					q->m_Anti = RenderAnti;
					q->m_Cont = RenderCont;
					q->m_Trans = RenderTrans;
					q->m_Out = OutFilterInx;
					q->m_Time = RenderEstTime;
					q->m_Frames = RenderFrames;
					q->m_Frame = RenderFrame;
					q->m_Last = RenderLast;
					q->m_JPG = RenderJPG;
					q->m_Quality = RenderQuality;
					q->m_Auto = RenderAuto;
					SaveRenderQueueList();
				}
			case IDOK:
			case IDCANCEL:
				SaveRenderIni();
				::KillTimer(hWnd, RENDTIMERID2);
				::EndDialog(hWnd, LOWORD(wParam));
				return TRUE;
			}
			break;
		}
		break;

	case WM_HSCROLL:
	case WM_VSCROLL:
		{
			HWND wnd = (HWND)lParam;
			if ((wnd == RenderJPGSlider.Handle()) && !RenderJPGSlider.Filling())
			{
				RenderQuality = RenderJPGSlider.GetPos();
				RenderJPGEdit.SetInt(RenderQuality);
			}
		}
		break;

	case WM_TIMER:
		if ((PrevStatTime > 0) && (PrevStatPix > 0))
		{
			int n = (int)(PrevStatTime*0.001/PrevStatPix*RenderWidth*RenderHeight*(RenderAnti ? 5 : 1));
			int k = RenderCPUNum;
			if ((RenderThreads > 0) && (RenderCPUNum > RenderThreads)) k = RenderThreads;
			n = (int)(n / ((sqrt((double)k)+k)/2));
			if (RenderFrames > 0)
			{
				int i = RenderLast - RenderFrame + 1;
				if (i < 1) i = 1;
				n *= i;
			}

			if (n != RenderEstTime)
			{
				RenderEstTime = n;
				CText t;
				t.SetTime(n);
				RenderEstTimeLab.SetText(t);
			}
		}
		break;
	}
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// get current filename

CText RenderGetFilename()
{
	CText txt = RenderFile;
	if (RenderFrames > 0)
	{
		int pos = txt.Find(FILENAMECHAR);
		if (pos >= 0)
		{
			int n = 1;
			while (pos + n < txt.Length())
			{
				if (txt[pos + n] == FILENAMECHAR)
					n++;
				else break;
			}

			CText t = txt.Left(pos);
			int k = 10;
			int n2 = 1;
			while (RenderFrame >= k)
			{
				n2++;
				k *= 10;
			}

			for (; n2 < n; n2++) t += TCHAR('0');

			t.AddInt(RenderFrame);
			t += txt.RightFrom(pos + n);
			txt = t;
		}
	}
	return txt;
}

/////////////////////////////////////////////////////////////////////////////
// rendering procedure

INT_PTR CALLBACK RenderProc2(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
	case WM_INITDIALOG:
		{
			// create timer
			::SetTimer(hWnd, RENDTIMERID, RENDTIMER, NULL);

			// initialize dialog controls
			ProgDialog.SetHandle(hWnd);
			RenderProg.InitDlg(IDC_PROGRESS, &ProgDialog);
			RenderProg.SetRange(0, RendTotal/RendDiv, TRUE);
			RenderProg.SetPos(RendInx/RendDiv, TRUE);
			RenderElapTxt.InitDlg(IDC_ELAPSED, &ProgDialog);
			RenderRemTxt.InitDlg(IDC_REMAIN, &ProgDialog);
			RenderInQueueTxt.InitDlg(IDC_INQUEUE, &ProgDialog);
			RenderTotalTxt.InitDlg(IDC_TOTAL, &ProgDialog);
			RenderPauseCheck.InitDlg(IDC_PAUSE, &ProgDialog);
			RenderPriorList.InitDlg(IDC_PRIORITY, &ProgDialog);
			RenderPriorList.AddMulti(IDS_PRIORITY);
			RenderPriorList.SetSelect(RenderPriority);
			RenderThreadsList.InitDlg(IDC_THREADS, &ProgDialog);
			RenderThreadsList.AddMulti(IDS_THREADS);
			RenderThreadsList.SetSelect(RenderThreads);
			RenderFileTxt.InitDlg(IDC_FILE, &ProgDialog);

			RenderFileTxt.SetText(RenderGetFilename());
		}
		return TRUE;

	case WM_COMMAND:
		switch(HIWORD(wParam))
		{
		case BN_CLICKED:
		case 1:
			switch (LOWORD(wParam))
			{
			case IDCANCEL2:
				::KillTimer(hWnd, RENDTIMERID);
				::EndDialog(hWnd, IDCANCEL);
				return TRUE;

			case IDC_PAUSE:
				if (!RenderPauseCheck.Filling())
					RenderPause = (u8)RenderPauseCheck.GetCheck();
				break;

			case IDC_PRIORITY:
				if (!RenderPriorList.Filling())
				{
					int i = RenderPriorList.GetSelect();
					if ((DWORD)i < (DWORD)CPUPRIOR_NUM)
					{
						RenderPriority = i;
						int k;
						for (k = 0; k < RendObjNum; k++)
							::SetThreadPriority(RendObj[k].m_RenderThreadH, RenderPriorityTab[i]);
						WriteIniInt("RenderPriority", RenderPriority);
					}
				}
				break;

			case IDC_THREADS:
				if (!RenderThreadsList.Filling())
				{
					int i = RenderThreadsList.GetSelect();
					if ((DWORD)i <= (DWORD)RENDMAX)
					{
						RenderThreads = i;
						if (i == 0) i = RenderCPUNum;
						RenderThreadsNew = i;
						WriteIniInt("RenderThreads", RenderThreads);
					}
				}
				break;
			}
			break;
		}
		break;

	case WM_TIMER:
		{
			// get number of rendered pixels
			BOOL ok = TRUE;
			int n = 0;
			int i;
			CRender* r;
			for (i = 0; i < RendObjNum; i++)
			{
				r = &RendObj[i];
				n += r->m_Num;
				if (!r->m_OK) ok = FALSE;
			}
			RendAllOK = ok;
			n /= RendTransByte;
			RendInxProg = RendInx + n;

			// shift progress indicator
			RenderUpdateProg--;
			if (RenderUpdateProg <= 0) RenderUpdateProg = 10;

			// time
			if (!RenderPause && (RendInxProg > RendInx0))
			{
				// elapsed time
				RenderTimeElapsed += RENDTIMER;

				if (RenderUpdateProg == 10)
				{
					RenderProg.SetPos(RendInxProg/RendDiv, TRUE);

					// elapsed time
					n = (int)((real)RenderTimeElapsed/(RendInxProg-RendInx0)*RendInxProg) / 1000;
					CText txt;
					txt.SetTime(n);
					RenderElapTxt.SetText(txt);

					// remaining time
					n = (int)((real)RenderTimeElapsed/(RendInxProg-RendInx0)*(RendTotal-RendInx0)) - RenderTimeElapsed;
					n /= 1000;
					txt.SetTime(n);
					RenderRemTxt.SetText(txt);

					// add frames
					txt.SetInt(RendQueueNum);
					if ((RenderFrames > 0) && (RenderFrame < RenderLast))
					{
						n += (int)((real)RenderTimeElapsed/(RendInxProg-RendInx0)*RendTotal)*(RenderLast - RenderFrame)/1000;
						txt += _T(" - ");
						txt.AddInt(RenderLast - RenderFrame);
					}

					// in queue
					RenderInQueueTxt.SetText(txt);

					// remaining total
					int i;
					for (i = 0; i < RendQueueNum; i++) n += RendQueue[i].m_Time;

					txt.SetTime(n);
					RenderTotalTxt.SetText(txt);
				}
			}

			// all buffers rendered OK
			if (RendAllOK)
			{
				// save buffers
				for (i = 0; i < RendObjNum; i++)
				{
					r = &RendObj[i];
					if (!RenderSaveErr && (r->m_Num > 0))
					{
						n = (int)fwrite(r->m_Data, 1, r->m_Num, RenderF);
						if (n != r->m_Num)
						{
							RenderSaveErr = TRUE;
							::KillTimer(hWnd, RENDTIMERID);
							::EndDialog(hWnd, IDCANCEL);
						}
					}

					RendInx += r->m_Num / RendTransByte;
				}

				// change number of render objects
				if (RenderThreadsNew != RendObjNum)
				{
					// increase number of threads
					for (i = RendObjNum; i < RenderThreadsNew; i++)
					{
						r = &RendObj[i];
						if (!r->Start())
						{
							RenderThreadsNew = i;
							break;
						}
					}

					// decrease number of threads
					for (i = RendObjNum - 1; i >= RenderThreadsNew; i--)
					{
						r = &RendObj[i];
						r->Stop();
					}

					RendObjNum = RenderThreadsNew;
				}

				// start new renders
				n = RendInx;
				int k;
				for (i = 0; i < RendObjNum; i++)
				{
					r = &RendObj[i];

					r->m_Num = 0;

					r->m_Y = n / RenderWidth;
					r->m_X = n - r->m_Y * RenderWidth;

					k = RendTotal - n;
					if (k > RENDBUFSIZE/RendTransByte) k = RENDBUFSIZE/RendTransByte;
					n += k;
					k *= RendTransByte;
					r->m_Max = k;

					if (k > 0)
					{
						r->m_OK = FALSE;
						RendAllOK = FALSE;
					}
				}
			}

			// stop rendering
			if (RendAllOK)
			{
				::KillTimer(hWnd, RENDTIMERID);
				::EndDialog(hWnd, IDOK);
			}
		}
		break;
	}
	return FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// save error

void RenderSaveError()
{
	CText txt, txt2;
	txt2.Load(ID_SAVEERR2);
	CText t = RenderGetFilename();
	txt.Format((LPCTSTR)txt2, (LPCTSTR)t);
	txt2.Load(ID_SAVEERR);
	::MessageBox(MainFrame->Handle(), txt, txt2, MB_OK);
}

///////////////////////////////////////////////////////////////////////////////
// open render window

void OpenRender()
{
	// no output filter
	if (OutFilterNum == 0) return;

	// number of processors
	SYSTEM_INFO	si;
	si.dwNumberOfProcessors = 1;
	::GetSystemInfo(&si);
	RenderCPUNum = si.dwNumberOfProcessors;
	if (RenderCPUNum < 1) RenderCPUNum = 1;
	if (RenderCPUNum > RENDMAX) RenderCPUNum = RENDMAX;

	// render dialog
	INT_PTR res = ::DialogBoxParam(Instance, MAKEINTRESOURCE(IDD_RENDER),
				MainFrame->Handle(), RenderProc, (LPARAM)0);

	while (res == IDOK)
	{
		RendTransByte = RenderTrans ? 4 : 3;

		// create output file
		RenderF = _tfopen(RenderGetFilename(), RenderCont ? _T("r+b") : _T("wb"));
		if ((RenderF == NULL) && RenderCont) RenderF = _tfopen(RenderGetFilename(), _T("wb"));
		if (RenderF == NULL)
		{
			RenderSaveError();
			return;
		}

		// get current file size
		fseek(RenderF, 0, SEEK_END);
		int size = ftell(RenderF) - sizeof(TGAHEADER);

		// create new file
		if (!RenderCont || (size < 1000))
		{
			size = 0;

			// prepare TGA file header
			TGAHEADER tga;
			memset(&tga, 0, sizeof(TGAHEADER));
			tga.DataTypeCode = 2;
			tga.Width = (WORD)RenderWidth;
			tga.Height = (WORD)RenderHeight;
			tga.BitsPerPixel = (BYTE)(RendTransByte * 8);
			if (RenderTrans) tga.ImageDescriptor = 8;

			// write TGA file header
			fseek(RenderF, 0, SEEK_SET);
			int n = (int)fwrite(&tga, 1, sizeof(TGAHEADER), RenderF);
			if (n != sizeof(TGAHEADER))
			{
				fclose(RenderF);
				RenderSaveError();
				return;
			}
		}

		// seek behind last valid line
		int n = size / (RendTransByte*RenderWidth);
		n *= RenderWidth;
		fseek(RenderF, n*RendTransByte + sizeof(TGAHEADER), SEEK_SET);

		// pause preview
		PreviewPause = TRUE;

		// prepare current pixel index
		RendTotal = RenderWidth * RenderHeight;
		RendInx0 = n;
		RendInx = n;
		RendInxProg = n;

		// number of threads when image is too small
		int k = RENDBUFSIZE / RendTransByte;
		k = ((RendTotal - n) + k - 1) / k;

		// prepare progress divider (progress cannot display big numbers)
		n = RendTotal;
		RendDiv = 1;
		while (n > 10000)
		{
			n >>= 1;
			RendDiv <<= 1;
		}

		// prepare number of threads
		n = RenderThreads;
		if (n == 0) n = RenderCPUNum;
		if (n > k) n = k;
		if (n < 1) n = 1;

		// output render filter
		RenderFilter = OutFilter[(OutFilterInx < OutFilterNum) ? OutFilterInx : 0];

		// other variables
		RenderSaveErr = FALSE;
		RenderTimeElapsed = 0;

		// create threads
		CRender* r;
		k = RendInx;
		int i, j;
		RendObjNum = n;
		RenderThreadsNew = n;

		PreviewMode = FALSE;
		RenderMode = TRUE;

		for (i = 0; i < n; i++)
		{
			r = &RendObj[i];
			if (!r->Start())
			{
				for (i--; i >= 0; i--) RendObj[i].Stop();
				fclose(RenderF);
				PreviewPause = FALSE;
				RenderSaveError();
				RenderMode = FALSE;
				return;
			}

			r->m_Y = k / RenderWidth;
			r->m_X = k - r->m_Y * RenderWidth;

			j = RendTotal - k;
			if (j > RENDBUFSIZE/RendTransByte) j = RENDBUFSIZE/RendTransByte;
			k += j;
			j *= RendTransByte;
			r->m_Num = 0;
			r->m_Max = j;

			if (j > 0) r->m_OK = FALSE;
		}

		// unpause render
		RenderPause = FALSE;

		// open progress dialog
		res = ::DialogBoxParam(Instance, MAKEINTRESOURCE(IDD_PROGRESS),
			MainFrame->Handle(), RenderProc2, (LPARAM)0);

		// stop render thread and save rest of data
		RendAllOK = TRUE;
		for (i = 0; i < RendObjNum; i++)
		{
			r = &RendObj[i];
			r->Stop();
			if (!r->m_OK) RendAllOK = FALSE;

			if (RendAllOK)
			{
				if (!RenderSaveErr && (r->m_Num > 0))
				{
					n = (int)fwrite(r->m_Data, 1, r->m_Num, RenderF);
					if (n != r->m_Num) RenderSaveErr = TRUE;
				}
			}
		}

		// close file
		fclose(RenderF);

		RenderMode = FALSE;

		// save JPG
		if (!RenderSaveErr && RenderJPG && (res == IDOK))
		{
			CText oldfile = RenderGetFilename();
			SCanvas* can = ImgLoad(oldfile);
			if (can == NULL)
				RenderSaveErr = TRUE;
			else
			{
				CText newfile = oldfile;
				int pos = newfile.FindRev(TCHAR('.'));
				if (pos < 0) pos = newfile.Length();
				newfile.DelToEnd(pos);
				newfile += _T(".jpg");
				if (!JPGSave(newfile, can, RenderQuality))
					RenderSaveErr = TRUE;
				else
					DeleteFile(oldfile);
				free(can);
			}
		}

		// unpause preview
		PreviewPause = FALSE;

		// save error
		if (RenderSaveErr)
		{
			RenderSaveError();
			break;
		}

		// next frame
		if ((RenderFrames > 0) && (RenderFrame < RenderLast))
		{
			if (res == IDOK) RenderFrame++;
			SaveRenderIni();
		}
		else
		{
			if ((RenderFrames > 0) && (RenderFrame != 0))
			{
				RenderFrame = 0;
				SaveRenderIni();
			}

			// render queue
			if (SelectMode && (res == IDOK) && (RendQueueNum > 0) && RenderQueueOn)
			{
				if (!LoadRenderQueue(0)) break;

				// delete entry from render queue
				int i;
				for (i = 0; i < RendQueueNum-1; i++)
				{
					RendQueue[i] = RendQueue[i+1];
				}
				RendQueueNum--;
				SaveRenderQueueList();
			}
			else
				break;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// generate mark in icon
/*
#define MARKW	5
#define MARKH	5

// mark
u8 MarkImg[MARKW*MARKH] = {
	0, 1, 1, 1, 0,
	1, 2, 2, 2, 1,
	1, 2, 2, 2, 1,
	1, 2, 2, 2, 1,
	0, 1, 1, 1, 0,
};

void GenMark(u8* data)
{
	u8* d = data + (FPREVWH - 8)*3 + (8 - MARKH)*FPREVWH*3;
	u8* s = MarkImg;
	int i,j;
	for (i = MARKH; i > 0; i--)
	{
		for (j = MARKW; j > 0; j--)
		{
			if (*s > 0)
			{
				u8 b = (*s == 2) ? 255 : 0;
				d[0] = b;
				d[1] = b;
				d[2] = 255;
			}
			d += 3;
			s++;
		}
		d += (FPREVWH - MARKW)*3;
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// save preview icon

void SaveIcon(const CText& filename /*, BOOL mark*/)
{
	// output filter
	if ((DWORD)OutFilterInx >= (DWORD)OutFilterNum) return;
	CFilterOut* f = OutFilter[OutFilterInx];

	// render image
	FLock.Lock();
	GenFPrev(f);
	FLock.Unlock();

	// set mark
	//if (mark) GenMark(f->Preview()->d);

	// open file
	FILE* file = _tfopen(filename, _T("wb"));
	if (file == NULL) return;

	// prepare BMP header
	BMPHEADER bmp;
	memset(&bmp, 0, sizeof(BMPHEADER));
	bmp.bfType = 0x4d42;
	bmp.bfSize = sizeof(BMPHEADER)+FPREVWH*FPREVWH*3;
	bmp.bfOffBits = sizeof(BMPHEADER);
	bmp.biSize = 40;
	bmp.biWidth = FPREVWH;
	bmp.biHeight = FPREVWH;
	bmp.biPlanes = 1;
	bmp.biBitCount = 24;
	bmp.biCompression = bmpBI_RGB;
	bmp.biSizeImage = FPREVWH*FPREVWH*3;
	bmp.biXPelsPerMeter = 5906;
	bmp.biYPelsPerMeter = 5906;

	// write BMP header
	fwrite(&bmp, 1, sizeof(BMPHEADER), file);

	// write data
	fwrite(f->Preview()->d, 1, FPREVWH*FPREVWH*3, file);

	// close file
	fclose(file);

	// restore preview
	/*if (mark && EditMode)
	{
		FLock.Lock();
		GenFPrev(f);
		FLock.Unlock();
	}  */
}
