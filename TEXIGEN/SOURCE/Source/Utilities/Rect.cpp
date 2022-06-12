
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Rectangle                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// clip rectangle with another rectangle

void CRect::Clip(const CRect& rc)
{
	if (left < rc.left) left = rc.left;
	if (left > rc.right) left = rc.right;
	if (top < rc.top) top = rc.top;
	if (top > rc.bottom) top = rc.bottom;
	if (right < rc.left) right = rc.left;
	if (right > rc.right) right = rc.right;
	if (bottom < rc.top) bottom = rc.top;
	if (bottom > rc.bottom) bottom = rc.bottom;
}

///////////////////////////////////////////////////////////////////////////////
// merge rectangle with another rectangle

void CRect::Merge(const CRect& rc)
{
	if (left > rc.left) left = rc.left;
	if (top > rc.top) top = rc.top;
	if (right < rc.right) right = rc.right;
	if (bottom < rc.bottom) bottom = rc.bottom;
}
