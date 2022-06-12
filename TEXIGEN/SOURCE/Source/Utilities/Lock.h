
///////////////////////////////////////////////////////////////////////////////
//
//                               Section Lock
//
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Lock
class CLock
{

private:

	// synchronisation object
	CRITICAL_SECTION m_CriticalSection;

public:

	// constructor
	CLock();

	// destructor
	~CLock();

	// lock
	void Lock();

	// unlock
	void Unlock();

	// retype operator
	inline operator LPCRITICAL_SECTION() { return &m_CriticalSection; }
};
