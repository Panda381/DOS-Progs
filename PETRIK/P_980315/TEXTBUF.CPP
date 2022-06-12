
#include "stdafx.h"
#include "peter.h"
#include "TextBuf.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

////////////////////////////////////////////////////////////////////
// Poznámka - pøi kopii a pøesunu struktur se vytváøí nové indexy
//            textù, staré se pouze vynulují, ale nechají se na místì.
//            Tím pøi editaci narùstá tabulka indexù textù, ale snad
//            by to nemìlo vadit - je dost rezerva a pøi ukonèení
//            programu se vše spraví.

////////////////////////////////////////////////////////////////////
// konstruktor a destruktor

CTextBuf::CTextBuf()
{
	SetSize(0,100);
}

