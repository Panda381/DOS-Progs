
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Window Frame                               //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Notifications:
//	ON COMMAND with ID, frame click

// window frame type
typedef enum FRAMETYPE {
	FRAME_NONE		= 0,	// no border
	// frames with transparent content
	FRAME_DARK		= 1,	// dark gray frame
	FRAME_GRAY		= 2,	// gray frame
	FRAME_LIGHT		= 3,	// light gray frame
	FRAME_ETCHED	= 4,	// etched frame
	FRAME_HETCHED	= 5,	// horizontal etched line
	FRAME_VETCHED	= 6,	// vertical etched line
	// frames with non transparent content
	FRAME_DARKRECT	= 7,	// dark gray rectangle
	FRAME_GRAYRECT	= 8,	// gray rectangle
	FRAME_LIGHTRECT	= 9,	// light gray rectangle
	FRAME_HALFSUNK	= 10,	// half sunken frame
	FRAME_SUNKEN	= 11,	// sunken frame
	FRAME_DBLSUNK	= 12,	// doubly sunken frame
	FRAME_LINE		= 13,	// black frame
	FRAME_LINESUNK	= 14,	// line and half sunken frame
	FRAME_RAISED	= 15,	// raised frame
	FRAME_BUMP		= 16,	// bumped frame (raised and sunken)
};

///////////////////////////////////////////////////////////////////////////////
// window frame

class CFrame : public CChildWindow
{
protected:

	// frame type
	FRAMETYPE	m_FrameType;

public:

	// constructor
	CFrame();

	// frame type
	inline FRAMETYPE FrameType() const { return m_FrameType; }

	// create window frame (returns FALSE on error)
	BOOL CreateFrm(FRAMETYPE type, int x, int y, int w, int h,
													CWindow* parent = NULL);
};
