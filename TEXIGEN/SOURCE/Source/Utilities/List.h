
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                        Circular Doubly Linked List                        //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Entries in the list point to their neighbors - it is chain of entries linked
// into closed circle. Head of the list can be list entry, too.

// list entry (size 8 bytes)
class CListEntry
{

protected:

	// pointer to next entry
	CListEntry*		m_Next;

	// pointer to previous entry
    CListEntry*		m_Prev;

public:

	// next entry in the list
	inline CListEntry* Next() const { return m_Next; }

	// previous entry in the list
	inline CListEntry* Prev() const { return m_Prev; }

	// initialize list
	inline void Init() { m_Next = this; m_Prev = this; }

	// add another entry after this one
	inline void AddAfter(CListEntry* entry)
	{
		CListEntry* next = m_Next;
		next->m_Prev = entry;
		entry->m_Next = next;
		entry->m_Prev = this;
		m_Next = entry;
	}

	// add another entry before this one
	inline void AddBefore(CListEntry* entry)
	{
		CListEntry* prev = m_Prev;
		prev->m_Next = entry;
		entry->m_Prev = prev;
		m_Prev = entry;
		entry->m_Next = this;
	}

	// remove entry from the list
	inline void Del()
	{
		CListEntry* prev = m_Prev;
		CListEntry* next = m_Next;
		prev->m_Next = next;
		next->m_Prev = prev;
	}
};

// data list entry
template <class data_entry> class CListEntryData : public CListEntry
{
public:

	// next entry in the list
	inline data_entry* Next() const { return (data_entry*)m_Next; }

	// previous entry in the list
	inline data_entry* Prev() const { return (data_entry*)m_Prev; }
};

// head of the list (size 8 bytes)
template <class data_entry> class CListList : public CListEntry
{

private:

	// add another entry after this one
	inline void AddAfter(data_entry* entry)
		{ CListEntry::AddAfter(entry); }

	// add another entry before this one
	inline void AddBefore(data_entry* entry)
		{ CListEntry::AddBefore(entry); }

	// remove entry from the list
	inline void Del() { CListEntry::Del(); }

public:

	// constructor
	inline CListList() { Init(); }

	// head of the list - used as stop mark when walking through the list
	// Note: (CListEntry*) is needed due to correct retype object with virtual functions.
	inline const data_entry* Head() const { return (data_entry*)(CListEntry*)this; }

	// first entry of the list (returns "this" if list is empty)
	inline data_entry* First() const { return (data_entry*)Next(); }

	// last entry of the list (returns "this" if list is empty)
	inline data_entry* Last() const { return (data_entry*)Prev(); }

	// check if list is empty
	inline BOOL IsEmpty() const { return m_Next == m_Prev; }

	// add entry into start of the list
	inline void AddFirst(data_entry* entry) { CListEntry::AddAfter(entry); }

	// add entry into end of the list
	inline void AddLast(data_entry* entry) { CListEntry::AddBefore(entry); }

	// add entry after another one
	inline void AddAfter(data_entry* newentry, data_entry* oldentry)
				{ oldentry->AddAfter(newentry); }

	// add entry before another one
	inline void AddBefore(data_entry* newentry, data_entry* oldentry)
				{ oldentry->AddBefore(newentry); }

	// remove entry from the list
	inline static void Delete(data_entry* entry) { entry->Del(); }
};

