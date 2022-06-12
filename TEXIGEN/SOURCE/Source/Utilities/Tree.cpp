
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                  Tree List                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
// TexiGen - texture generator, (c) Miroslav Nemecek, http://panda38.sweb.cz/

#include "..\Include.h"

///////////////////////////////////////////////////////////////////////////////
// initialize tree entry

void CTreeEntry::Init()
{
	// next neighbor (NULL=none)
	m_Next = NULL;

	// previous neighbor (NULL=none)
	m_Prev = NULL;

	// parent (NULL=none, root)
	m_Parent = NULL;

	// first child (NULL=none)
	m_First = NULL;

	// last child (NULL=none)
	m_Last = NULL;
}

///////////////////////////////////////////////////////////////////////////////
// find next tree entry (cyclical)

CTreeEntry* _fastcall CTreeEntry::NextTreeEntry()
{
	if (m_First != NULL) return m_First;
	CTreeEntry* entry = this;
	for (;;)
	{
		if (entry->m_Next != NULL) return entry->m_Next;
		if (entry->m_Parent == NULL) return entry->m_First;
		entry = entry->m_Parent;
	}
}

///////////////////////////////////////////////////////////////////////////////
// find previous tree entry (cyclical)
/*
CTreeEntry* _fastcall CTreeEntry::PrevTreeEntry()
{
	CTreeEntry* entry = this;
	for (;;)
	{
		if (


	if (m_First != NULL) return m_First;
	CTreeEntry* entry = this;
	for (;;)
	{
		if (entry->m_Next != NULL) return entry->m_Next;
		if (entry->m_Parent == NULL) return entry->m_First;
		entry = entry->m_Parent;
	}
}
*/
///////////////////////////////////////////////////////////////////////////////
// find next entry, continue with neighbor, NULL=root (return NULL=none)

CTreeEntry* _fastcall CTreeEntry::NextEntryNeigh(CTreeEntry* root)
{
	CTreeEntry* entry = this;			// this entry will be starting
	do {
		if (entry->m_Next != NULL)	// does next neighbor follow?
		{
			entry = entry->m_Next;	// neighbor will be next valid entry
			break;
		}
		entry = entry->m_Parent;	// debouching into parent
		if (entry == root) return NULL; // root entry has been found
	} while (entry != NULL);		// until ROOT
	return entry;
}

///////////////////////////////////////////////////////////////////////////////
// find next entry in tree branch, NULL=root (return NULL=none)

CTreeEntry* _fastcall CTreeEntry::NextEntryBranch(CTreeEntry* root)
{
	CTreeEntry* entry = m_First;		// nesting into first child
	if (entry == NULL)				// there is no child
		entry = NextEntryNeigh(root);	// continue with neighbor
	return entry;
}

///////////////////////////////////////////////////////////////////////////////
// add new child (or branch) into begin of the list (new child can have
// branch of children, it must have initialized entries m_First and m_Last)

void _fastcall CTreeEntry::AddFirst(CTreeEntry* entry)
{
	entry->m_Next = m_First;
	entry->m_Prev = NULL;

	if (m_First == NULL)
		m_Last = entry;
	else
		m_First->m_Prev = entry;

	m_First = entry;
	entry->m_Parent = this;
}

///////////////////////////////////////////////////////////////////////////////
// add new child (or branch) into end of list (new child can have
// branch of children, it must have initialized entries m_First and m_Last)

void _fastcall CTreeEntry::AddLast(CTreeEntry* entry)
{
	entry->m_Next = NULL;
	entry->m_Prev = m_Last;

	if (m_Last == NULL)
		m_First = entry;
	else
		m_Last->m_Next = entry;

	m_Last = entry;
	entry->m_Parent = this;
}

///////////////////////////////////////////////////////////////////////////////
// add neighbor (or branch) after current entry (neighbor can have
// branch of children, it must have initialized entries m_First and m_Last)

void _fastcall CTreeEntry::AddAfter(CTreeEntry* entry)
{
	entry->m_Next = m_Next;
	entry->m_Prev = this;

	if (m_Next != NULL)
		m_Next->m_Prev = entry;
	else
		if (m_Parent != NULL)
			m_Parent->m_Last = entry;

	entry->m_Parent = m_Parent;
	m_Next = entry;
}

///////////////////////////////////////////////////////////////////////////////
// add neighbor (or branch) before current entry (neighbor can have
// branch of children, it must have initialized entries m_First and m_Last)

void _fastcall CTreeEntry::AddBefore(CTreeEntry* entry)
{
	entry->m_Next = this;
	entry->m_Prev = m_Prev;

	if (m_Prev != NULL)
		m_Prev->m_Next = entry;
	else
		if (m_Parent != NULL)
			m_Parent->m_First = entry;

	entry->m_Parent = m_Parent;
	m_Prev = entry;
}

///////////////////////////////////////////////////////////////////////////////
// detach entry (children will stay attached to entry, Parent <- NULL)

void CTreeEntry::Delete()
{
	if (m_Prev != NULL)
		m_Prev->m_Next = m_Next;
	else
		if (m_Parent != NULL)
			m_Parent->m_First = m_Next;

	if (m_Next != NULL)
		m_Next->m_Prev = m_Prev;
	else
		if (m_Parent != NULL)
			m_Parent->m_Last = m_Prev;

	m_Parent = NULL;
}
