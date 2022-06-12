
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                 Filter Graph                              //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Locking filter graph
//
// Lock with render thread:
// - read FGraph (cannot modify structure)
// - read PrevFilter
// - set off m_ReqPrev filter flag
//
// Lock with main thread:
// - modify structure FGraph (need not lock when reading)
// - set PrevFilter
// - set on m_ReqPrev filter flag

extern CLock	FLock;				// filter lock

// filter graph (LOCKED!)
extern CListCount<CFilter> FGraph;
extern CText FInfo;					// filter info

// output filters
#define OUTMAX	20			// max. number of output filters
extern CFilterOut* OutFilter[OUTMAX];// output filters
extern int		OutFilterNum;		// number of output filters (-1=none)
extern int		OutFilterInx;		// output filter index

// input filters
#define INMAX	100				// max. number of input filters
extern CFilterIn* InFilter[INMAX];	// input filters
extern BOOL InFilterLock[INMAX];	// input filters locks
extern int		InFilterNum;		// number of input filters

#define FMAXPOS		4000			// filter max. position (X or Y)
#define FRESMARG	300				// reserve marging around work area

// output dimension
//extern int		OutWidth;		// output width
//extern int		OutHeight;		// output height
//#define OUTWHMIN	4			// minimal dimension
//#define OUTWHMAX	32768		// maximal dimension
//
//extern BOOL		Anti;			// antialiasing

// filter graph
extern CText	GraphFilename;	// current graph filename
extern CText	GraphText;		// graph content

// filter graph view area
extern int FGraphViewX, FGraphViewY, FGraphViewX2, FGraphViewY2;

// filter graph select area
extern int FGraphSelX, FGraphSelY, FGraphSelX2, FGraphSelY2;

// filter graph modified
extern BOOL Modi;

///////////////////////////////////////////////////////////////////////////////
// clear filter graph (should be LOCKED!)

void ClearGraph();

///////////////////////////////////////////////////////////////////////////////
// get list of output filters

void GetOutFilt();

///////////////////////////////////////////////////////////////////////////////
// get list of input filters

void GetInFilt();

///////////////////////////////////////////////////////////////////////////////
// find filter by coordinates (NULL=not found)

CFilter* FindGraphFilter(int x, int y);

///////////////////////////////////////////////////////////////////////////////
// find filter by name (NULL=not found)

CFilter* FindGraphName(const CText& name);

///////////////////////////////////////////////////////////////////////////////
// restart all filters

void FGraphRestart();

///////////////////////////////////////////////////////////////////////////////
// find highest selected filter (NULL=none)

CFilter* FindGraphSelect();

///////////////////////////////////////////////////////////////////////////////
// delete filter (need lock FLock!)

void DelGraphSelect(CFilter* f);

///////////////////////////////////////////////////////////////////////////////
// create new filter name

CText NewGraphName();

///////////////////////////////////////////////////////////////////////////////
// find filter property by coordinates (from top, NULL=property not found)

CProperty* FindGraphProperty(int x, int y);

///////////////////////////////////////////////////////////////////////////////
// find filter output by coordinates (from top, NULL=not found)

CFilter* FindGraphOut(int x, int y);

///////////////////////////////////////////////////////////////////////////////
// check filter connection loopback (returns FALSE if connection forbidden)

BOOL GraphCheckLoop(CFilter* src, CFilter* dst);

///////////////////////////////////////////////////////////////////////////////
// request to update filter preview (with dependent filters; need lock FLock!)

void FGraphUpdate(CFilter* f);

///////////////////////////////////////////////////////////////////////////////
// move selected filters

void MoveGraphFilter(int dx, int dy);

///////////////////////////////////////////////////////////////////////////////
// align filters to grid

void GridGraphFilter();

///////////////////////////////////////////////////////////////////////////////
// move filter to top of graph

void TopGraphFilter(CFilter* f);

///////////////////////////////////////////////////////////////////////////////
// unselect all filters

void UnselectGraphFilter();

///////////////////////////////////////////////////////////////////////////////
// select filters in range

void SelGraphFilterRange(int x1, int y1, int x2, int y2);

///////////////////////////////////////////////////////////////////////////////
// clear filter graph with lock

void ClearGraphLock();

///////////////////////////////////////////////////////////////////////////////
// get view area of filters

void GetGraphView();

///////////////////////////////////////////////////////////////////////////////
// get select area of filters

void GetGraphSelect();

///////////////////////////////////////////////////////////////////////////////
// parameters correction before loading

void ParOnLoad(CText* txt);

///////////////////////////////////////////////////////////////////////////////
// load filter graph (returns FALSE on error, locks filter lock, empty text = no file)

BOOL LoadGraph(const CText& filename);

///////////////////////////////////////////////////////////////////////////////
// save filter graph (returns FALSE on error)

BOOL SaveGraph(const CText& filename);

///////////////////////////////////////////////////////////////////////////////
// save filter graph As

void SaveGraphAs();

///////////////////////////////////////////////////////////////////////////////
// check modification (returns FALSE = break operation)

BOOL CheckModi();

///////////////////////////////////////////////////////////////////////////////
// set filter modification

void SetModi();
