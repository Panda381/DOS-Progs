
#include "stdafx.h"
#include "peter.h"
#include "TextBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

////////////////////////////////////////////////////////////////////
// Pozn�mka - p�i kopii a p�esunu struktur se vytv��� nov� indexy
//            text�, star� se pouze vynuluj�, ale nechaj� se na m�st�.
//            T�m p�i editaci nar�st� tabulka index� text�, ale snad
//            by to nem�lo vadit - je dost rezerva a p�i ukon�en�
//            programu se v�e sprav�.

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CTextBuf::CTextBuf()
{
	SetSize(0,100);
}

