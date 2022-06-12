
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Text Label                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications:
//	ON COMMAND with ID, label click

extern const CText StaticClass;

// default width and height of text label
extern int DefLabelW;
extern int DefLabelH;

///////////////////////////////////////////////////////////////////////////////
// text label

class CLabel : public CChildWindow
{
public:

	// constructor
	CLabel();

	// create label aligned left (returns FALSE on error)
	BOOL CreateLeft(const CText& text, int x, int y, int w = 0, int h = 0,
													CWindow* parent = NULL);
	BOOL CreateLeft(int txtid, int x, int y, int w = 0, int h = 0,
													CWindow* parent = NULL);

	// create label centered (returns FALSE on error)
	BOOL CreateCenter(const CText& text, int x, int y, int w = 0, int h = 0,
													CWindow* parent = NULL);
	BOOL CreateCenter(int txtid, int x, int y, int w = 0, int h = 0,
													CWindow* parent = NULL);

	// create label aligned right (returns FALSE on error)
	BOOL CreateRight(const CText& text, int x, int y, int w = 0, int h = 0,
													CWindow* parent = NULL);
	BOOL CreateRight(int txtid, int x, int y, int w = 0, int h = 0,
													CWindow* parent = NULL);
};
