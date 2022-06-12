
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              Editation Preview                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

// preview buffer
u8	EPrevBuf[EPREVWH*EPREVWH*3 + 1];	// preview buffer (+ 1 byte reserve to enable using DWORD)

// preview window
#define EPREVWINX (MainFrameClientLeft+GRPMARG+1)
#define EPREVWINY (MainFrameClientTop+GRPMARG+1)
#define EPREVWINW (EditW1-2*GRPMARG-2)
#define EPREVWINH (EditW1-2*GRPMARG-2)

// preview
#define EPREVDX ((EPREVWINW - EPREVWH)/2 + EPREVWINX)
#define EPREVDY ((EPREVWINH - EPREVWH)/2 + EPREVWINY)
#define EPREVDW EPREVWH
#define EPREVDH EPREVWH

#define EPREVINC ((real)1/EPREVWH) // preview increment
volatile u8 EPrevReq = TRUE;	// request to render preview
volatile u8 EPrevBreak = FALSE;	// request to break render preview
int EPrevStepN;					// preview steps (256,128,64,32,16,8,4,2,1)
int EPrevStepMask;				// preview steps mask
int EPrevX, EPrevY;				// preview coordinates
int EPrevProgN = EPREVWH*EPREVWH; // preview progress total
int EPrevProg;					// preview progress (0..PrevProgN)
#define EPREVSLEEPN 50			// preview sleep interval
int EPrevSleepN = EPREVSLEEPN;	// preview sleep counter
volatile u8 EPrevUpDisp = FALSE;	// request to update display
HANDLE EPrevThreadH = NULL;		// handle of preview thread
DWORD EPrevThreadID = 0;		// ID of preview thread

///////////////////////////////////////////////////////////////////////////////
// render preview thread

DWORD WINAPI EPrevThread(void* lParam)
{
	// lock filters
	FLock.Lock();
	FilterOut* f;
	u8* b;
	Vector col;
	for (;;)
	{
		// break render preview
		if (EPrevBreak) break;

		// get output filter
		if (((DWORD)OutFilterInx >= (DWORD)OutFilterNum) ||
			(((EPrevProg >= EPrevProgN) || (EPrevStepN == 0)) && !EPrevReq))
		{
			// sleep and wait to interrupt
EPrevThreadSleep:
			EPrevUpDisp = TRUE;
			FLock.Unlock();
			::Sleep(15);
			FLock.Lock();
			continue;
		}
		f = OutFilter[OutFilterInx];

		// restart rendering
		if (EPrevReq)
		{
			EPrevReq = FALSE;
			EPrevStepN = EPREVWH/2;
			EPrevStepMask = EPREVWH/2-1;
			EPrevX = EPREVWH/2;
			EPrevY = 0;

			// first pixel
			b = &EPrevBuf[0];
			f->RenderCol(&col, (real)0.5*EPREVINC, (real)0.5*EPREVINC);
			int k = col.GetB() + (col.GetG()<<8) + (col.GetR()<<16); 
			int i;
			for (i = EPREVWH*EPREVWH; i > 0; i--)
			{
				*(int*)b = k;
				b += 3;
			}
			EPrevProg = 1;
		}

		// render color
		b = &EPrevBuf[(EPrevX + EPrevY*EPREVWH)*3];
		if (((EPrevX & EPrevStepMask) == 0) && ((EPrevY & EPrevStepMask) == 0))
		{
			f->RenderCol(&col, (EPrevX + (real)0.5)*EPREVINC, (EPrevY + (real)0.5)*EPREVINC);
			b[0] = col.GetB();
			b[1] = col.GetG();
			b[2] = col.GetR();
			EPrevProg++;
			if (EPrevProg >= EPrevProgN) goto EPrevThreadSleep;
		}
		else
		{
			if ((EPrevY & EPrevStepMask) == 0)
			{
				b[0] = b[-3];
				b[1] = b[-2];
				b[2] = b[-1];
			}
			else
			{
				b[0] = b[-EPREVWH*3];
				b[1] = b[-EPREVWH*3+1];
				b[2] = b[-EPREVWH*3+2];
			}
		}
		EPrevUpDisp = TRUE;

		// shift coordinate
		EPrevX++;
		if (((EPrevX & EPrevStepN) == 0) && ((EPrevY & EPrevStepN) == 0)) EPrevX += EPrevStepN;
		if (EPrevX >= EPREVWH)
		{
			EPrevX = 0;
			EPrevY++;
			if ((EPrevY & EPrevStepN) == 0) EPrevX = EPrevStepN;
			
			if (EPrevY >= EPREVWH)
			{
				EPrevStepN >>= 1;
				EPrevStepMask >>= 1;
				if (EPrevStepN == 0) goto EPrevThreadSleep;
				EPrevY = 0;
				EPrevX = EPrevStepN;
			}
		}

		// unlock filters
		EPrevSleepN--;
		if (EPrevSleepN <= 0)
		{
			EPrevSleepN = EPREVSLEEPN;
			FLock.Unlock();
			::Sleep(0);
			FLock.Lock();
		}
	}

	// unlock filters
	FLock.Unlock();

	return 1;
}

