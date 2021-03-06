
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                              Editation Preview                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// edit preview size
#define EPREVWH	256				// edit preview size

extern volatile u8 EPrevUpDisp;	// request to update display

///////////////////////////////////////////////////////////////////////////////
// start render preview

void EPrevRenderStart();

///////////////////////////////////////////////////////////////////////////////
// stop render preview

void EPrevRenderStop();

///////////////////////////////////////////////////////////////////////////////
// redraw preview

void EditRedrawPrev();
