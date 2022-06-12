
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Render                                   //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// current render or preview values (thread specific)
extern __declspec (thread) real CurRenderX, CurRenderY;	// current render X and Y coordinates (range 0..1)
extern __declspec (thread) real CurRenderDX, CurRenderDY;	// current render X and Y deltas (range 0..1)

extern volatile BOOL RenderMode;

// render queue
#define RENDQUEUEMAX	500		// render queue max. length

typedef struct SRendQueue_
{
	CText	m_Group;			// filter group
	CText	m_Filter;			// filter name
	CText	m_Variant;			// variant name
	CText	m_Presets;			// presets string
	CText	m_File;				// output file
	int		m_Width;			// width
	int		m_Height;			// height
	BOOL	m_Anti;				// antialiasing
	BOOL	m_Cont;				// continue rendering
	BOOL	m_Trans;			// transparency
	int		m_Out;				// output filter index
	int		m_Time;				// time in seconds
	int		m_Frames;			// number of frames
	int		m_Frame;			// current frame
	int		m_Last;				// last frame
	BOOL	m_JPG;				// save to JPG
	int		m_Quality;			// JPG quality
	BOOL	m_Auto;				// auto name
} SRendQueue;

// on change update RenderPriorityTab[]
enum CPUPRIOR {
	CPUPRIOR_IDLE = 0,			// THREAD_PRIORITY_IDLE = -15
	CPUPRIOR_LOWEST = 1,		// -4
	CPUPRIOR_VERYLOW = 2,		// -3
	CPUPRIOR_LOW = 3,			// THREAD_PRIORITY_LOWEST = -2
	CPUPRIOR_LOWER = 4,			// THREAD_PRIORITY_BELOW_NORMAL = -1
	CPUPRIOR_NORMAL = 5,		// THREAD_PRIORITY_NORMAL = 0

	CPUPRIOR_NUM
};

// render priority constants (on change update CPUPRIOR)
extern const int RenderPriorityTab[];

#define RENDBUFSIZE	 65000		// render buffer size
#define RENDMAX 15				// max. number of render objects
#define RENDSLEEPN 100			// render sleep counter

extern int RenderFrames;		// render number of frames (0=no video)
extern int RenderFrame;			// render current frame
extern int RenderLast;			// render last frame

// render object
class CRender
{
public:

	// render buffer (65 KB)
	u8				m_Data[RENDBUFSIZE];

	// number of bytes in render buffer
	volatile int	m_Num;

	// number of bytes to render (= multiple of pixels)
	volatile int	m_Max;

	// render coordinates
	volatile int	m_X;
	volatile int	m_Y;

	// buffer is rendered OK (= wait and do not render)
	volatile u8		m_OK;

	// render sleep counter
	int				m_Sleep;

	// stop render thread request
	volatile u8		m_StopReq;

	// render filter
	CFilterOut*		m_OutFilter;

	// filter graph
	CListCount<CFilter>	m_Graph;

	// handle of render thread
	HANDLE			m_RenderThreadH;

	// start render object (returns FALSE on error)
	BOOL Start();

	// stop render object
	void Stop();
};

/////////////////////////////////////////////////////////////////////////////
// load render configuration

void LoadRenderIni();

/////////////////////////////////////////////////////////////////////////////
// update preset list box

//void UpdateRenderPresets();

///////////////////////////////////////////////////////////////////////////////
// open render window

void OpenRender();

///////////////////////////////////////////////////////////////////////////////
// generate mark in icon

void GenMark(u8* data);

///////////////////////////////////////////////////////////////////////////////
// save preview icon

void SaveIcon(const CText& filename /*, BOOL mark*/);
