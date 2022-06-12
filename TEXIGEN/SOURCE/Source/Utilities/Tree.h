
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Tree List                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

// Tree entry (size 20 bytes)
class CTreeEntry
{

protected:

	// next neighbor (NULL=none)
	CTreeEntry*		m_Next;

	// previous neighbor (NULL=none)
	CTreeEntry*		m_Prev;

	// parent (NULL=none, root)
	CTreeEntry*		m_Parent;

	// first child (NULL=none)
	CTreeEntry*		m_First;

	// last child (NULL=none)
	CTreeEntry*		m_Last;

public:

	// initialize tree entry
	void Init();

	// constructor
	inline CTreeEntry() { Init(); }

	// next neighbor (NULL=none)
	inline CTreeEntry* Next() const { return m_Next; }

	// previous neighbor (NULL=none)
	inline CTreeEntry* Prev() const { return m_Prev; }

	// parent (NULL=none, root)
	inline CTreeEntry* Parent() const { return m_Parent; }

	// first child (NULL=none)
	inline CTreeEntry* First() const { return m_First; }

	// last child (NULL=none)
	inline CTreeEntry* Last() const { return m_Last; }

	// find next tree entry (cyclical)
	CTreeEntry* _fastcall NextTreeEntry();

	// find next entry, continue with neighbor, NULL=root (return NULL=none)
	CTreeEntry* _fastcall NextEntryNeigh(CTreeEntry* root);

	// find next entry in tree branch, NULL=root (return NULL=none)
	CTreeEntry* _fastcall NextEntryBranch(CTreeEntry* root);

	// find next entry in the tree (returns NULL=none)
	inline CTreeEntry* NextEntry() { return NextEntryBranch(NULL); }

	// add new child (or branch) into begin of list (new child can have
	// branch of children, it must have initialized entries m_First and m_Last)
	void _fastcall AddFirst(CTreeEntry* entry);

	// add new child (or branch) into end of list (new child can have
	// branch of children, it must have initialized entries m_First and m_Last)
	void _fastcall AddLast(CTreeEntry* entry);

	// add neighbor (or branch) after current entry (neighbor can have
	// branch of children, it must have initialized entries m_First and m_Last)
	void _fastcall AddAfter(CTreeEntry* entry);

	// add neighbor (or branch) before current entry (neighbor can have
	// branch of children, it must have initialized entries m_First and m_Last)
	void _fastcall AddBefore(CTreeEntry* entry);

	// detach entry (children will stay attached to entry, Parent <- NULL)
	void Delete();
};

///////////////////////////////////////////////////////////////////////////////
// walking through children of tree branch in forward direction
//  entry = variable of CTreeEntry* base class
//  parent = parent of CTreeEntry* base class

#define TreeForEachChild(entry, parent) \
	for(entry = (parent)->First(); entry != NULL; entry = entry->Next())

///////////////////////////////////////////////////////////////////////////////
// walking through children of tree branch in back direction
//  entry = variable of CTreeEntry* base class
//  parent = parent of CTreeEntry* base class

#define TreeForEachChildBack(entry, parent) \
	for(entry = (parent)->Last(); entry != NULL; entry = entry->Prev())

///////////////////////////////////////////////////////////////////////////////
// walking throug all tree entries
//  entry = variable of CTreeEntry* base class
//  root = starting entry of CTreeEntry* base class

#define TreeForEach(entry, root) \
	for (entry = root; entry != NULL; entry = entry->NextEntryBranch(root))

///////////////////////////////////////////////////////////////////////////////
// get pointer to owner object from pointer to tree entry
//	entry = pointer to tree entry of CTreeEntry base class
//	type = class of owner of tree entry
//	member = name of member variable of tree entry in its owner

#define ObjectFromTree(entry, type, member) (type*)((char*)(entry) - \
		(((char*)&(((type*)NULL)->member)) - (char*)NULL))
