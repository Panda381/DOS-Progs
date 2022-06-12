
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Rectangle                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

/*
typedef struct tagSIZE {
	long	cx;
	long	cy;
} SIZE;
*/

// size
class CSize : public SIZE
{
public:

	// clear
	inline void Clear() { cx = 0; cy = 0; }

	// width
	inline int Width() const { return cx; }
	inline void SetWidth(int w) { cx = w; }

	// height
	inline int Height() const { return cy; }
	inline void SetHeight(int h) { cy = h; }

	// copy operator
	inline CSize& operator= (const CSize& sz)
		{ cx = sz.cx; cy = sz.cy; return *this;}
	inline CSize& operator= (const SIZE& sz)
		{ cx = sz.cx; cy = sz.cy; return *this;}
};

/*
typedef struct tagRECT
{
    long    left;
    long    top;
    long    right;
    long    bottom;
} RECT;
*/

// Rectangle
class CRect : public RECT
{
public:

	// clear
	inline void Clear() { left = 0; top = 0; right = 0; bottom = 0; }

	// width
	inline int Width() const { return right - left; }
	inline void SetWidth(int w) { right = left + w; }

	// height
	inline int Height() const { return bottom - top; }
	inline void SetHeight(int h) { bottom = top + h; }

	// set position and size
	inline void Set(int x, int y, int w, int h)
		{ left = x; top = y; right = x + w; bottom = y + h; }

	// set position
	inline void SetPos(int x, int y) { left = x; top = y; }

	// set size
	inline void SetSize(int w, int h) { right = left + w; bottom = top + h; }

	// shift position relative
	inline void AddPos(int dx, int dy) { left += dx; top += dy; }

	// change size relative
	inline void AddSize(int dw, int dh) { right += dw; bottom += dh; }

	// clip rectangle with another rectangle
	void Clip(const CRect& rc);

	// merge rectangle with another rectangle
	void Merge(const CRect& rc);

	// check point if it hits the rectangle
	inline BOOL Hit(int x, int y) const
	{ return ((x >= left) && (x < right) && (y >= top) && (y < bottom)); }

	// check if rectangle partially overlaps with another rectangle
	inline BOOL Overlap(const CRect& rc) const
		{ return ((left < rc.right) && (top < rc.bottom) &&
				(right > rc.left) && (bottom > rc.top)); }

	// check if rectangle is whole inside another rectangle
	inline BOOL Inside(const CRect& rc) const
	{ return ((left >= rc.left) && (top >= rc.top) &&
		(right <= rc.right) && (bottom <= rc.bottom)); }

	// copy operator
	inline CRect& operator= (const CRect& rc)
	{left=rc.left; top=rc.top; right=rc.right; bottom=rc.bottom; return *this;}
	inline CRect& operator= (const RECT& rc)
	{left=rc.left; top=rc.top; right=rc.right; bottom=rc.bottom; return *this;}

	// pointer to right and bottom size structure
	inline CSize* Size() { return (CSize*)&right; }
};
