
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                            Font Selection Dialog                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

///////////////////////////////////////////////////////////////////////////////
// font selection dialog

class CFontSel
{
protected:

	// selected font
	LOGFONT		m_Font;

public:

	// constructor
	CFontSel();

	// selected font
	inline LOGFONT* Font() { return &m_Font; }

	// font height (>0 cell height, 0 default, <0 character height)
	// height = - pointsize * ::GetDeviceCaps(hDC, LOGPIXELSY) / 72
	inline int Height() const { return m_Font.lfHeight; }
	inline void SetHeight(int height = -16) { m_Font.lfHeight = height; }

	// font width (average width in logical units of characters, 0=default)
	inline int Width() const { return m_Font.lfWidth; }
	inline void SetWidth(int width = 0) { m_Font.lfWidth = width; }

	// font angle (in tenths of degrees)
	inline int Angle() const { return m_Font.lfEscapement; }
	inline void SetAngle(int angle = 0)
		{ m_Font.lfEscapement = angle; m_Font.lfOrientation = angle; }

	// font weight (0=default, 100=thin, 400=normal, 700=bold, 900=heavy)
	inline int Weight() const { return m_Font.lfWeight; }
	inline void SetWeight(int weight = 400) { m_Font.lfWeight = weight; }

	// italic
	inline BOOL Italic() const { return m_Font.lfItalic; }
	inline void SetItalic(BOOL italic = FALSE) { m_Font.lfItalic = (BYTE)italic; }

	// underline
	inline BOOL Underline() const { return m_Font.lfUnderline; }
	inline void SetUnderline(BOOL underline = FALSE)
		{ m_Font.lfUnderline = (BYTE)underline; }

	// strikeout
	inline BOOL StrikeOut() const { return m_Font.lfStrikeOut; }
	inline void SetStrikeOut(BOOL strikeout = FALSE)
		{ m_Font.lfStrikeOut = (BYTE)strikeout; }

	// character set
	inline int CharSet() const { return m_Font.lfCharSet; }
	inline void SetCharSet(int charset = DEFAULT_CHARSET)
		{ m_Font.lfCharSet = (BYTE)charset; }
	
	// output precision
	inline int Precision() const { return m_Font.lfOutPrecision; }
	inline void SetPrecision(int precision = OUT_DEFAULT_PRECIS)
		{ m_Font.lfOutPrecision = (BYTE)precision; }

	// clipping precision
	inline int Clipping() const { return m_Font.lfClipPrecision; }
	inline void SetClipping(int clipping = CLIP_DEFAULT_PRECIS)
		{ m_Font.lfClipPrecision = (BYTE)clipping; }

	// output quality
	inline int Quality() const { return m_Font.lfQuality; }
	inline void SetQuality(int quality = DEFAULT_QUALITY)
		{ m_Font.lfQuality = (BYTE)quality; }

	// pitch (DEFAULT_PITCH, FIXED_PITCH, VARIABLE_PITCH)
	inline int Pitch() const { return m_Font.lfPitchAndFamily & 3; }
	inline void SetPitch(int pitch = DEFAULT_PITCH) { m_Font.lfPitchAndFamily =
		(BYTE)((m_Font.lfPitchAndFamily & ~3) | pitch); }

	// font family (FF_DECORATIVE, FF_DONTCARE, FF_MODERN, FF_ROMAN,...)
	inline int Family() const { return m_Font.lfPitchAndFamily & 0xf0; }
	inline void SetFamily(int family) { m_Font.lfPitchAndFamily = 
		(BYTE)((m_Font.lfPitchAndFamily & ~0xf0) | family); }

	// typeface name of the font (empty=default)
	CText Face();
	void SetFace(CText face);

	// execute font selection dialog (returns FALSE on error or cancel)
	BOOL Execute(CWindow* parent = NULL);
};

// global font selection dialog
extern CFontSel FontSel;
