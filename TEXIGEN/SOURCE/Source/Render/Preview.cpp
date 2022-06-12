
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Preview                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

BOOL Tiles = FALSE;				// display tiles

volatile BOOL PreviewMode = TRUE;	// preview mode

// preview thread
HANDLE PreviewThreadH = NULL;	// handle of render thread
DWORD PreviewThreadID = 0;		// ID of render thread
volatile BOOL StopPreviewThreadReq = FALSE;	// request to stop render thread

// ------- preview

// preview size
int PrevW;						// preview width
int PrevH;						// preview height
real PrevZoomX = 0;				// preview X relative coordinate
real PrevZoomY = 0;				// preview Y relative coordinate
real PrevZoomW = 1;				// preview relative width

volatile int PreviewPriority = 3;	// preview priority, 0=stop, 1=idle...6=normal (= CPUPRIOR + 1)

// preview dimension Select
int PrevDim = 5;
const int PrevDimXTab[PREVDIMN] = { 320, 256, 320, 512, 640, 512, 640, 1024, 1024, 1024 };
const int PrevDimYTab[PREVDIMN] = { 180, 256, 240, 256, 360, 512, 480,  512,  768, 1024 };

// preview dimension Edit
int PrevDim2 = 3;
const int PrevDimXTab2[PREVDIMN2] = { 256, 256, 256, 256 };
const int PrevDimYTab2[PREVDIMN2] = { 128, 144, 192, 256 };

// preview filter (NULL=none, LOCKED with FLock)
CFilter* PrevFilter = NULL;		// current preview filter

// preview buffer
u8	PrevBuf[PREVDIMMAXX*PREVDIMMAXY*3 + 5];		// preview buffer (+ 1 byte reserve to enable using DWORD)

// preview window
int PrevWinX, PrevWinY, PrevWinW, PrevWinH; // preview window position and size
int PrevDX, PrevDY, PrevDW, PrevDH;	// preview destination position and size
int PrevSX, PrevSY;				// preview source position

real PrevIncX = (real)1/512;	// preview increment X
real PrevIncY = (real)1/512;	// preview increment Y
volatile u8 PrevReq = TRUE;		// request to render preview
int PrevStepN = 64;				// preview steps (64,32,16,8,4,2,1)
int PrevStepMask = 0x3f;		// preview steps mask
int PrevX = 256;
int PrevY = 0;					// preview coordinates
int PrevProgN = 512*512;		// preview progress total
int PrevProg = 0;				// preview progress (0..PrevProgN)
//#define PREVSLEEPN 50			// preview sleep interval
int PrevSleepN = 10; //PREVSLEEPN;	// preview sleep counter
volatile u8 PrevUpDisp = FALSE;	// request to update preview display
volatile u8 PreviewPause = FALSE; // pause preview (set from render dialog)

// ----- filter preview images

volatile u8 FilterReq = TRUE;		// request to render filter preview images
volatile u8 FilterViewReq = TRUE;	// request to update filter view

// render statistic
int PrevStatTime = 0;			// time counter (in [ms])
int PrevStatPix = 0;			// pixel counter

///////////////////////////////////////////////////////////////////////////////
// clear preview buffer

void ClearPrevBuf()
{
	memset(PrevBuf, 0, PREVDIMMAXX*PREVDIMMAXY*3);
}

///////////////////////////////////////////////////////////////////////////////
// update preview statistic timer (called every 55 ms)

void PreviewStatTimer()
{
	if (!StopPreviewThreadReq && !PreviewPause && (PrevFilter != NULL) &&
		(PrevProg < PrevProgN) && (PrevStepN > 0))
			PrevStatTime += TIMERTIME;
}

///////////////////////////////////////////////////////////////////////////////
// preview layout (need PrevWH to be set)

void PreviewLayout(int x, int y, int w, int h, int prevw, int prevh)
{
	PrevW = prevw;
	PrevH = prevh;
	PrevWinX = x;
	PrevWinY = y;
	PrevWinW = w;
	PrevWinH = h;
	PrevDW = prevw;
	if (PrevDW > PrevWinW) PrevDW = PrevWinW;
	PrevDX = (PrevWinW - PrevDW)/2 + PrevWinX;
	PrevDH = prevh;
	if (PrevDH > PrevWinH) PrevDH = PrevWinH;
	PrevDY = (PrevWinH - PrevDH)/2 + PrevWinY;
	PrevSX = (prevw - PrevDW)/2;
	PrevSY = (prevh - PrevDH)/2;
}

