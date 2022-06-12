
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 PNG file                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

///////////////////////////////////////////////////////////////////////////////
// load PNG file (returns TRUE if OK)
/*
BOOL PNGLoad(FILE* file, BYTE** dst, int* w, int* h, int* wb, TEXIFMT* fmt,
										SRGBA** pal, SRGBA** trans);
*/

///////////////////////////////////////////////////////////////////////////////
// decode PNG picture (returns NULL on error; returns Canvas with ref=1)

SCanvas* PNGDecode(const u8* buf, int size);
