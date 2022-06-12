dm.obj:       dm.asm dmuse.asm dmdat.asm
                tasm dm,dm /z $(demo) $(slov) $(upver) $(angl);

dmcom.obj:    dmcom.asm
                tasm dmcom,dmcom /z $(demo) $(slov) $(upver) $(angl);

dmuse1.obj:    dmuse1.asm
                tasm dmuse1,dmuse1 /z $(demo) $(slov) $(upver) $(angl);

dmint.obj:    dmint.asm
                tasm dmint,dmint /z $(demo) $(slov) $(upver) $(angl);

dmwin.obj:    dmwin.asm
                tasm dmwin,dmwin /z $(demo) $(slov) $(upver) $(angl);

dmtre.obj:    dmtre.asm
                tasm dmtre,dmtre /z $(demo) $(slov) $(upver) $(angl);

dmfnd.obj:    dmfnd.asm
                tasm dmfnd,dmfnd /z $(demo) $(slov) $(upver) $(angl);

dmhlp.obj:    dmhlp.asm
                tasm dmhlp,dmhlp /z $(demo) $(slov) $(upver) $(angl);

dmsel.obj:    dmsel.asm
                tasm dmsel,dmsel /z $(demo) $(slov) $(upver) $(angl);

dmmen.obj:    dmmen.asm
                tasm dmmen,dmmen /z $(demo) $(slov) $(upver) $(angl);

dmedi.obj:    dmedi.asm
                tasm dmedi,dmedi /z $(demo) $(slov) $(upver) $(angl);

dmzob.obj:    dmzob.asm
                tasm dmzob,dmzob /z $(demo) $(slov) $(upver) $(angl);

dmini.obj:    dmini.asm
                tasm dmini,dmini /z $(demo) $(slov) $(upver) $(angl);

dmlin.obj:    dmlin.asm
                tasm dmlin,dmlin /z $(demo) $(slov) $(upver) $(angl);
