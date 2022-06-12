'SQUAWK.BAS v 1.0  A sound effects sampler (C) 1987 by Merlin R. Null 4-17-87

DEFINT A-X
RANDOMIZE TIMER
Cuckoo$="T120L16MLO3BF#"
Zap$="T255L64MLO4BAGFEDC<BAGFEDEC<BAGFEDC<BAGFEDC<BAGFEDC"
Tifweet$="T255L32O4mlDGD<G>DGDDGDGBAGF#EE"
Zang1$="T255L64MLO2BCADGEFEGDACBCADGEFEGDACB"
Zang2$="T255L64MLO3BCADGEFEGDACBCADGEFEGDACB"
Zang3$="T255L64MLO4BCADGEFEGDACBCADGEFEGDACB"
Zang4$="T255L64MLO5BCADGEFEGDACBCADGEFEGDACB"
Downer1$="T150L64MSO4BGEC<AFL16D"
Downer2$="T150L64MSO4BFC<GD<AL16E"
Downer3$="T150L64MSO4BE<AD<GC<L32F"
UpScale1$="T150L64MSO3DFA>CEGL16B"
UpScale2$="T120L64MSO2E.A.>D.G.>C.F.B."
UpScale3$="T150L64MSO0F>CG>DA>EB."
Tweedle$="T240L64MLO4EGEGEGCFCFCFGEGEGE"
Whoople$="T255L64O4CDEFGABO3CDEFGABO2CDEFGAB"
Bongee1$="T255L64MLO1BAGFEDC<BAGFEDCP16>CDEFGAB>CDEFGABP32"
Bongee2$="T255L64MLO2BAGFEDC<BAGFEDCP16>CDEFGAB>CDEFGABP32"
Bongee3$="T255L64MLO3BAGFEDC<BAGFEDCP16>CDEFGAB>CDEFGABP32"
Bongee4$="T255L64MLO4BAGFEDC<BAGFEDCP16>CDEFGAB>CDEFGABP32"
Uhoh1$="T255L64MLO1CDEFGAB>CDEFGABP16<BAGFEDC<BAGFEDCP32"
Uhoh2$="T255L64MLO2CDEFGAB>CDEFGABP16<BAGFEDC<BAGFEDCP32"
Uhoh3$="T255L64MLO3CDEFGAB>CDEFGABP16<BAGFEDC<BAGFEDCP32"
Uhoh4$="T255L64MLO4CDEFGAB>CDEFGABP16<BAGFEDC<BAGFEDCP32"
BobWhite$="T120L16O4C#.P16T255L64mlC#DD#EFF#GG#AA#BO5CC#DD#EF"
Whung$="T255L32mlO3CD<CD>>CD<<CD>>CD<<CD>CD"
Phone2$="T240L64MLO4EGEGEGEGEGEGEGEGEGEGEGEGEGEGEG"
Tweet$="O4T255L64MLB-BB-BAGAG.>EGG>EGG"
Wolf$="T200L64MLO4C#DD#EFF#GG#AA#B>CC#DD#EFP8.<C#DD#EFF#GG#AA#B>CC#DD#EFFED#DC#C<BA#AG#GGF#FED#DC#"
Fweet$="T255L64MsO4C#DD#EFF#GG#AA#B>CC#DD#EF"
COLOR 14,1
CLS
LOCATE 3,10
PRINT"Squawkers and Zangers and Off-Key Loud Clangers and Things that";
LOCATE 4,10
PRINT"go Bleep in the Night.   (C) 1987 Merlin R. Null    version 1.0";
LOCATE 2,1
COLOR 15,1
PRINT TAB(6)"ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
PRINT TAB(6)"บ";
LOCATE 3,75
PRINT"บ"
PRINT TAB(6)"บ";
LOCATE 4,75
PRINT"บ"
PRINT TAB(6)"ฬออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน"
PRINT TAB(6)"บ  A  Cuckoo         N  Chang          a  Boingee 1      n  Mew      บ"
PRINT TAB(6)"บ  B  Zap            O  Oh!            b  Boingee 2      o  Tweet    บ"
PRINT TAB(6)"บ  C  Tifweet        P  Space 1        c  Boingee 3      p  Phone 1  บ"
PRINT TAB(6)"บ  D  Zang 1         Q  Space 2        d  Boingee 4      q  Phone 2  บ"
PRINT TAB(6)"บ  E  Zang 2         R  Gurgle         e  Uhoh 1         r  Wolf     บ"
PRINT TAB(6)"บ  F  Zang 3         S  Spectre        f  Uhoh 2         s  Siren    บ"
PRINT TAB(6)"บ  G  Zang 4         T  Grup 1         g  Uhoh 3         t  Fweet    บ"
PRINT TAB(6)"บ  H  Downer 1       U  Grup 2         h  Uhoh 4         u  Zhoup    บ"
PRINT TAB(6)"บ  I  Downer 2       V  Chirp          i  Bob White      v  Vrowr    บ"
PRINT TAB(6)"บ  J  Downer 3       W  Waver          j  Whung          w  Zhou     บ"
PRINT TAB(6)"บ  K  UpScale 1      X  Tweedle        k  Kazango        x  Art      บ"
PRINT TAB(6)"บ  L  UpScale 2      Y  Blurp          l  Who 1          y  Coo      บ"
PRINT TAB(6)"บ  M  UpScale 3      Z  Whoople        m  Who 2          z  Squawk   บ"
PRINT TAB(6)"ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
LOCATE 20,29
COLOR 12,1
PRINT"ษอออออป";
LOCATE 21,29
PRINT"บ F10 บ";
LOCATE 22,29
PRINT"ศอออออผ";
LOCATE 21,37
COLOR 15,1
PRINT"Cacophony";
LOCATE 24,6,1
PRINT"Noise (A-Z, a-z) or <Esc> to exit ? ";
While X$<>CHR$(27)
  IF Demoflag THEN
    IF INKEY$="" THEN
      X=INT(RND*52)+65
      IF X>90 THEN
        X=X+6
      END IF
      X$=CHR$(X)
    ELSE
      DemoFlag = 0
      LOCATE 24,6
      PRINT STRING$(40,32);
      LOCATE 24,6,1
      PRINT"Noise (A-Z, a-z) or <Esc> to exit ? ";
    END IF
  ELSEIF RandomSounds > 0 THEN
    X=INT(RND*52)+65
    IF X>90 THEN
      X=X+6
    END IF
    X$=CHR$(X)
    RandomSounds=RandomSounds-1
  ELSE
