
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 TGA file                                  //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

///////////////////////////////////////////////////////////////////////////////
// decode JPG picture (returns NULL on error; returns Canvas with ref=1)

SCanvas* JPGDecode(const u8* buf, int size);

///////////////////////////////////////////////////////////////////////////////
// save JPEG file - only RGB (returns TRUE if OK)

BOOL JPGSave(const CText& filename, SCanvas* can, int quality = 50);
