
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                   Includes                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// version
#define VERMIN		19			// version minor number (in hundreds)
#define VERMAJ		1			// version major number
#define VERTXT		_T("119")	// version in short text form (used in file header)
#define VERTXT2		_T("1.19")	// version in long text form (used in About)
#define VERYEARTXT	_T("2015")	// version year in text form

// configurations
#define GRAPHEXT	"txg"		// filter graph filename extension
#define BACKEXT		"bak"		// filter graph backup filename extension
#define PREVEXT		"bmp"		// filter graph preview filename extension
#define VAREXT		"txp"		// filter variation filename extension
#define	ICONWH		64			// preview icon dimension

#define PICMAXWH	16384		// picture maximal width and height

///////////////////////////////////////////////////////////////////////////////
// compilation switches
// _DEBUG	... debug version
// _UNICODE	... UNICODE code

#pragma warning ( disable: 4100)		// warning - unreferenced parameter
#pragma warning ( disable: 4310)		// warning - cast truncates constant value
//#pragma warning ( disable: 4514)		// warning - unreferenced inline func.
//#pragma warning ( disable: 4710)		// warning - function not inlined
//#pragma warning ( disable: 4711)		// warning - automatic inline expans.
#pragma warning ( disable: 4996)		// warning - unsafe function

#pragma comment(lib, "comctl32.lib")	// common control
#pragma comment(lib, "Htmlhelp.lib")

///////////////////////////////////////////////////////////////////////////////
// system includes

#include <windows.h>
#define WM_MOUSEWHEEL          0x020A
//#define GET_X_LPARAM(lp)                        ((int)(short)LOWORD(lp))
//#define GET_Y_LPARAM(lp)                        ((int)(short)HIWORD(lp))
#include <commctrl.h>
#include <olectl.h>
#include <stdio.h>
#include <tchar.h>
#include <math.h>
#include <Htmlhelp.h>					// help

///////////////////////////////////////////////////////////////////////////////
// debug

#ifdef _DEBUG
#define ASSERT(f)	{ if (!(f)) _asm{int 3}; }
#else
#define ASSERT(f)	((void)0)
#endif	// _DEBUG

///////////////////////////////////////////////////////////////////////////////
// base types

typedef __int8				s8;
typedef __int16				s16;
typedef __int32				s32;
typedef __int64				s64;

typedef unsigned __int8		u8;
typedef unsigned __int16	u16;
typedef unsigned __int32	u32;
typedef unsigned __int64	u64;

// internal filter real number (float should be sufficient, but double is faster!)
//typedef float real;
typedef double real;

///////////////////////////////////////////////////////////////////////////////
// constants

#define PI (real)3.141592653589793
#define PI2 (real)6.283185307179586
#define SQRT2 (real)1.414213562373095 // sqrt(2)
#define RSQRT2 (real)0.7071067811865475 // 1/sqrt(2)
//#define SIN45 RSQRT2
//#define COS45 RSQRT2

// bits
#define	B0	0x1
#define	B1	0x2
#define	B2	0x4
#define	B3	0x8
#define	B4	0x10
#define	B5	0x20
#define	B6	0x40
#define	B7	0x80
#define	B8	0x100
#define	B9	0x200
#define	B10	0x400
#define	B11	0x800
#define	B12	0x1000
#define	B13	0x2000
#define	B14	0x4000
#define	B15	0x8000
#define B16 0x10000
#define B17	0x20000
#define B18	0x40000
#define	B19	0x80000
#define B20 0x100000
#define B21 0x200000
#define B22 0x400000
#define B23 0x800000
#define B24 0x1000000
#define B25 0x2000000
#define B26 0x4000000
#define B27 0x8000000
#define B28 0x10000000
#define B29 0x20000000
#define B30 0x40000000
#define B31 0x80000000

#define	BIGINT	0x40000000

///////////////////////////////////////////////////////////////////////////////
// inplace "new" operator
//		example:	new (&m_List[inx]) CText;
//					m_List[i].~CText()

inline void* operator new (size_t size, void* p)
{
	size;
	return p;
}

inline void operator delete (void* adr, void* p)
{
	adr; p;
	return;
}

///////////////////////////////////////////////////////////////////////////////
// macros and inlines

// clamp to range 0..1
inline real CLAMP(real x)
{
	return (x <= 0) ? 0 : ((x >= 1) ? 1 : x);
}

// clamp int to byte 0..255
inline u8 CLAMPB(int x)
{
	return (u8)((x < 0) ? 0 : ((x > 255) ? 255 : x));
}

// clamp int to word 0..65535
inline u16 CLAMPW(int x)
{
	return (u16)((x < 0) ? 0 : ((x > 0xffff) ? 0xffff : x));
}

// normalized sinus to 0..1 (input 0..1=angle 0..360°, output 0..1 with middle 0.5)
inline real SINNORM(real x)
{
	return sin(x*PI2)/2+(real)0.5;
}

