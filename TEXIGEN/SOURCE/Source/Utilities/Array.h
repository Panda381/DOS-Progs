
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                Array List                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

template <class data_entry> class CArray
{
protected:

	// number of entries
	int				m_Num;

	// array size
	int				m_Max;

	// data array
	data_entry*		m_List;

	// set array size (without initializing entries, returns FALSE on error)
	inline BOOL SetSize(int num)
	{
		int max = (num + 0xff) & ~0xff;
		if (max > m_Max)
		{
			data_entry* lst = (data_entry*)realloc(m_List, max*sizeof(data_entry));
			if (lst == NULL) return FALSE;
			m_List = lst;
			m_Max = max;
		}
		m_Num = num;
		return TRUE;
	}

public:

	// constructor
	CArray()
	{
		m_Num = 0;
		m_Max = 0;
		m_List = NULL;
	}

	// destructor
	~CArray()
	{
		this->DelAll();
	}

	// delete all entries
	void DelAll()
	{
		int i;
		for (i = m_Num - 1; i >= 0; i--) m_List[i].~data_entry();
		free(m_List);
		m_Num = 0;
		m_Max = 0;
		m_List = NULL;
	}

	// number of entries in the list
	inline int Num() const { return m_Num; }

	// array of entries
	inline const data_entry* List() const { return m_List; }
	inline data_entry* List() { return m_List; }

	// check if index is valid
	inline BOOL IsValid(int inx) const { return (DWORD)inx < (DWORD)m_Num; }
	inline BOOL IsNotValid(int inx) const { return (DWORD)inx >= (DWORD)m_Num; }

	// array operator (without index checking)
	inline data_entry& operator[] (int inx) { return m_List[inx]; }
	inline const data_entry& operator[] (int inx) const { return m_List[inx]; }

	// add new empty entry (returns index or -1 on error)
	int New()
	{
		int inx = m_Num;
		if (!this->SetSize(inx+1)) return -1;
		new (&m_List[inx]) data_entry();
		return inx;
	}

	// add new entry (returns index or -1 on error)
	int Add(const data_entry& entry)
	{
		int inx = m_Num;
		if (!this->SetSize(inx+1)) return -1;
		new (&m_List[inx]) data_entry(entry);
		return inx;
	}

	// add another list (returns index of first entry or -1 on error)
	int Add(const CArray<data_entry>* list)
	{
		int inx = m_Num;
		int num = list->m_Num;
		if (num == 0) return inx;
		if (!this->SetSize(inx+num)) return -1;
		for (num--; num >= 0; num--)
			new (&m_List[inx+num]) data_entry(list->m_List[num]);
		return inx;
	}

	// insert new entry into list (limits index range, returns FALSE on error)
	BOOL Insert(int inx, const data_entry& entry)
	{
		if (inx < 0) inx = 0;
		int num = m_Num;
		if (inx > num) inx = num;
		if (!this->SetSize(num+1)) return FALSE;
		memmove(&m_List[inx+1], &m_List[inx], (num-inx)*sizeof(data_entry));
		new (&m_List[inx]) data_entry(entry);
		return TRUE;
	}

	// insert another list (limits index range, returns FALSE on error)
	BOOL Insert(int inx, const CArray<data_entry>* list)
	{
		if (list == this)
		{
			CArray<data_entry> lst;
			lst.Copy(list);
			return this->Insert(inx, &lst);
		}
		if (inx < 0) inx = 0;
		int num = m_Num;
		if (inx > num) inx = num;
		int num2 = list->m_Num;
		if (!this->SetSize(num+num2)) return FALSE;
		memmove(&m_List[inx+num2], &m_List[inx], (num-inx)*sizeof(data_entry));
		for (num2--; num2 >= 0; num2--)
			new (&m_List[inx+num2]) data_entry(list->m_List[num2]);
		return TRUE;
	}

	// copy list from another list (destroys old content, returns FALSE on error)
	BOOL Copy(const CArray<data_entry>* list)
	{
		this->DelAll();
		return (this->Add(list) >= 0);
	}

	// delete entry from the list (checks index range)
	void Delete(int inx, int num = 1)
	{
		if ((num > 0) && this->IsValid(inx))
		{
			if (num > m_Num - inx) num = m_Num - inx;
			int i = num;
			for (i--; i >= 0; i--) m_List[inx+i].~data_entry();
			memmove(&m_List[inx], &m_List[inx+num], (m_Num-inx-num)*sizeof(data_entry));
			this->SetSize(m_Num-num);
		}
	}
	inline void DelFirst() { this->Delete(0); }
	inline void DelLast() { this->Delete(BIGINT); }
	inline void DelToEnd(int inx) { this->Delete(inx, BIGINT); }

	// duplicate entry (returns index or -1 on error)
	inline int Dup(int inx)
	{
		if (this->IsNotValid(inx)) return -1;
		data_entry entry = m_List[inx]; // create copy of entry
		return this->Add(entry);
	}

	// operators
	inline const CArray<data_entry>& operator= (const CArray<data_entry>& src)
		{ this->Copy(&src); return *this; }
	inline const CArray<data_entry>& operator+= (const data_entry& src)
		{ this->Add(src); return *this; }
	inline const CArray<data_entry>& operator+= (const CArray<data_entry>& src)
		{ this->Add(&src); return *this; }
};
