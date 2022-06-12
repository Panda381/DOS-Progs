dm.obj:       dm.asm dmuse.asm dmdat.asm
                tasm dm,dm /z $(demo) $(slov) $(upver) $(angl);

dmcom.obj:    dmcom.asm
                masm dmcom,dmcom /z $(demo) $(slov) $(upver) $(angl);

dmuse1.obj:    dmuse1.asm
                masm dmuse1,dmuse1 /z $(demo) $(slov) $(upver) $(angl);

dmint.obj:    dmint.asm
                masm dmint,dmint /z $(demo) $(slov) $(upver) $(angl);

dmwin.obj:    dmwin.asm
                masm dmwin,dmwin /z $(demo) $(slov) $(upver) $(angl);

dmtre.obj:    dmtre.asm
                masm dmtre,dmtre /z $(demo) $(slov) $(upver) $(angl);

dmfnd.obj:    dmfnd.asm
                masm dmfnd,dmfnd /z $(demo) $(slov) $(upver) $(angl);

dmhlp.obj:    dmhlp.asm
                masm dmhlp,dmhlp /z $(demo) $(slov) $(upver) $(angl);

dmsel.obj:    dmsel.asm
                masm dmsel,dmsel /z $(demo) $(slov) $(upver) $(angl);

dmmen.obj:    dmmen.asm
                masm dmmen,dmmen /z $(demo) $(slov) $(upver) $(angl);

dmedi.obj:    dmedi.asm
                masm dmedi,dmedi /z $(demo) $(slov) $(upver) $(angl);

dmzob.obj:    dmzob.asm
                masm dmzob,dmzob /z $(demo) $(slov) $(upver) $(angl);

dmini.obj:    dmini.asm
                masm dmini,dmini /z $(demo) $(slov) $(upver) $(angl);

dmlin.obj:    dmlin.asm
                masm dmlin,dmlin /z $(demo) $(slov) $(upver) $(angl);
