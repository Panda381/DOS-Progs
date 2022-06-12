// Exec.h : header file
//



/*
A particularly complicated use of typedef is to define a synonym 
for a “pointer to a function that returns type T.” For example, 
a typedef declaration that means “pointer to a function that takes
no arguments and returns type void” uses this code:
  
typedef void (*PVFN)();
  
The synonym can be handy in declaring arrays of functions that are to be invoked through a pointer:
  
#include <iostream.h>
#include <stdlib.h>

extern void func1();         // Declare 4 functions.
extern void func2();         // These functions are assumed to be
extern void func3();         //  defined elsewhere.
extern void func4();
                             // Declare synonym for pointer to
typedef void (*PVFN)();      //  function that takes no arguments
                             //  and returns type void.

void main( int argc, char * argv[] )
{
    // Declare an array of pointers to functions.
    PVFN pvfn1[] = { func1, func2, func3, func4 };

    // Invoke the function specified on the command line.
    if( argc > 0 && *argv[1] > '0' && *argv[1] <= '4' )
	(*pvfn1[atoi( argv[1] ) - 1])();
}
  
*/






/////////////////////////////////////////////////////////////////////////////
// CExec form view

#ifndef __AFXEXT_H__
#include <afxext.h>
#endif

class CExec : public CFormView
{
public:
	CExec();           // protected constructor used by dynamic creation
	DECLARE_DYNCREATE(CExec)

// Form Data
public:
	//{{AFX_DATA(CExec)
	enum { IDD = IDR_EXEC };
	CAnimateCtrl	m_Exec;
	//}}AFX_DATA

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CExec)
	public:
	virtual void OnInitialUpdate();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	virtual ~CExec();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

	// Generated message map functions
	//{{AFX_MSG(CExec)
	afx_msg void OnSize(UINT nType, int cx, int cy);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