///////////////////////////////////////////////////////////////////////////////
// start render preview

void EPrevRenderStart()
{
	// request
	EPrevUpDisp = FALSE;
	EPrevBreak = FALSE;
	EPrevReq = TRUE;

	// create preview thread
	if (EPrevThreadH == NULL)
	{
		if ((DWORD)OutFilterInx >= (DWORD)OutFilterNum) return;
		EPrevProg = 0;
		EPrevThreadH = ::CreateThread(NULL, 0, EPrevThread, NULL, 0, &EPrevThreadID);
		if (EPrevThreadH == NULL) return;
		::SetThreadPriority(EPrevThreadH, THREAD_PRIORITY_IDLE);
	}
}

///////////////////////////////////////////////////////////////////////////////
// stop render preview

void EPrevRenderStop()
{
	// request to break
	EPrevBreak = TRUE;
	EPrevReq = FALSE;

	// create preview thread
	if (EPrevThreadH != NULL)
	{
		::WaitForSingleObject(EPrevThreadH, 100);
		::CloseHandle(EPrevThreadH);
		EPrevThreadH = NULL;
	}
}

///////////////////////////////////////////////////////////////////////////////
// redraw preview

void EditRedrawPrev()
{
	// reset update display request
	EPrevUpDisp = FALSE;
	if (EPrevProg >= EPrevProgN) EPrevRenderStop();

	// get client window DC
	HDC dc = ::GetDC(MainFrame->Handle());

	// prepare bitmap info header
	BITMAPINFO bmp;
	memset(&bmp, 0, sizeof(BITMAPINFO));
	bmp.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
	bmp.bmiHeader.biHeight = EPREVWH;
	bmp.bmiHeader.biWidth = EPREVWH;
	bmp.bmiHeader.biPlanes = 1;
	bmp.bmiHeader.biBitCount = 24;
	bmp.bmiHeader.biCompression = BI_RGB;

	// stretch mode - no smoothing
	::SetStretchBltMode(dc, COLORONCOLOR);

	// display picture
//	u8* buf;
/*	if (Tiles)
	{
		int x, y, xd, yd, xs, ys, w, h;
		y = EPREVDY;
		while (y > EPREVWINY) y -= SPREVWH;
		for (; y < PrevWinY + PrevWinH; y += SPREVWH)
		{
			yd = y;
			ys = 0;
			h = SPREVWH;
			if (yd < PrevWinY)
			{
				ys = PrevWinY - yd;
				h -= ys;
				yd = PrevWinY;
			}
			if (yd + h > PrevWinY + PrevWinH) h = PrevWinY + PrevWinH - yd;
			bmp.bmiHeader.biHeight = h;

			x = PrevDX;
			while (x > PrevWinX) x -= SPREVWH;
			for (; x < PrevWinX + PrevWinW; x += SPREVWH)
			{
				xd = x;
				xs = 0;
				w = SPREVWH;
				if (xd < PrevWinX)
				{
					xs = PrevWinX - xd;
					w -= xs;
					xd = PrevWinX;
				}
				if (xd + w > PrevWinX + PrevWinW) w = PrevWinX + PrevWinW - xd;

				buf = PrevBuf + (SPREVWH - ys - h)*SPREVWH*3;
				::StretchDIBits(dc, xd, yd, w, h, xs, 0,
					w, h, buf, &bmp, DIB_RGB_COLORS, SRCCOPY);
			}
		}
	}*/

	::StretchDIBits(dc, EPREVDX, EPREVDY, EPREVDW, EPREVDH, 0, 0,
		EPREVDW, EPREVDH, EPrevBuf, &bmp, DIB_RGB_COLORS, SRCCOPY);

	// release DC
	::ReleaseDC(MainFrame->Handle(), dc);
}