// head of the list with count (size 12 bytes)
template <class data_entry> class CListCount : public CListList<data_entry>
{

protected:

	// number of entries in the list
	int			m_Count;

public:

	// initialize list
	inline void Init() { CListList<data_entry>::Init(); m_Count = 0; }

	// constructor
	inline CListCount() { m_Count = 0; }

	// number of entries in the list
	inline int Count() const { return m_Count; }

	// check if list is empty
	inline BOOL IsEmpty() const { return (m_Count == 0); }

	// add entry into start of the list
	inline void AddFirst(data_entry* entry)
			{ CListList<data_entry>::AddFirst(entry); m_Count++; }

	// add entry into end of the list
	inline void AddLast(data_entry* entry)
			{ CListList<data_entry>::AddLast(entry); m_Count++; }

	// add entry after another one
	inline void AddAfter(data_entry* newentry, data_entry* oldentry)
			{ oldentry->AddAfter(newentry); m_Count++; }

	// add entry before another one
	inline void AddBefore(data_entry* newentry, data_entry* oldentry)
			{ oldentry->AddBefore(newentry); m_Count++; }

	// remove entry from the list
	inline void Delete(data_entry* entry)
			{ CListList<data_entry>::Delete(entry); m_Count--; }
};

///////////////////////////////////////////////////////////////////////////////
// walking through the list in forward direction
//	entry = variable of CListEntry* base class
//	head = pointer to head of CListList or CListCount base class

#define ListForEach(entry, head) \
  for(entry = (head)->First(); entry != (head)->Head(); entry = entry->Next())

///////////////////////////////////////////////////////////////////////////////
// walking throgh the list in backward direction
//	entry = variable of CListEntry* base class
//	head = pointer to head of CListList or CListCount base class

#define ListForEachBack(entry, head) \
	for(entry = (head)->Last(); entry != (head)->Head(); entry = entry->Prev())

///////////////////////////////////////////////////////////////////////////////
// get pointer to owner object from pointer to list entry
//	entry = pointer to list entry of CListEntry base class
//	type = class of owner of the list entry
//	member = name of member variable of list entry in its owner

#define ObjectFromList(entry, type, member) (type*)((char*)(entry) - \
		(((char*)&(((type*)NULL)->member)) - (char*)NULL))

///////////////////////////////////////////////////////////////////////////////
// hash list

#define HASH_BITS	10				// hash list - number of bits of hash key
#define HASH_KEYS	(1<<HASH_BITS)	// hash list - number of hash keys
#define HASH_MASK	(HASH_KEYS-1)	// hash list - mask of hash key

// hash list
template <class data_entry> class CHashList
{
protected:

	// array of hash list branches
	CListList<data_entry>	m_Hash[HASH_KEYS];

	// total number of entries in the list
	int		m_Count;

public:

	// constructor
	inline CHashList()
	{
		int i;
		for (i = HASH_KEYS-1; i >= 0; i--) m_Hash[i].Init();
		m_Count = 0;
	}

	// total number of entries in the list
	inline int Count() const { return m_Count; }

	// hash value of the entry
	static inline int Hash(data_entry* entry)
	{
		int hash = entry->Hash();
		return (hash + (hash >> HASH_BITS) + (hash >> 2*HASH_BITS))&HASH_MASK;
	}

	// detach entry from the list
	inline void Delete(data_entry* entry)
	{
		entry->Del();
		m_Count--;
	}

	// add new entry into list (without checking similar entries)
	inline void AddHash(data_entry* entry, int hash)
	{
		m_Hash[hash].AddLast(entry);
		m_Count++;
	}

	inline void Add(data_entry* entry)
	{
		AddHash(entry, Hash(entry));
	}

	// find similar entry 
	//	(returns similar data entry or NULL if it does not exist)
	data_entry* FindHash(data_entry* entry, int hash)
	{
		data_entry* e;
		CListList<data_entry>* list = &m_Hash[hash];
		ListForEach(e, list)
		{
			if (*entry == *e) return e;
		}
		return NULL;
	}

	inline data_entry* Find(data_entry* entry)
	{
		return FindHash(entry, Hash(entry));
	}

	// add new entry into list if it does not exist
	//	(returns similar data entry or NULL if new entry was added)
	data_entry* AddNewHash(data_entry* entry, int hash)
	{
		data_entry* e = FindHash(entry, hash);
		if (e == NULL)
		{
			AddHash(entry, hash);
			e = NULL;
		}
		return e;
	}

	inline data_entry* AddNew(data_entry* entry)
	{
		return AddNewHash(entry, Hash(entry));
	}
};