// normalized cosinus to 0..1 (input 0..1=angle 0..360°, output 0..1 with middle 0.5)
inline real COSNORM(real x)
{
	return cos((x)*PI2)/2+(real)0.5;
}

// granularity (integer of x/y)
inline real GRAN(real x, real y)
{
	return (y == 0) ? x : floor(x/y)*y;
}

// modulo (reminder of x/y)
inline real MODUL(real x, real y)
{
	return x - GRAN(x,y);
}

inline real sqr(real x) { return x*x; }

#ifndef GET_X_LPARAM
#define GET_X_LPARAM(lParam)	((int)(short)LOWORD(lParam))
#endif
#ifndef GET_Y_LPARAM
#define GET_Y_LPARAM(lParam)	((int)(short)HIWORD(lParam))
#endif

// fast divide WORD by 255 into BYTE
inline BYTE div255(int n) { return (BYTE)((n * 32897) >> 23); }

// conversion big-endian / little-endian
inline WORD BigLit2(WORD n) { return (WORD)(((n & 0xFF) << 8) | \
													((n & 0xFF00) >> 8)); }
inline DWORD BigLit4(DWORD n) { return (DWORD)(((n & 0xFF) << 24) | \
				((n & 0xFF00) << 8) | ((n & 0xFF0000) >> 8) | (n >> 24)); }

// conversion from 1 bit to 8 bits (255/1)
//inline BYTE Col1To8(int val) { return (BYTE)(val*255); }

// conversion from 1 bit to 4 bits (15/1)
//inline BYTE Col1To4(int val) { return (BYTE)(val*15); }

// conversion from 2 bits to 8 bits (255/3)
inline BYTE Col2To8(int val) { return (BYTE)(val*85); }

// conversion from 2 bits to 4 bits (15/3)
//inline BYTE Col2To4(int val) { return (BYTE)(val*5); }

// conversion from 2 bits to 5 bits (31/3)
//inline BYTE Col2To5(int val) { return (BYTE)((val*31+1)/3); }

// conversion from 3 bits to 4 bits (15/7)
//inline BYTE Col3To4(int val) { return (BYTE)((val*15+3)/7); }

// conversion from 3 bits to 5 bits (31/7)
//inline BYTE Col3To5(int val) { return (BYTE)((val*31+3)/7); }

// conversion from 3 bits to 6 bits (63/7)
//inline BYTE Col3To6(int val) { return (BYTE)(val*9); }

// conversion from 3 bits to 8 bits (255/3)
//inline BYTE Col3To8(int val) { return (BYTE)((val*255+3)/7); }

// conversion from 4 bits to 5 bits (31/15)
//inline BYTE Col4To5(int val) { return (BYTE)((val*31+7)/15); }

// conversion from 4 bits to 6 bits (63/15)
//inline BYTE Col4To6(int val) { return (BYTE)((val*63+7)/15); }

// conversion from 4 bits to 8 bits (255/15)
inline BYTE Col4To8(int val) { return (BYTE)(val*17); }

// conversion from 5 bits to 6 bits (63/31)
//inline BYTE Col5To6(int val) { return (BYTE)((val*63+15)/31); }

// conversion from 5 bits to 8 bits (255/31)
//inline BYTE Col5To8(int val) { return (BYTE)((val*255+15)/31); }

// conversion from 6 bits to 8 bits (255/63)
//inline BYTE Col6To8(int val) { return (BYTE)((val*255+31)/63); }

///////////////////////////////////////////////////////////////////////////////
// program includes

#include "..\Resource\Resource.h"

#include "HelpIndex.h"

//#include "Main\CmdLine.h"

// Utilities
#include "Utilities\List.h"			// doubly linked list
#include "Utilities\Array.h"		// array list
#include "Utilities\Tree.h"			// tree structure
#include "Utilities\Rect.h"			// rectangle
#include "Utilities\Color.h"		// color vector
#include "Utilities\Text.h"			// text string
#include "Utilities\Noise.h"		// noise generator
#include "Utilities\Lock.h"			// section lock
#include "Utilities\Complex.h"		// complex numbers

// Canvas
#include "Canvas\Canvas.h"			// canvas
#include "Canvas\Font.h"			// font
#include "Canvas\bmp.h"				// BMP file
#include "Canvas\jpg.h"				// JPG file
#include "Canvas\png.h"				// PNG file
#include "Canvas\tga.h"				// TGA file

