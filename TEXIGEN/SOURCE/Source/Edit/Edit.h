
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Filter Editation                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

extern volatile BOOL EditMode;	// editation mode is activated

extern int EditW1;				// width of left stripe
extern int EditW2;				// width of right stripe

extern int EditFGrpH;			// height of group filter selection

extern int GroupFSel;			// current selected group of filters template (0=all)

#define VIEWSCROLLERW	18		// width of scroller

#define GROUPSELHEIGHT	((FGRP_NUM+1)*13+7) // height of group selection box

#define DRAGDELTA	3			// start dragging delta of coordinates
#define DRAGDELTANEW 20			// start dragging delta of coordinates in new filter

#define ARROWDELTA	GRID		// tollerace of dragging connection

extern CListBox GrpSelListBox;			// group selection list box
extern CScroller FGrpScroller;			// group filter scroller

// scrollers
extern CScroller		ViewHScroller;		// view horizontal scroller
extern CScroller		ViewVScroller;		// view vertical scroller

#define EDITGRPDH  4			// gap between group selection and filter list

// lock view check
extern CCheckBox LockViewCheck;	// lock view check

extern BOOL Lock;				// lock filter preview

///////////////////////////////////////////////////////////////////////////////
// start edit screen (returns FALSE on error)

void CreateEdit();

///////////////////////////////////////////////////////////////////////////////
// update edit texts after changing language

void UpdateEditText();

///////////////////////////////////////////////////////////////////////////////
// close edit screen

void CloseEdit();

///////////////////////////////////////////////////////////////////////////////
// redraw edit window

void EditRedraw();

///////////////////////////////////////////////////////////////////////////////
// redraw group selection

void EditGSelRedraw();

///////////////////////////////////////////////////////////////////////////////
// select group of filters

void SetGroupFSel(int inx);

///////////////////////////////////////////////////////////////////////////////
// resize edit window

void EditResize();

///////////////////////////////////////////////////////////////////////////////
// delete filters

void EditDelete();

///////////////////////////////////////////////////////////////////////////////
// mouse event

void EditOnMouse(int x, int y, BOOL lb, BOOL rb, BOOL mb, int msg);

///////////////////////////////////////////////////////////////////////////////
// request to update current filter after change

void EditFilterUpdate();

///////////////////////////////////////////////////////////////////////////////
// auto generator

void AutoGener();
