Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   mov       ah,0fh
         int       10h                      ; poskytnut� videom�du
         mov       bx,0b000h
         cmp       al,7
         je        Start2
         mov       bh,0b8h
         cmp       al,1
         jbe       Konec
         cmp       al,3
         ja        Konec
Start2:  xor       di,di
         mov       es,bx
         mov       si,offset Obraz
         mov       cx,80*12
         cld
         mov       ah,7
Start3:  lodsb
         stosw
         loop      Start3

         mov       al," "
         mov       cx,(25-12)*80
         rep       stosw

         xor       bx,bx
         mov       dx,12*256
         mov       ah,2
         int       10h                      ; nastaven� kurzoru

Konec:   int       20h

Obraz    label     byte
         db        '������������������������������������������������������������������������������ͻ'
         db        '�                                                                              �'
         db        '�    ����۲��  ������۲�� ��۲��  ��۲��    ���۲��                            �'
         db        '�   �۲���۲�� �۲��      ���۲�����۲��   �۲��۲��                           �'
         db        '�  �۲��       �۲��      �۲�۲�۲�۲��  �۲�� �۲��  �����         ���  ��   �'
         db        '�  �۲��       ���۲��    �۲���۲��۲�� �۲��   �۲�� ��            ��   ��   �'
         db        '�  �۲����۲�� �۲��      �۲��    �۲�� ���������۲�� ����� ������ ���� ����  �'
         db        '�   �۲���۲�� �۲��      �۲��    �۲�� �۲��   �۲��    �� ��  ��  ��   ��   �'
         db        '�    ����۲��  ������۲�� �۲��    �۲�� �۲��   �۲�� ����� ������  ��   ���  �'
         db        '�                                                                              �'
         db        '������������������������������������������������������������������������������ͼ'
         db        '                              zav�d� se program...                              '

Code     ENDS
         END       Start