// Windows
#include "Windows\Window.h"			// window base class
#include "Windows\ChildWindow.h"	// child windows
#include "Windows\Button.h"			// button
#include "Windows\ButtonPic.h"		// button with picture
#include "Windows\CheckBox.h"		// check box
#include "Windows\CheckPic.h"		// check box with picture
#include "Windows\Label.h"			// text label
#include "Windows\GroupBox.h"		// group box
#include "Windows\Frame.h"			// window frame
#include "Windows\Image.h"			// image
#include "Windows\Picture.h"		// picture
#include "Windows\Edit.h"			// edit box
#include "Windows\ListBox.h"		// list box
#include "Windows\ComboBox.h"		// combo box
#include "Windows\ListView.h"		// list view
#include "Windows\Progress.h"		// progress bar
#include "Windows\Scroller.h"		// scroller
#include "Windows\Spin.h"			// spin control
#include "Windows\Status.h"			// status line
#include "Windows\Tabs.h"			// tabs
#include "Windows\ToolTip.h"		// tooltip
#include "Windows\Slider.h"			// slider
#include "Windows\ToolBar.h"		// tool bar
#include "Windows\ColorSel.h"		// color selection dialog
#include "Windows\FontSel.h"		// font selection dialog

// Filters
#include "Filters\!Property.h"		// filter property
#include "Filters\!Filter.h"		// base filter
#include "Filters\FilterBlend.h"	// blending filter
#include "Filters\FilterBox.h"		// box
#include "Filters\FilterBrick.h"	// brick generator
#include "Filters\FilterBright.h"	// brightness control
#include "Filters\FilterCard.h"		// card
#include "Filters\FilterCellular.h" // Cellular Worley noise generator
#include "Filters\FilterCheck.h"	// check generator
#include "Filters\FilterClamp.h"	// clamp filter
#include "Filters\FilterClip.h"		// paper clip generator
#include "Filters\FilterColorize.h" // gradient colorize filter
#include "Filters\FilterCurve.h"	// curve generators
#include "Filters\FilterCut.h"		// cut filter
#include "Filters\FilterDebug.h"	// debug
#include "Filters\FilterEaster.h"	// easter egg generator
#include "Filters\FilterEmboss.h"	// processing
#include "Filters\FilterFractal.h"	// fractals
#include "Filters\FilterGradient.h" // gradient generator
#include "Filters\FilterHexacomb.h"	// hexacomb generator
#include "Filters\FilterHSL.h"		// color correction filter
#include "Filters\FilterInOut.h"	// input/output filters
#include "Filters\FilterKaleid.h"	// kaleidoscope
#include "Filters\FilterLoop.h"		// loop
#include "Filters\FilterMath.h"		// level mathematical operations
#include "Filters\FilterMixer.h"	// color channels mixer
#include "Filters\FilterDuo.h"		// duo filter
#include "Filters\FilterParticle.h"	// particle generator
#include "Filters\FilterPerlin.h"	// Perlin noise generator
#include "Filters\FilterRGB.h"		// RGB channels
#include "Filters\FilterRotate.h"	// rotation filter
#include "Filters\FilterScale.h"	// scale filter
#include "Filters\FilterShear.h"	// shear filter
#include "Filters\FilterShift.h"	// shift filter
#include "Filters\FilterSpectrum.h" // spectrum gradient generator
#include "Filters\FilterStar.h"		// star generator
#include "Filters\FilterSwitch.h"	// switch sources
#include "Filters\FilterThres.h"	// threshold switch sources
#include "Filters\FilterWarp.h"		// warp filter

// Integrated filters
#include "Filters\FilterRose.h"		// rose filter
#include "Filters\FilterDandelion.h" // dandelion filter
#include "Filters\FilterBlade.h"	// blade filter
#include "Filters\FilterSewingButton.h"	// sewing button filter
#include "Filters\FilterCracks.h"	// cracks filter
#include "Filters\FilterGlass.h"	// glass filter
#include "Filters\FilterGranite.h"	// granite filter
#include "Filters\FilterMalachite.h" // malachite filter
#include "Filters\FilterMarble.h"	// marble filter
#include "Filters\FilterMetal.h"	// metal filter
#include "Filters\FilterWood.h"		// wood filter
#include "Filters\FilterFabric.h"	// fabric filter
#include "Filters\FilterMaterial.h"	// material filter
#include "Filters\FilterShape.h"	// shape filter
#include "Filters\FilterSnowflake.h" // snowflake filter
#include "Filters\FilterTussock.h"	// tussock filter

// Filter graph
#include "Graph\Graph.h"			// filter graph

// Rendering
#include "Render\Preview.h"			// preview render thread
#include "Render\Render.h"			// output render

// Filter editation
#include "Edit\PropFrame.h"			// property frame
#include "Edit\EditView.h"			// editor view
#include "Edit\EditProp.h"			// editation properties
#include "Edit\Edit.h"				// editation screen

// Filter Selection
#include "Select\VarList.h"			// variation list
#include "Select\GraphList.h"		// graph list
#include "Select\GroupList.h"		// group list
#include "Select\EditVar.h"			// editation variations
#include "Select\Select.h"			// selection screen

// Main module
#include "Main\MainFrame.h"			// application window
#include "Main\Main.h"				// main module
