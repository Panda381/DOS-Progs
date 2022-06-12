
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                   Font                                    //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#define FONTMIN	33		// font minimal character
#define FONTMAX 126		// font maximal character

// character table (X offset in font picture)
extern int FontTabX[FONTMAX-FONTMIN+1];
extern int FontTabW[FONTMAX-FONTMIN+1];

// Font
extern u8 Font11_[];
#define Font11 ((SCanvas*)Font11_)

///////////////////////////////////////////////////////////////////////////////
// map font table

void FontTabMap();