///////////////////////////////////////////////////////////////////////////////
// generate filter preview

void GenFPrev(CFilter* f)
{
#define FPREVINC ((real)1/FPREVWH)

	f->SetReqPrev(FALSE);

	if ((f->Category() == FCAT_INVALUE) || (f->Category() == FCAT_PIN)) return;

	// generate preview image
	u8* d = f->Preview()->d;
	real x, y;
	CColor col, col2;
	CurRenderDX = FPREVINC;
	CurRenderDY = FPREVINC;
	for (y = FPREVINC/2; y < 1; y += FPREVINC)
	{
		for (x = FPREVINC/2; x < 1; x += FPREVINC)
		{
			PreviewMode = FALSE;
			RenderMode = FALSE;
			CurRenderX = x;
			CurRenderY = y;
			f->RenderCol(&col, x, y);
			if (col.a < 1)
			{
				col2.SetGray(((((int)(x*GRIDN1)+(int)(y*GRIDN1)) & 1) == 0) ? GRID1 : GRID2);
				col.BlendInv(col2);
			}
			*d++ = col.GetB();
			*d++ = col.GetG();
			*d++ = col.GetR();
		}
	}

	// generate curve
	if ((f->Category() == FCAT_CURVE) || (f->Category() == FCAT_TABLE))
	{
		// convert image to gray
		u8* s = f->Preview()->d;
		u8 buf[FPREVWH*FPREVWH];
		d = buf;
		int i;
		for (i = FPREVWH*FPREVWH; i > 0; i--)
		{
			//*d++ = s[0]/19 + s[1]*3/4 + s[2]/5; // makes some tooth on linear curve
			*d++ = (s[0]+ s[1]+ s[2])/3;
			s += 3;
		}

		// generate curve image
		d = f->Preview()->d;
		int xx, yy;
		int n;
		int k = 0;
		for (yy = 0; yy < FPREVWH; yy++)
		{
			for (xx = 0; xx < FPREVWH; xx++)
			{
				s = &buf[xx];
				n = 0;
				for (i = FPREVWH; i > 0; i--)
				{
					if (k > *s) n += 256/FPREVWH;
					s += FPREVWH;
				}
				if (n > 255) n = 255;
				*d++ = 210;
				*d++ = (u8)n;
				*d++ = (u8)n;
			}
			k += 256/FPREVWH;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// render thread

DWORD WINAPI PreviewThread(void* lParam)
{
	// lock filters
	FLock.Lock();
	CFilter* f;
	u8* b;
	CColor col, col2;
	real x, y;
	BOOL update;
	while (!StopPreviewThreadReq)
	{
		// pause
		if (PreviewPause) goto PrevThreadSleep;

		// filter preview images
		if (FilterReq && EditMode && ((PrevFilter == NULL) || (((PrevStepN <= 2) ||
				((PreviewPriority == 0) && (PrevStepN <= 32))) && !PrevReq)))
		{
			if (PrevUpDisp)
			{
				FLock.Unlock();
				::Sleep(15);
				FLock.Lock();
			}

			do {
				ListForEach(f, &FGraph)
				{
					if (f->ReqPrev())
					{
						GenFPrev(f);
						FilterViewReq = TRUE;
						FLock.Unlock();
						::Sleep(0);
						FLock.Lock();
						break;
					}
				}
			} while (f != FGraph.Head());
			FilterReq = FALSE;
		}

		// get preview filter
		f = PrevFilter;
		if ((f == NULL) || (((PrevProg >= PrevProgN) || (PrevStepN == 0)) && !PrevReq))
		{
			// sleep and wait to interrupt
PrevThreadSleep:
			FLock.Unlock();
			::Sleep(15);
			FLock.Lock();
			continue;
		}

		// request to update preview display
		if ((PrevStepN <= 4) || (PreviewPriority == 0)) PrevUpDisp = TRUE;

		// restart rendering
		update = FALSE;
		if (PrevReq)
		{
			PrevUpDisp = FALSE;
			PrevSleepN = 10;//PREVSLEEPN;
			PrevReq = FALSE;
			PrevProgN = PrevW*PrevH;
#define PREVSTEPN0 64
			PrevStepN = PREVSTEPN0;
			PrevStepMask = PrevStepN - 1;
			PrevIncX = (real)1/PrevW;
			PrevIncY = (real)1/PrevH;
			CurRenderDX = PrevIncX;
			CurRenderDY = PrevIncY;
			PrevX = 0;
			PrevY = 0;
			PrevStatTime = 0;
			PrevStatPix = 0;
			PrevProg = 0;
		}

		// render color
		b = &PrevBuf[(PrevX + PrevY*PrevW)*3];
		if (((PrevX & PrevStepMask) == 0) && ((PrevY & PrevStepMask) == 0))
		{
			PreviewMode = TRUE;
			RenderMode = FALSE;
			x = (PrevX + (real)0.5)*PrevIncX*PrevZoomW + PrevZoomX;
			y = (PrevY + (real)0.5)*PrevIncY*PrevZoomW + PrevZoomY;
			CurRenderX = x;
			CurRenderY = y;
			f->RenderCol(&col, x, y);
			update = TRUE;

			PrevStatPix++;

			if (EditMode && (col.a < 1))
			{
				col2.SetGray(((((int)(x*GRIDN2/PrevZoomW)+(int)(y*GRIDN2/PrevZoomW)) & 1) == 0) ? GRID1 : GRID2);
				col.BlendInv(col2);
			}

			b[0] = col.GetB();
			b[1] = col.GetG();
			b[2] = col.GetR();
			PrevProg++;
			if (PrevProg >= PrevProgN) goto PrevThreadSleep;
		}
		else
		{
			if ((PrevY & PrevStepMask) == 0)
			{
				b[0] = b[-3];
				b[1] = b[-2];
				b[2] = b[-1];
			}
			else
			{
				b[0] = b[-PrevW*3];
				b[1] = b[-PrevW*3+1];
				b[2] = b[-PrevW*3+2];
			}
		}

		// shift coordinate
		PrevX++;
		if (((PrevX & PrevStepN) == 0) && ((PrevY & PrevStepN) == 0) && (PrevStepN < PREVSTEPN0)) PrevX += PrevStepN;
		if (PrevX >= PrevW)
		{
			PrevX = 0;
			PrevY++;
			if (((PrevY & PrevStepN) == 0) && (PrevStepN < PREVSTEPN0)) PrevX = PrevStepN;

			if (PrevY >= PrevH)
			{
				PrevStepN >>= 1;
				PrevStepMask >>= 1;
				if (PrevStepN == 0) goto PrevThreadSleep;
				PrevY = 0;
				PrevX = PrevStepN;
			}
		}

		// unlock filters
		if (update)
		{
			PrevSleepN--;
			if (PrevSleepN <= 0)
			{
				PrevSleepN = PreviewPriority*20 + 10; //PREVSLEEPN;
				FLock.Unlock();
				if (PreviewPriority == 0)
				{
					::Sleep(15);
					PrevStatTime -= 15;
				}
				else
					::Sleep(0);
				FLock.Lock();
			}
		}
	}

	// unlock filters
	FLock.Unlock();

	return 1;
}

///////////////////////////////////////////////////////////////////////////////
// start selection render preview

void SPrevRenderStart()
{
	PrevW = PrevDimXTab[PrevDim];
	PrevH = PrevDimYTab[PrevDim];
	PrevFilter = ((DWORD)OutFilterInx >= (DWORD)OutFilterNum) ? NULL : OutFilter[OutFilterInx];
	PrevUpDisp = FALSE;
	PrevReq = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// start edit render preview (selected filter or NULL=none)

void EPrevRenderStart(/*CFilter* f*/)
{
	PrevW = PrevDimXTab2[PrevDim2];
	PrevH = PrevDimYTab2[PrevDim2];
	//PrevFilter = f;
	PrevUpDisp = FALSE;
	PrevReq = TRUE;
	FilterReq = TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// stop render preview

void PrevRenderStop()
{
	PrevReq = FALSE;
}

///////////////////////////////////////////////////////////////////////////////
// redraw preview

void RedrawPreview()
{
	// reset update display request
	PrevUpDisp = FALSE;

	// get client window DC
	HDC dc = ::GetDC(MainFrame->Handle());

	// prepare bitmap info header
	BITMAPINFO bmp;
	memset(&bmp, 0, sizeof(BITMAPINFO));
	bmp.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
	bmp.bmiHeader.biHeight = PrevH;
	bmp.bmiHeader.biWidth = PrevW;
	bmp.bmiHeader.biPlanes = 1;
	bmp.bmiHeader.biBitCount = 24;
	bmp.bmiHeader.biCompression = BI_RGB;

	// stretch mode - no smoothing
	::SetStretchBltMode(dc, COLORONCOLOR);

	// display picture
	u8* buf;
	if (Tiles)
	{
		int x, y, xd, yd, xs, ys, w, h;
		y = PrevDY;
		while (y > PrevWinY) y -= PrevH;
		for (; y < PrevWinY + PrevWinH; y += PrevH)
		{
			yd = y;
			ys = 0;
			h = PrevH;
			if (yd < PrevWinY)
			{
				ys = PrevWinY - yd;
				h -= ys;
				yd = PrevWinY;
			}
			if (yd + h > PrevWinY + PrevWinH) h = PrevWinY + PrevWinH - yd;
			bmp.bmiHeader.biHeight = h;

			x = PrevDX;
			while (x > PrevWinX) x -= PrevW;
			for (; x < PrevWinX + PrevWinW; x += PrevW)
			{
				xd = x;
				xs = 0;
				w = PrevW;
				if (xd < PrevWinX)
				{
					xs = PrevWinX - xd;
					w -= xs;
					xd = PrevWinX;
				}
				if (xd + w > PrevWinX + PrevWinW) w = PrevWinX + PrevWinW - xd;

				buf = PrevBuf + (PrevH - ys - h)*PrevW*3;
				::StretchDIBits(dc, xd, yd, w, h, xs, 0,
					w, h, buf, &bmp, DIB_RGB_COLORS, SRCCOPY);
			}
		}
	}
	else
	{
		// frame background - top
		HBRUSH brush = (HBRUSH)::GetSysColorBrush(COLOR_BTNSHADOW); //COLOR_APPWORKSPACE);
		RECT rc;
		rc.left = PrevWinX;
		rc.right = PrevWinX + PrevWinW;
		if (PrevDY != PrevWinY)
		{
			rc.top = PrevWinY;
			rc.bottom = PrevDY;
			::FillRect(dc, &rc, brush);
		}

		// frame background - bottom
		if ((PrevDY + PrevDH) != (PrevWinY + PrevWinH))
		{
			rc.top = PrevDY + PrevDH;
			rc.bottom = PrevWinY + PrevWinH;
			::FillRect(dc, &rc, brush);
		}

		// frame background - left
		rc.top = PrevDY;
		rc.bottom = PrevDY + PrevDH;
		if (PrevDX != PrevWinX)
		{
			rc.left = PrevWinX;
			rc.right = PrevDX;
			::FillRect(dc, &rc, brush);
		}

		// frame background - right
		if ((PrevDX + PrevDW) != (PrevWinX + PrevWinW))
		{
			rc.left = PrevDX + PrevDW;
			rc.right = PrevWinX + PrevWinW;
			::FillRect(dc, &rc, brush);
		}

		// picture
		buf = PrevBuf + (PrevH - PrevSY - PrevDH)*PrevW*3;
		::StretchDIBits(dc, PrevDX, PrevDY, PrevDW, PrevDH, PrevSX, 0,
			PrevDW, PrevDH, buf, &bmp, DIB_RGB_COLORS, SRCCOPY);
	}

	// release DC
	::ReleaseDC(MainFrame->Handle(), dc);
}

///////////////////////////////////////////////////////////////////////////////
// update preview priority

void UpdatePreviewPriority()
{
	if (PreviewThreadH != NULL)
	{
		int k = PreviewPriority - 1;
		if (k < 0) k = 0;
		::SetThreadPriority(PreviewThreadH, RenderPriorityTab[k]);
	}
}

///////////////////////////////////////////////////////////////////////////////
// start render thread (returns FALSE on error)

BOOL RenderInit()
{
	PreviewThreadH = ::CreateThread(NULL, 0, PreviewThread, NULL, 0, &PreviewThreadID);
	if (PreviewThreadH == NULL) return FALSE;
	UpdatePreviewPriority();
	return TRUE;
}

///////////////////////////////////////////////////////////////////////////////
// terminate render thread

void RenderTerm()
{
	StopPreviewThreadReq = TRUE;
	::WaitForSingleObject(PreviewThreadH, 500);
	::CloseHandle(PreviewThreadH);
}