GetKey:
    X$=INKEY$
    IF X$="" THEN GOTO GetKey
  END IF

  IF LEN(X$)=2 THEN
    IF RIGHT$(X$,1)="D" THEN            '<F10>
      DemoFlag=-1
      LOCATE 24,6
      PRINT STRING$(45,32);
      LOCATE 24,6,0
      COLOR 12,1
      PRINT"Press Any Key to Stop... ";
      COLOR 15,1
    END IF
  ELSEIF X$>"0"AND X$<":" THEN		'1-9
    RandomSounds=VAL(X$)
  END IF
  IF LEN(X$)=1 AND X$>CHR$(31) THEN
    IF DemoFlag THEN
      LOCATE 24,31
      PRINT X$;
      LOCATE 24,31
    ELSE
      LOCATE 24,42
      PRINT X$;
      LOCATE 24,42
    END IF
  END IF
  IF X$="A" THEN
    PLAY "X" + VARPTR$(Cuckoo$)
  ELSEIF X$="B" THEN
    PLAY "X" + VARPTR$(Zap$)
  ELSEIF X$="C" THEN
    PLAY "X" + VARPTR$(Tifweet$)
  ELSEIF X$="D" THEN
    PLAY "X" + VARPTR$(Zang1$)
  ELSEIF X$="E" THEN
    PLAY "X" + VARPTR$(Zang2$)
  ELSEIF X$="F" THEN
    PLAY "X" + VARPTR$(Zang3$)
  ELSEIF X$="G" THEN
    PLAY "X" + VARPTR$(Zang4$)
  ELSEIF X$="H" THEN
    PLAY "X" + VARPTR$(Downer1$)
  ELSEIF X$="I" THEN
    PLAY "X" + VARPTR$(Downer2$)
  ELSEIF X$="J" THEN
    PLAY "X" + VARPTR$(Downer3$)
  ELSEIF X$="K" THEN
    PLAY "X" + VARPTR$(UpScale1$)
  ELSEIF X$="L" THEN
    PLAY "X" + VARPTR$(UpScale2$)
  ELSEIF X$="M" THEN
    PLAY "X" + VARPTR$(UpScale3$)
  ELSEIF X$="N" THEN			'Chang
    FOR J=1 TO 4
      FOR I=2000 TO 50 STEP -400
        SOUND I,.2
      NEXT
      FOR I=800 TO 2000 STEP 400
        SOUND I,.2
      NEXT
    NEXT
  ELSEIF X$="O" THEN
    FOR I=800 TO 2000 STEP 100		'Oh
      SOUND I,.2
    NEXT
    FOR I=2000 TO 50 STEP -100
      SOUND I,.2
    NEXT
  ELSEIF X$="P" THEN
    FOR I=1000 TO 40 STEP -20		'Space 1
      SOUND I,.2
    NEXT
  ELSEIF X$="Q" THEN
    FOR I=10000 TO 500 STEP -500	'Space 2
      SOUND I,.2
    NEXT
  ELSEIF X$="R" THEN
    FOR I=10 TO 50 STEP 10		'Gurgle
      FOR J=50 TO 10 STEP -10
       SOUND I^2+J^2,.1
      NEXT
    NEXT
  ELSEIF X$="S" THEN
    FOR Z=1 TO 30 STEP .4		'Spectre
      SOUND (SIN(Z)+40)*50,.2
    NEXT
  ELSEIF X$="T" THEN
    FOR I=10 TO 50 STEP 10		'Grup 1
      FOR J=50 TO 10 STEP -10
	SOUND I*J,.1
      NEXT
    NEXT
  ELSEIF X$="U" THEN
    FOR I=30 TO 70 STEP 10		'Grup 2
      FOR J=70 TO 30 STEP -10
	SOUND I*J,.1
      NEXT
    NEXT
  ELSEIF X$="V" THEN
    FOR I=30 TO 60 STEP 10		'Chirp
      FOR J=60 TO 30 STEP -10
	SOUND I*J,.2
      NEXT
    NEXT
  ELSEIF X$="W" THEN
    FOR Z=1 TO 30 STEP .7		'Waver
      SOUND (SIN(Z)+20)*30,.2
    NEXT
  ELSEIF X$="X" THEN
    PLAY "X" + VARPTR$(Tweedle$)
  ELSEIF X$="Y" THEN
    FOR I=1 TO 40			'Blurp
      SOUND INT(RND*1400)+450,.1
    NEXT
  ELSEIF X$="Z" THEN
    PLAY "X" + VARPTR$(Whoople$)
  ELSEIF X$="a" THEN                      'a
    PLAY "X" + VARPTR$(Bongee1$)
  ELSEIF X$="b" THEN
    PLAY "X" + VARPTR$(Bongee2$)
  ELSEIF X$="c" THEN
    PLAY "X" + VARPTR$(Bongee3$)
  ELSEIF X$="d" THEN
    PLAY "X" + VARPTR$(Bongee4$)
  ELSEIF X$="e" THEN
    PLAY "X" + VARPTR$(Uhoh1$)
  ELSEIF X$="f" THEN
    PLAY "X" + VARPTR$(Uhoh2$)
  ELSEIF X$="g" THEN
    PLAY "X" + VARPTR$(Uhoh3$)
  ELSEIF X$="h" THEN
    PLAY "X" + VARPTR$(Uhoh4$)
  ELSEIF X$="i" THEN
    PLAY "X" + VARPTR$(BobWhite$)
  ELSEIF X$="j" THEN
    PLAY "X" + VARPTR$(Whung$)
  ELSEIF X$="k" THEN
    FOR I=10000 TO 500 STEP -500	'Space 2
      SOUND I,.2
    NEXT
    PLAY "X" + VARPTR$(Zap$)
  ELSEIF X$="l" THEN
    FOR Y=10.2 TO 8.2 STEP -.2          'Who 1
      SOUND (TAN(Y)+36)*25,.8
      SOUND (SIN(Y)+20)*50,.4
    NEXT
  ELSEIF X$="m" THEN
    FOR Y=10.2 TO 8.2 STEP -.2          'Who 2
      SOUND (TAN(Y)+36)*10,.8
      SOUND (SIN(Y)+20)*20,.4
    NEXT
  ELSEIF X$="n" THEN
    FOR Y=10.8 TO 8 STEP -.1            'Mew
      SOUND (TAN(Y)+50)*25,.4
    NEXT
  ELSEIF X$="o" THEN
    FOR I=1 TO 3
      PLAY "X" +VARPTR$(Tweet$)
    NEXT
  ELSEIF X$="p" THEN
    FOR Y=1 TO 10			'Phone 1
      SOUND 1195,.4
      SOUND 2571,.4
    NEXT
  ELSEIF X$="q" THEN
    PLAY "X" + VARPTR$(Phone2$)
  ELSEIF X$="r" THEN
    PLAY "X" + VARPTR$(Wolf$)
  ELSEIF X$="s" THEN
    FOR Y=1 TO 3                        'siren
      SOUND 550,9
      SOUND 400,9
    NEXT
  ELSEIF X$="t" THEN
    FOR I=1 TO 2
      PLAY "X" +VARPTR$(Fweet$)
    NEXT
  ELSEIF X$="u" THEN
    FOR Z=3 TO 9 step .2                'Zhoup
      SOUND 120+Z^4,.1
      SOUND 0,.1
    NEXT
  ELSEIF X$="v" THEN
    FOR Z=9 TO 3 step -.1               'Vrowr
      SOUND 120+Z^4,.1
      SOUND 0,.1
    NEXT
  ELSEIF X$="w" THEN
    FOR I=40 TO 15 STEP -1              'Zhou
      SOUND I*90,.1
      SOUND I*80,.1
      SOUND I*70,.1
      SOUND I*60,.1
      SOUND I*50,.1
    NEXT
  ELSEIF X$="x" THEN
    FOR I=1 TO 10                        'Art
      SOUND 1195-50*I,.3
      SOUND 1195+50*I,.3
    NEXT
  ELSEIF X$="y" THEN
    FOR I=0 TO 150 STEP 10              'Coo
      SOUND 1295-I,.4
      SOUND 1095+I,.4
    NEXT
  ELSEIF X$="z" THEN                    'Squawk
    FOR I=1 TO 20
      SOUND I*50,.1
      SOUND I*100,.1
      SOUND I*150,.1
    NEXT
  END IF
WEND
END
